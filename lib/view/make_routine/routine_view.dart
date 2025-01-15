import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../common/app_colors.dart';
import '../../common/widget/custom_bottom_navigation_bar.dart';
import '../../view_model/make_routine/routine_controller.dart';

class RoutineView extends StatefulWidget {
  const RoutineView({super.key});

  @override
  State<RoutineView> createState() => _RoutineViewState();
}

class _RoutineViewState extends State<RoutineView> {
  // GetX Controller 주입
  final RoutineController routineController = Get.put(RoutineController());

  @override
  Widget build(BuildContext context) {
    // 상태 표시줄 높이를 가져오기
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    // TODO : 텍스트 폰트 사이즈 지정
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 0.07.sw),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: statusBarHeight),

            Container(
              height: 0.1.sh,
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  /// 뒤로가기 버튼
                  IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: Icon(Icons.arrow_back_rounded,
                        color: AppColors.textGreyColor, size: 40.sp),
                  ),

                  /// 검색창
                  Expanded(
                    child: TextField(
                      onChanged: routineController.updateSearchQuery,
                      style: TextStyle(color: AppColors.textGreyColor),
                      cursorColor: AppColors.textGreyColor,
                      decoration: InputDecoration(
                        hintText: '검색',
                        hintStyle: TextStyle(color: AppColors.textGreyColor),
                        prefixIcon:
                            Icon(Icons.search, color: AppColors.textGreyColor),
                        fillColor: AppColors.textBackgroundColor,
                        filled: true,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.borderGreyColor,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.borderGreyColor,
                          ),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// 운동 리스트
            Expanded(
              child: Obx(() {
                final exercises = routineController.filteredExercises;

                return ListView.builder(
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];

                    return Obx(() {
                      final isSelected = routineController.selectedExerciseIds
                          .contains(exercise['id']);
                      return ListTile(
                        onTap: () {
                          routineController
                              .toggleExerciseSelection(exercise['id']);
                        },
                        title: Text(
                          exercise['name'] ?? '',
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primaryColor
                                : Colors.white,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          exercise['target_area'] ?? '',
                          style: TextStyle(color: AppColors.textGreyColor),
                        ),
                      );
                    });
                  },
                );
              }),
            ),

            /// 선택된 운동이 있다면 '루틴 만들러 가기' 버튼 노출
            Obx(
              () => routineController.selectedExerciseIds.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        // 루틴을 만드는 로직 대신 우선 콘솔 출력
                        routineController.printSelectedExercises();
                        // TODO : 서버에 루틴 저장 -> 엔드포인트 완성되면 작업 ㄱㄱ
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: 14.h,
                        ),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: const Text(
                          '루틴 만들러 가기',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        homeIconPath: 'assets/icons/home_on.svg',
        calendarIconPath: 'assets/icons/calendar_off.svg',
        socialIconPath: 'assets/icons/group_off.svg',
        myPageIconPath: 'assets/icons/my_page_off.svg',
      ),
    );
  }
}
