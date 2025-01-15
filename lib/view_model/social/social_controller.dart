import 'dart:io';
import 'package:get/get.dart';
import '../../service/image_service.dart';
import '../../common/utils/logger.dart';

/// 소셜 관련 데이터를 다루는 컨트롤러
class SocialController extends GetxController {
  /// [내가 올린 오운완 사진 목록] (id, photo_path)
  var ownPhotos = <Map<String, dynamic>>[].obs;

  /// [SNS에 업로드된 사진 목록] (id, user_id, datetime, photo_path, is_uploaded)
  var socialPhotos = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // 화면 진입 시, SNS 업로드된 사진 목록 불러오기
    fetchSocialPhotos();
  }

  /// 서버에서 내가 올린 오운완 사진 목록을 불러온다.
  /// BottomSheet에 표시할 것이므로, 이 메서드는 플로팅버튼을 누를 때 호출됨
  Future<void> fetchOwnPhotosForSheet() async {
    ownPhotos.clear();
    final results = await ImageService.fetchOwnPhotos();
    if (results != null) {
      for (var item in results) {
        final path = item["photo_path"] ?? "";
        if (path.isNotEmpty && File(path).existsSync()) {
          ownPhotos.add(item);
        } else {
          Log.warning("해당 경로의 파일을 찾을 수 없습니다: $path");
        }
      }
      ownPhotos.addAll(results);
      Log.info("내 오운완 사진 불러오기 완료. 총 ${ownPhotos.length}개");
    } else {
      Log.warning("오운완 사진 조회 결과가 없습니다.");
    }
  }

  /// SNS에 업로드된 사진 목록 불러오기
  Future<void> fetchSocialPhotos() async {
    socialPhotos.clear();
    final results = await ImageService.fetchSocialPhotos();
    if (results != null) {
      socialPhotos.addAll(results);
      Log.info("SNS 사진 불러오기 완료. 총 ${socialPhotos.length}개");
    } else {
      Log.warning("SNS 사진 조회 결과가 없습니다.");
    }
  }

  /// 선택한 사진(photoId)을 SNS에 업로드
  /// 업로드 성공 시, [fetchSocialPhotos]를 재호출해 목록 갱신
  Future<void> uploadSocialPhoto(int photoId) async {
    final result = await ImageService.uploadSocialPhoto(photoId);
    if (result != null) {
      Log.info("SNS 사진 업로드 성공 -> photoId: $photoId");
      // 업로드 성공 시, SNS 사진 목록 재불러오기
      await fetchSocialPhotos();
    }
  }
}
