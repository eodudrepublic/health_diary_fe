import 'dart:io';
import 'package:get/get.dart';
import '../../common/utils/logger.dart';
import '../../service/image_service.dart';
import '../../service/workout_service.dart';

class CalendarController extends GetxController {
  // 현재 선택된 탭 상태
  var selectedIndex = 0.obs;

  // 탭 이름 리스트
  final List<String> tabs = ['운동', '오운완', '식단'];

  // 선택된 날짜
  var selectedDate = DateTime.now().obs;

  // 포커스된 날짜
  var focusedDay = DateTime.now().obs;

  // 마커가 있는 날짜들
  var markedDates = <DateTime>{}.obs;

  // 오운완 사진 경로 리스트
  var ownPhotoPaths = <String>[].obs;

  // 식단 사진 경로 리스트
  var mealPhotoPaths = <String>[].obs;

  // ─────────────────────────────────────────────────────────
  // [운동] 탭에 보여줄 신체 기록 데이터
  // ─────────────────────────────────────────────────────────
  var bodyMetrics = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    // 화면 진입 시, 신체 기록 불러오기
    loadBodyMetrics();
  }

  // 탭 선택 메서드
  void changeTab(int index) {
    selectedIndex.value = index;

    // 탭이 "오운완(1)" 또는 "식단(2)" 으로 바뀔 때마다 사진 목록 가져오기
    if (index == 1) {
      fetchOwnPhotos();
    } else if (index == 2) {
      fetchMealPhotos();
    }
  }

  // ─────────────────────────────────────────────────────────
  // [운동] 탭 관련 메서드들 (달력, 마커)
  // ─────────────────────────────────────────────────────────

  // 날짜 선택 메서드
  void onDaySelected(DateTime selectedDay, DateTime focusedDay_) {
    selectedDate.value = selectedDay;
    focusedDay.value = focusedDay_;
  }

  // 월 변경 시 포커스된 날짜 업데이트
  void onPageChanged(DateTime focusedDay_) {
    focusedDay.value = focusedDay_;
  }

  // 마커 추가 메서드
  void addMarker(DateTime date) {
    Log.trace("마커 추가: $date");
    markedDates.add(date);
  }

  // 마커 제거 메서드
  void removeMarker(DateTime date) {
    markedDates.remove(date);
  }

  // 특정 월에 마커가 있는지 확인
  List<DateTime> getMarkersForMonth(DateTime month) {
    return markedDates
        .where((date) => date.year == month.year && date.month == month.month)
        .toList();
  }

  /// WorkoutService에서 신체 기록 데이터를 불러와 저장
  Future<void> loadBodyMetrics() async {
    final results = await WorkoutService.fetchBodyMetrics();
    if (results != null) {
      bodyMetrics.value = results;
      Log.info("신체 기록 불러오기 완료. 총 ${results.length}개");

      // 가져온 신체 기록의 날짜들을 마커로 추가
      for (var item in results) {
        if (item["record_date"] != null) {
          try {
            final date = DateTime.parse(item["record_date"]);
            addMarker(date);
          } catch (e) {
            Log.warning("record_date 파싱 실패: ${item["record_date"]} / $e");
          }
        }
      }
    } else {
      Log.warning("신체 기록 조회 결과가 없습니다.");
    }
  }

  // ─────────────────────────────────────────────────────────
  // [오운완, 식단] 탭 관련 메서드들 (사진 불러오기)
  // ─────────────────────────────────────────────────────────

  /// 오운완 사진 목록 불러오기
  Future<void> fetchOwnPhotos() async {
    ownPhotoPaths.clear();

    final results = await ImageService.fetchOwnPhotos();
    if (results != null) {
      // results: [ { "id": 1, "photo_path": "..." }, ... ]
      for (var item in results) {
        final path = item["photo_path"] ?? "";
        // 파일 존재 여부 확인
        if (path.isNotEmpty && File(path).existsSync()) {
          ownPhotoPaths.add(path);
        } else {
          // 파일이 없거나 경로가 비었을 경우 Log 출력 후 건너뜀
          Log.warning("해당 경로의 파일을 찾을 수 없습니다: $path");
        }
      }
      Log.info("오운완 사진 불러오기 완료. 총 ${ownPhotoPaths.length}개");
    } else {
      Log.warning("오운완 사진 조회 결과가 없습니다.");
    }
  }

  /// 식단 사진 목록 불러오기
  Future<void> fetchMealPhotos() async {
    mealPhotoPaths.clear();

    final results = await ImageService.fetchMealPhotos();
    if (results != null) {
      // results: [ { "id": 1, "photo_path": "..." }, ... ]
      for (var item in results) {
        final path = item["photo_path"] ?? "";
        // 파일 존재 여부 확인
        if (path.isNotEmpty && File(path).existsSync()) {
          mealPhotoPaths.add(path);
        } else {
          // 파일이 없거나 경로가 비었을 경우 Log 출력 후 건너뜀
          Log.warning("해당 경로의 파일을 찾을 수 없습니다: $path");
        }
      }
      Log.info("식단 사진 불러오기 완료. 총 ${mealPhotoPaths.length}개");
    } else {
      Log.warning("식단 사진 조회 결과가 없습니다.");
    }
  }
}
