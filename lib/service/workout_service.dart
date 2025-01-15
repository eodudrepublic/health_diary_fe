import 'dart:convert';
import 'package:http/http.dart' as http;
import '../common/utils/logger.dart';
import '../common/server_url.dart';
import '../model/user_model.dart';

class WorkoutService {
  /// $serverUrl:8000/exercises GET 요청으로 운동 리스트를 받아온다.
  static Future<List<dynamic>> fetchExercises() async {
    final response = await http.get(Uri.parse('$serverUrl:8000/exercises'));

    if (response.statusCode == 200) {
      // 바이트 데이터를 UTF-8로 디코딩
      final decodedBody = utf8.decode(response.bodyBytes);
      return jsonDecode(decodedBody) as List;
    } else {
      throw Exception('Failed to load exercises');
    }
  }

  /// 유저의 신체 기록을 생성하는 메서드
  /// - [recordDate], [weight], [muscleMass], [bodyFatPercentage]를 전달받아 BodyMetrics를 생성
  static Future<Map<String, dynamic>?> postBodyMetrics({
    required String recordDate,
    required double weight,
    required double muscleMass,
    required double bodyFatPercentage,
  }) async {
    final userId = AppUser().id;
    // final userId = 3872309321; // 데모용

    if (userId == null) {
      Log.warning("postBodyMetrics() 실패: userId가 null입니다. 로그인 여부를 확인하세요.");
      return null;
    }

    final url = Uri.parse('$serverUrl:8000/users/$userId/body_metrics');
    Log.info("신체 기록 업로드 시작 -> $url");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "record_date": recordDate,
          "weight": weight,
          "muscle_mass": muscleMass,
          "body_fat_percentage": bodyFatPercentage,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        Log.info("신체 기록 업로드 성공: $data");
        return data;
      } else {
        Log.error(
          "신체 기록 업로드 실패: "
          "statusCode=${response.statusCode}, body=${response.body}",
        );
        return null;
      }
    } catch (e) {
      Log.error("신체 기록 업로드 중 예외 발생: $e");
      return null;
    }
  }

  /// 유저의 신체 기록 전체 목록을 조회하는 메서드
  // TODO : 현재 운동 기록 데이터 불러오는게 없어서 이걸로 대체
  /// - 성공 시, List<Map<String, dynamic>> 형태로 반환
  static Future<List<Map<String, dynamic>>?> fetchBodyMetrics() async {
    final userId = AppUser().id;
    // final userId = 3872309321; // 데모용

    if (userId == null) {
      Log.warning("fetchBodyMetrics() 실패: userId가 null입니다. 로그인 여부를 확인하세요.");
      return null;
    }

    final url = Uri.parse('$serverUrl:8000/users/$userId/body_metrics');
    Log.info("신체 기록 목록 조회 시작 -> $url");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = jsonDecode(decodedBody);

        // 필요한 필드만 추출하여 반환 (예: id, user_id, record_date, weight 등)
        final List<Map<String, dynamic>> results = data.map((e) {
          return {
            "id": e["id"],
            "user_id": e["user_id"],
            "record_date": e["record_date"],
            "weight": e["weight"],
            "muscle_mass": e["muscle_mass"],
            "body_fat_percentage": e["body_fat_percentage"],
          };
        }).toList();

        Log.info("신체 기록 목록 조회 성공: ${results.length}개");
        return results;
      } else {
        Log.error(
          "신체 기록 목록 조회 실패: "
          "statusCode=${response.statusCode}, body=${response.body}",
        );
        return null;
      }
    } catch (e) {
      Log.error("신체 기록 목록 조회 중 예외 발생: $e");
      return null;
    }
  }
}
