import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/server_url.dart';
import '../../common/utils/logger.dart';

class MyPageController extends GetxController {
  final RxString name = "".obs;
  final RxnString profileImage = RxnString();
  final RxInt exerciseDays = 0.obs;
  final RxInt userId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserProfile();
  }

  // 사용자 프로필 및 ID 로드
  Future<void> loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getInt('user_id');
      Log.info("Loaded user_id from SharedPreferences: $id");

      if (id != null) {
        userId.value = id;
        await fetchUserProfile(id);
      } else {
        Log.info("User ID not found in SharedPreferences");
      }
    } catch (e) {
      Log.info("Error loading user profile: $e");
    }
  }

  // 사용자 프로필 서버에서 가져오기
  Future<void> fetchUserProfile(int id) async {
    try {
      Log.info("Fetching user profile for ID: $id");
      final response = await http.get(
        Uri.parse("$serverUrl:8000/users/$id/profile"),
      );

      Log.info("Response status: ${response.statusCode}");
      Log.info("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedData = jsonDecode(utf8.decode(response.bodyBytes));
        Log.info("Decoded data: $decodedData");

        name.value = decodedData["nickname"] ?? "Anonymous";
        profileImage.value = decodedData["profile_image"];
        exerciseDays.value = decodedData["completed_days"] ?? 0;

        Log.info("Updated name: ${name.value}");
        Log.info("Updated profileImage: ${profileImage.value}");
        Log.info("Updated exerciseDays: ${exerciseDays.value}");
      } else {
        Log.info("Failed to fetch user profile: ${response.statusCode}");
      }
    } catch (e) {
      Log.info("Error fetching user profile: $e");
    }
  }

  // QR 코드 스캔 및 친구 추가
  Future<void> addFriendFromQrCode(String scannedUserId) async {
    try {
      final response = await http.post(
        Uri.parse("$serverUrl:8000/friends"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "scanned_user_id": userId.value,
          "qr_user_id": int.parse(scannedUserId),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Log.info("Friend added successfully.");
        Get.snackbar("친구 추가 성공", "친구가 성공적으로 추가되었습니다.");
      } else {
        Log.info("Failed to add friend: ${response.statusCode}");
        Get.snackbar("친구 추가 실패", "상태 코드: ${response.statusCode}");
      }
    } catch (e) {
      Log.info("Error adding friend: $e");
      Get.snackbar("친구 추가 실패", "네트워크 오류가 발생했습니다.");
    }
  }

  // Future<List<Map<String, dynamic>>> fetchFriends(String userId) async {
  //   final String apiUrl = "$serverUrl:8000/users/$userId/friends";
  //   try {
  //     final response = await http.get(Uri.parse(apiUrl));
  //
  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = jsonDecode(response.body);
  //       return data.map((friend) => friend as Map<String, dynamic>).toList();
  //     } else {
  //       Log.info("Failed to load friends: ${response.statusCode}");
  //       throw Exception("Failed to load friends");
  //     }
  //   } catch (e) {
  //     Log.info("Error fetching friends: $e");
  //     throw Exception("Error fetching friends");
  //   }
  // }

  // QR 코드 데이터 생성
  String generateQrCode() {
    Log.info("Debug: Generating QR Code for userId: ${userId.value}");
    return userId.value.toString(); // user_id를 QR 코드 데이터로 사용
  }
}
