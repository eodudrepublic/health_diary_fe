import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:health_diary_fe/view/home/widget/expandable_fab.dart';
import '../../common/app_colors.dart';
import '../../common/utils/logger.dart';
import '../../common/widget/custom_bottom_navigation_bar.dart';
import '../../view_model/home/home_controller.dart';

class HomeView extends StatelessWidget {
  final HomeController _homeController = Get.put(HomeController());

  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      // FAB 우측 하단 배치
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Padding(
                  // TODO: 앞으로 화면 좌우 여백 0.07.sw로 통일
                  padding: EdgeInsets.symmetric(horizontal: 0.07.sw),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height: 0.2.sh,
                        padding: EdgeInsets.symmetric(vertical: 0.065.sh),
                        alignment: Alignment.center,
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.symmetric(horizontal: 20.sp),
                          decoration: BoxDecoration(
                            color: AppColors.textBackgroundColor,
                            borderRadius: BorderRadius.circular(15.r),
                            border: Border.all(
                              color: AppColors.borderGreyColor,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            "플러스 버튼을 눌러 루틴을 만들어보세요",
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.textGreyColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const CustomBottomNavigationBar(
                homeIconPath: 'assets/icons/home_on.svg',
                calendarIconPath: 'assets/icons/calendar_off.svg',
                socialIconPath: 'assets/icons/group_off.svg',
                myPageIconPath: 'assets/icons/my_page_off.svg',
              ),
            ],
          ),
          Obx(() {
            // FAB가 열려 있을 때 오버레이 추가
            if (_homeController.isFabOpen.value) {
              return Positioned.fill(
                child: GestureDetector(
                  onTap: _homeController.closeFab,
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),

      // FAB 대신 ExpandableFab 위젯 사용
      floatingActionButton: ExpandableFab(),
    );
  }
}
