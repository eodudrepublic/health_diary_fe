import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../common/server_url.dart';
import '../../common/utils/logger.dart';
import '../../model/user_model.dart';
import '../../service/kakao_login_api.dart';

class UserController extends GetxController {
  // Rx<AppUser?>은 반응형으로 사용자 정보를 저장합니다.
  var user = Rxn<AppUser>();
  final KakaoLoginApi kakaoLoginApi;

  UserController({required this.kakaoLoginApi});

  @override
  void onInit() {
    super.onInit();
    // 싱글톤 인스턴스로 초기화
    user.value = AppUser();
  }

  // 카카오 로그인 메서드
  Future<void> kakaoLogin() async {
    try {
      var kakaoUser = await kakaoLoginApi.signWithKakao();
      if (kakaoUser != null) {
        AppUser appUser = AppUser.fromKakaoUser(kakaoUser);
        user.value = appUser;
        Get.snackbar('성공', '카카오 로그인이 성공했습니다.');

        // Prepare JSON payload
        Map<String, dynamic> payload = {
          "kakao_id": appUser.id.toString(), // 필드 이름 변경
          "nickname": appUser.nickname ?? "",
          "profile_image": appUser.profileImageUrl ?? "", // 필드 이름 변경
          "connected_at": DateTime.now().toIso8601String(), // 누락된 필드 추가
        };


        // Send POST request to the server
        var response = await http.post(
          Uri.parse("$serverUrl:8000/users/login"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(payload),
        ).timeout(Duration(seconds: 15)); // 타임아웃 추가
        //

        // 응답 확인
        Log.info("Status Code: ${response.statusCode}");
        Log.info("Response Body: ${response.body}");
        Log.info("Payload being sent: ${jsonEncode(payload)}");


        if (response.statusCode == 200 || response.statusCode == 201) {
          var responseData = jsonDecode(response.body);
          String message = responseData["message"];
          Log.info("서버 전송 성공! Server response: $message");
          // Get.snackbar('서버 응답', message);
        } else {
          Log.error('서버와의 통신 중 문제가 발생했습니다. 상태 코드: ${response.statusCode}');
          Get.snackbar(
              '서버 오류', '서버와의 통신 중 문제가 발생했습니다. 상태 코드: ${response.statusCode}');
        }
      } else {
        Get.snackbar('실패', '카카오 로그인이 취소되었거나 실패했습니다.');
      }
    } catch (error) {
      Log.error('로그인 중 오류가 발생했습니다: $error');
      Get.snackbar('오류', '로그인 중 오류가 발생했습니다: $error');
    }
  }

  // 로그아웃 메서드 (선택 사항)
  Future<void> kakaoLogout() async {
    try {
      await kakaoLoginApi.logout();
      AppUser().clearUser();
      user.value = AppUser();
      Get.snackbar('성공', '로그아웃에 성공했습니다.');
    } catch (error) {
      Get.snackbar('실패', '로그아웃에 실패했습니다.');
    }
  }
}
