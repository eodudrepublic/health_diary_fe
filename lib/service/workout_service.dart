import 'dart:convert';
import 'package:http/http.dart' as http;
import '../common/server_url.dart';

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

// 앞으로 운동/루틴 관련 서버 통신이 늘어나면 아래에 추가
}
