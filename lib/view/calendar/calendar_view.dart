import 'dart:io';
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
                                    ? AppColors.primaryColor
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
                                    color: AppColors.primaryColor,
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

          /// 탭바에 따른 화면
          Expanded(
            // 내용이 많을 수 있으니 스크롤 가능
            child: Obx(() {
              // 현재 탭 인덱스에 따라 다른 화면 구성
              switch (controller.selectedIndex.value) {
                case 0:
                  // ─────────────────────────────────────────────────────────
                  // 운동 탭 (달력 + 하단 몸 상태 변화)
                  // ─────────────────────────────────────────────────────────
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // 달력 부분
                        _buildCalendarWidget(controller),

                        // 몸 상태 변화 부분
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 0.07.sw,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
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
                                child: Obx(() {
                                  final data = controller.bodyMetrics;
                                  if (data.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        "신체 기록이 없습니다.",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    );
                                  }

                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: data.map((item) {
                                        // 날짜 추출
                                        final recordDateStr =
                                            item["record_date"] ?? "";
                                        final recordDate =
                                            DateTime.tryParse(recordDateStr);

                                        // 월/일
                                        final displayDateString = recordDate !=
                                                null
                                            ? '${recordDate.month}/${recordDate.day}'
                                            : '-';

                                        // 몸무게
                                        final weight =
                                            (item["weight"] ?? "").toString();

                                        return Container(
                                          margin: EdgeInsets.only(right: 20.sp),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              // 동그라미 안에 몸무게 표시
                                              Container(
                                                width: 50.sp,
                                                height: 50.sp,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: AppColors.primaryColor,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    weight,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16.sp,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 5.sp),
                                              // 날짜 표시
                                              Text(
                                                displayDateString,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  );
                                }),
                              ),

                              SizedBox(height: 10.sp),

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
                                child: Obx(() {
                                  final data = controller.bodyMetrics;
                                  if (data.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        "신체 기록이 없습니다.",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    );
                                  }

                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: data.map((item) {
                                        final recordDateStr =
                                            item["record_date"] ?? "";
                                        final recordDate =
                                            DateTime.tryParse(recordDateStr);
                                        final displayDateString = recordDate !=
                                                null
                                            ? '${recordDate.month}/${recordDate.day}'
                                            : '-';

                                        // 골격근량
                                        final muscleMass =
                                            (item["muscle_mass"] ?? "")
                                                .toString();

                                        return Container(
                                          margin: EdgeInsets.only(right: 20.sp),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 50.sp,
                                                height: 50.sp,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: AppColors.primaryColor,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    muscleMass,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16.sp,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 5.sp),
                                              Text(
                                                displayDateString,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  );
                                }),
                              ),

                              SizedBox(height: 10.sp),

                              /// 체지방률
                              Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "체지방률",
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
                                child: Obx(() {
                                  final data = controller.bodyMetrics;
                                  if (data.isEmpty) {
                                    return const Center(
                                      child: Text(
                                        "신체 기록이 없습니다.",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    );
                                  }

                                  return SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: data.map((item) {
                                        final recordDateStr =
                                            item["record_date"] ?? "";
                                        final recordDate =
                                            DateTime.tryParse(recordDateStr);
                                        final displayDateString = recordDate !=
                                                null
                                            ? '${recordDate.month}/${recordDate.day}'
                                            : '-';

                                        // 체지방률
                                        final bodyFat =
                                            (item["body_fat_percentage"] ?? "")
                                                .toString();

                                        return Container(
                                          margin: EdgeInsets.only(right: 20.sp),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 50.sp,
                                                height: 50.sp,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: AppColors.primaryColor,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    bodyFat,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16.sp,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(height: 5.sp),
                                              Text(
                                                displayDateString,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16.sp,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );

                case 1:
                  // ─────────────────────────────────────────────────────────
                  // 오운완 탭 (오운완 사진 3열 그리드)
                  // ─────────────────────────────────────────────────────────
                  return _buildOwnPhotosGrid(controller);

                case 2:
                  // ─────────────────────────────────────────────────────────
                  // 식단 탭 (식단 사진 3열 그리드)
                  // ─────────────────────────────────────────────────────────
                  return _buildMealPhotosGrid(controller);

                default:
                  return const SizedBox.shrink();
              }
            }),
          ),
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

  /// 달력을 그리는 위젯
  Widget _buildCalendarWidget(CalendarController controller) {
    return Container(
      width: 1.sw,
      constraints: BoxConstraints(
        minHeight: 1.sw,
      ),
      padding: EdgeInsets.symmetric(horizontal: 0.07.sw, vertical: 0.07.sw),
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
              return isSameDay(controller.selectedDate.value, day);
            },
            onDaySelected: (selectedDay, focusedDay_) {
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
            ),

            /// 요일
            daysOfWeekStyle: DaysOfWeekStyle(
              dowTextFormatter: (date, locale) {
                const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
                return weekdays[date.weekday % 7];
              },
            ),

            calendarBuilders: CalendarBuilders(
              dowBuilder: (context, day) {
                final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
                final text = weekdays[day.weekday % 7];
                TextStyle style;

                // 요일에 따른 텍스트 색상 설정
                if (day.weekday == DateTime.sunday) {
                  style = const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  );
                } else if (day.weekday == DateTime.saturday) {
                  style = const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  );
                } else {
                  style = const TextStyle(
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

              /// 날짜 기본 스타일
              defaultBuilder: (context, day, focusedDay) {
                TextStyle style = const TextStyle(color: Colors.white);
                if (day.weekday == DateTime.sunday) {
                  style = const TextStyle(color: Colors.red);
                } else if (day.weekday == DateTime.saturday) {
                  style = const TextStyle(color: Colors.blue);
                }
                return Center(
                  child: Text(
                    '${day.day}',
                    style: style,
                  ),
                );
              },

              /// 오늘
              todayBuilder: (context, day, focusedDay) {
                return Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                );
              },

              /// 선택된 날짜
              selectedBuilder: (context, day, focusedDay) {
                return Center(
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },

              /// 마커
              markerBuilder: (context, date, events) {
                final isMarked = controller.markedDates
                    .any((markedDate) => isSameDay(markedDate, date));
                if (isMarked) {
                  return Positioned(
                    bottom: 1,
                    child: Container(
                      width: 6.sp,
                      height: 6.sp,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
            onPageChanged: (focusedDay_) {
              // 월 변경 시 포커스된 날짜 업데이트
              controller.onPageChanged(focusedDay_);
            },
          );
        }),
      ),
    );
  }

  /// [오운완] 탭에서 3열 그리드로 사진 표시
  Widget _buildOwnPhotosGrid(CalendarController controller) {
    return Obx(() {
      // 컨트롤러에 저장된 오운완 사진 경로 리스트 사용
      final photos = controller.ownPhotoPaths;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.05.sw, vertical: 0.02.sh),
        child: photos.isEmpty
            ? const Center(
                child: Text(
                  "오운완 사진이 없습니다.",
                  style: TextStyle(color: Colors.white),
                ),
              )
            : GridView.builder(
                shrinkWrap: true, // 스크롤뷰 안에 있으므로 true
                physics: const BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3열
                  crossAxisSpacing: 8.sp,
                  mainAxisSpacing: 8.sp,
                ),
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  final filePath = photos[index];
                  return Image.file(
                    File(filePath),
                    fit: BoxFit.cover,
                  );
                },
              ),
      );
    });
  }

  /// [식단] 탭에서 3열 그리드로 사진 표시
  Widget _buildMealPhotosGrid(CalendarController controller) {
    return Obx(() {
      // 컨트롤러에 저장된 식단 사진 경로 리스트 사용
      final photos = controller.mealPhotoPaths;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.05.sw, vertical: 0.02.sh),
        child: photos.isEmpty
            ? const Center(
                child: Text(
                  "식단 사진이 없습니다.",
                  style: TextStyle(color: Colors.white),
                ),
              )
            : GridView.builder(
                shrinkWrap: true, // 스크롤뷰 안에 있으므로 true
                physics: const BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3열
                  crossAxisSpacing: 8.sp,
                  mainAxisSpacing: 8.sp,
                ),
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  final filePath = photos[index];
                  return Image.file(
                    File(filePath),
                    fit: BoxFit.cover,
                  );
                },
              ),
      );
    });
  }
}
