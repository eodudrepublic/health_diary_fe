import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../common/app_colors.dart';
import '../../common/widget/custom_bottom_navigation_bar.dart';
import '../../view_model/calendar/calendar_controller.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    final CalendarController controller = Get.put(CalendarController());

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// 상단 카테고리 탭바
          Container(
            height: 0.12.sh,
            alignment: Alignment.bottomCenter,
            // 탭바 UI
            child: Obx(() {
              return Stack(
                children: [
                  // 전체 선
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2.sp,
                      color: AppColors.textGreyColor,
                    ),
                  ),
                  // 탭바
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(controller.tabs.length, (index) {
                      final bool isSelected =
                          controller.selectedIndex.value == index;

                      return GestureDetector(
                        onTap: () {
                          controller.changeTab(index);
                        },
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              controller.tabs[index],
                              style: TextStyle(
                                fontSize: 20.sp,
                                // fontWeight: isSelected
                                //     ? FontWeight.bold
                                //     : FontWeight.normal,
                                color: isSelected
                                    ? AppColors.primaryColor2
                                    : Colors.white,
                              ),
                            ),
                            SizedBox(height: 5.sp),
                            if (isSelected)
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final text = controller.tabs[index];
                                  // 텍스트의 실제 길이 측정
                                  final textPainter = TextPainter(
                                    text: TextSpan(
                                      text: text,
                                      style: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    textDirection: TextDirection.ltr,
                                  )..layout();

                                  // 텍스트 길이 가져오기
                                  final textWidth = textPainter.size.width;

                                  return Container(
                                    height: 2.sp,
                                    width: textWidth + 2.sp, // 텍스트 길이에 맞춤
                                    color: AppColors.primaryColor2,
                                  );
                                },
                              ),
                          ],
                        ),
                      );
                    }),
                  ),
                ],
              );
            }),
          ),

          /// 탭바에 따른 화면 (일단 달력 화면)
          Container(
            width: 1.sw,
            constraints: BoxConstraints(
              minHeight: 1.sw,
            ),
            padding:
                EdgeInsets.symmetric(horizontal: 0.07.sw, vertical: 0.07.sw),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.borderGreyColor,
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Obx(() {
                return TableCalendar(
                  firstDay: DateTime(2023, 1, 1),
                  lastDay: DateTime(DateTime.now().year + 5, 12, 31),
                  focusedDay: controller.focusedDay.value,
                  selectedDayPredicate: (day) {
                    // 선택된 날짜인지 확인
                    return isSameDay(controller.selectedDate.value, day);
                  },
                  onDaySelected: (selectedDay, focusedDay_) {
                    // 날짜 선택 시
                    controller.onDaySelected(selectedDay, focusedDay_);
                  },
                  calendarFormat: CalendarFormat.month,

                  /// 헤더
                  daysOfWeekHeight: 30.sp,
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextFormatter: (date, locale) =>
                        '${date.year}년 ${date.month}월',
                    titleTextStyle: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    // leftChevronIcon: Icon(
                    //   Icons.chevron_left,
                    //   color: Colors.white,
                    // ),
                    // rightChevronIcon: Icon(
                    //   Icons.chevron_right,
                    //   color: Colors.white,
                    // ),
                  ),

                  /// 요일
                  daysOfWeekStyle: DaysOfWeekStyle(
                    dowTextFormatter: (date, locale) {
                      // 한국어 약식 요일 반환
                      const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
                      return weekdays[date.weekday % 7];
                    },
                  ),

                  calendarBuilders: CalendarBuilders(
                    /// 요일 스타일
                    dowBuilder: (context, day) {
                      final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
                      final text = weekdays[day.weekday % 7];
                      TextStyle style;

                      // 요일에 따른 텍스트 색상 설정
                      if (day.weekday == DateTime.sunday) {
                        style = TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        );
                      } else if (day.weekday == DateTime.saturday) {
                        style = TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        );
                      } else {
                        style = TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        );
                      }
                      return Center(
                        child: Text(
                          text,
                          style: style,
                        ),
                      );
                    },

                    /// 날짜 스타일
                    defaultBuilder: (context, day, focusedDay) {
                      TextStyle style = TextStyle(
                        color: Colors.white,
                      );

                      // 주말에 따른 텍스트 색상 설정
                      if (day.weekday == DateTime.sunday) {
                        style = TextStyle(
                          color: Colors.red,
                        );
                      } else if (day.weekday == DateTime.saturday) {
                        style = TextStyle(
                          color: Colors.blue,
                        );
                      }
                      return Center(
                        child: Text(
                          '${day.day}',
                          style: style,
                        ),
                      );
                    },

                    /// 오늘 스타일
                    todayBuilder: (context, day, focusedDay) {
                      return Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            color: AppColors.primaryColor1, // 오늘 날짜의 텍스트 색상
                          ),
                        ),
                      );
                    },

                    /// 선택된 날짜 스타일
                    selectedBuilder: (context, day, focusedDay) {
                      return Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            color: AppColors.primaryColor2, // 선택된 날짜의 텍스트 색상
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },

                    /// 마커 스타일
                    // TODO : 마커 적용해보고 스타일 수정 ㄱㄱ
                    markerBuilder: (context, date, events) {
                      if (controller.markedDates.contains(date)) {
                        return Positioned(
                          bottom: 1,
                          child: Container(
                            width: 6.sp,
                            height: 6.sp,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor2,
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  onPageChanged: (focusedDay_) {
                    // 월 변경 시 포커스된 날짜 업데이트
                    controller.onPageChanged(focusedDay_);
                  },
                );
              }),
            ),
          ),

          /// 하단 몸 상태 변화 확인 위젯들 들어갈 부분
          Expanded(
              child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 0.07.sw,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// 몸무게 변화
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "몸무게 변화",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 0.03.sw,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                          // TODO : 디자인 참고
                          ),
                    ),
                  ),

                  /// 골격근량
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "골격근량",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 0.03.sw,
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                          // TODO : 디자인 참고
                          ),
                    ),
                  ),

                  // TODO : 또 뭐 들어가야 했더라
                ],
              ),
            ),
          ))
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        homeIconPath: 'assets/icons/home_off.svg',
        calendarIconPath: 'assets/icons/calendar_on.svg',
        socialIconPath: 'assets/icons/group_off.svg',
        myPageIconPath: 'assets/icons/my_page_off.svg',
      ),
    );
  }
}
