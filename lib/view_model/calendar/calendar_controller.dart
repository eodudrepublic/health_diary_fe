import 'package:get/get.dart';

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

  // 탭 선택 메서드
  void changeTab(int index) {
    selectedIndex.value = index;
  }

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
}
