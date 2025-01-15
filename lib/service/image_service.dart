import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../common/utils/logger.dart';
import '../common/server_url.dart';
import '../model/user_model.dart';

/// 서버에 이미지를 업로드하고 조회하는 기능을 담당하는 서비스.
/// - 오운완 사진 업로드: [uploadOwnPhoto]
/// - 식단 사진 업로드: [uploadMealPhoto]
/// - 오운완 사진 조회: [fetchOwnPhotos]
/// - 식단 사진 조회: [fetchMealPhotos]
/// - SNS 사진 업로드: [uploadSocialPhoto]
/// - SNS 사진 목록 조회: [fetchSocialPhotos]
class ImageService extends GetxService {
  /// 오운완 사진 업로드
  static Future<Map<String, dynamic>?> uploadOwnPhoto(String imagePath) async {
    final userId = AppUser().id;
    // final userId = 3872309321;
    if (userId == null) {
      Log.warning("업로드 실패: userId가 null입니다. 로그인 여부를 확인하세요.");
      return null;
    }

    final url = Uri.parse('$serverUrl:8000/users/$userId/own_photos');
    Log.info("오운완 사진 업로드 시작 -> $url");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"photo_path": imagePath}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        Log.info("오운완 사진 업로드 성공: $data");
        return data;
      } else {
        Log.error(
            "오운완 사진 업로드 실패: statusCode=${response.statusCode}, body=${response.body}");
        return null;
      }
    } catch (e) {
      Log.error("오운완 사진 업로드 중 예외 발생: $e");
      return null;
    }
  }

  /// 식단 사진 업로드
  static Future<Map<String, dynamic>?> uploadMealPhoto(String imagePath) async {
    final userId = AppUser().id;
    // final userId = 3872309321;
    if (userId == null) {
      Log.warning("업로드 실패: userId가 null입니다. 로그인 여부를 확인하세요.");
      return null;
    }

    final url = Uri.parse('$serverUrl:8000/users/$userId/meal_photos');
    Log.info("식단 사진 업로드 시작 -> $url");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"photo_path": imagePath}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        Log.info("식단 사진 업로드 성공: $data");
        return data;
      } else {
        Log.error(
            "식단 사진 업로드 실패: statusCode=${response.statusCode}, body=${response.body}");
        return null;
      }
    } catch (e) {
      Log.error("식단 사진 업로드 중 예외 발생: $e");
      return null;
    }
  }

  /// 오운완 사진 목록 조회
  /// - GET $serverUrl:8000/users/{user_id}/own_photos
  /// - 성공 시, List<Map<String, dynamic>> 형태로 반환 (id, photo_path 필드만)
  static Future<List<Map<String, dynamic>>?> fetchOwnPhotos() async {
    final userId = AppUser().id;
    // final userId = 3872309321;
    if (userId == null) {
      Log.warning("조회 실패: userId가 null입니다. 로그인 여부를 확인하세요.");
      return null;
    }

    final url = Uri.parse('$serverUrl:8000/users/$userId/own_photos');
    Log.info("오운완 사진 조회 시작 -> $url");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // UTF-8로 디코딩된 문자열을 파싱
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = jsonDecode(decodedBody);

        // 각 요소에서 id, photo_path만 추출
        final List<Map<String, dynamic>> results = data.map((e) {
          return {
            "id": e["id"],
            "photo_path": e["photo_path"],
          };
        }).toList();

        Log.info("오운완 사진 조회 성공: ${results.length}개");
        return results;
      } else {
        Log.error(
            "오운완 사진 조회 실패: statusCode=${response.statusCode}, body=${response.body}");
        return null;
      }
    } catch (e) {
      Log.error("오운완 사진 조회 중 예외 발생: $e");
      return null;
    }
  }

  /// 식단 사진 목록 조회
  /// - GET $serverUrl:8000/users/{user_id}/meal_photos
  /// - 성공 시, List<Map<String, dynamic>> 형태로 반환 (id, photo_path 필드만)
  static Future<List<Map<String, dynamic>>?> fetchMealPhotos() async {
    final userId = AppUser().id;
    // final userId = 3872309321;
    if (userId == null) {
      Log.warning("조회 실패: userId가 null입니다. 로그인 여부를 확인하세요.");
      return null;
    }

    final url = Uri.parse('$serverUrl:8000/users/$userId/meal_photos');
    Log.info("식단 사진 조회 시작 -> $url");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        // UTF-8로 디코딩된 문자열을 파싱
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = jsonDecode(decodedBody);

        // 각 요소에서 id, photo_path만 추출
        final List<Map<String, dynamic>> results = data.map((e) {
          return {
            "id": e["id"],
            "photo_path": e["photo_path"],
          };
        }).toList();

        Log.info("식단 사진 조회 성공: ${results.length}개");
        return results;
      } else {
        Log.error(
            "식단 사진 조회 실패: statusCode=${response.statusCode}, body=${response.body}");
        return null;
      }
    } catch (e) {
      Log.error("식단 사진 조회 중 예외 발생: $e");
      return null;
    }
  }

  /// SNS 사진 업로드
  /// - POST $serverUrl:8000/users/{user_id}/social/upload
  /// - 파라미터 [photoId]: 업로드할 사진의 id
  /// - body: {"photo_id": photoId, "base64_image": "test"}
  ///   TODO: photoId에 해당하는 실제 이미지를 base64로 인코딩해서 넣어야 함
  static Future<Map<String, dynamic>?> uploadSocialPhoto(int photoId) async {
    final userId = AppUser().id;
    // final userId = 3872309321;
    if (userId == null) {
      Log.warning("SNS 업로드 실패: userId가 null입니다. 로그인 여부를 확인하세요.");
      return null;
    }

    final url = Uri.parse('$serverUrl:8000/users/$userId/social/upload');
    Log.info("SNS 사진 업로드 시작 -> $url");

    // TODO: photoId에 해당하는 이미지를 base64로 인코딩해서 base64_image 필드에 넣어야 합니다.
    // 현재는 "test" 문자열로 고정.
    final requestBody = {
      "photo_id": photoId,
      "base64_image": "test", // TODO: 실제 base64 인코딩된 이미지로 변경
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        Log.info("SNS 사진 업로드 성공: $data");
        return data;
      } else {
        Log.error(
            "SNS 사진 업로드 실패: statusCode=${response.statusCode}, body=${response.body}");
        return null;
      }
    } catch (e) {
      Log.error("SNS 사진 업로드 중 예외 발생: $e");
      return null;
    }
  }

  /// SNS 사진 목록 조회
  /// - GET $serverUrl:8000/users/{user_id}/social/photos
  /// - 성공 시, List<Map<String, dynamic>> 형태로 반환
  ///   (id, user_id, datetime, photo_path, is_uploaded 필드)
  static Future<List<Map<String, dynamic>>?> fetchSocialPhotos() async {
    final userId = AppUser().id;
    // final userId = 3872309321;
    if (userId == null) {
      Log.warning("SNS 사진 조회 실패: userId가 null입니다. 로그인 여부를 확인하세요.");
      return null;
    }

    final url = Uri.parse('$serverUrl:8000/users/$userId/social/photos');
    Log.info("SNS 사진 조회 시작 -> $url");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final String decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = jsonDecode(decodedBody);

        // 필요한 필드만 추출
        final List<Map<String, dynamic>> results = data.map((e) {
          return {
            "id": e["id"],
            "user_id": e["user_id"],
            "datetime": e["datetime"],
            "photo_path": e["photo_path"],
            "is_uploaded": e["is_uploaded"],
          };
        }).toList();

        Log.info("SNS 사진 조회 성공: ${results.length}개");
        return results;
      } else {
        Log.error(
            "SNS 사진 조회 실패: statusCode=${response.statusCode}, body=${response.body}");
        return null;
      }
    } catch (e) {
      Log.error("SNS 사진 조회 중 예외 발생: $e");
      return null;
    }
  }
}
