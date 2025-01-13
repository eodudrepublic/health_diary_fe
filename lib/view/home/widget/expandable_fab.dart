import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:health_diary_fe/common/app_colors.dart';
import '../../../common/utils/logger.dart';
import '../../../view_model/home/home_controller.dart';

/// 확장 가능한 FAB 위젯
// TODO : 다음엔 flutter_expandable_fab 패키지를 사용해보자
class ExpandableFab extends StatelessWidget {
  final HomeController _homeController = Get.find<HomeController>();

  ExpandableFab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomRight,
        children: [
          // 메뉴 아이템
          if (_homeController.isFabOpen.value) ...[
            Padding(
              padding: EdgeInsets.only(bottom: 150.sp),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildFabItem(
                    iconPath: 'assets/icons/camera.png',
                    label: "사진 촬영",
                    onTap: () {
                      Log.info("FAB : 사진 촬영");
                      // TODO: 사진 촬영 로직
                    },
                  ),
                  SizedBox(height: 20.sp),
                  _buildFabItem(
                    iconPath: 'assets/icons/routine.png',
                    label: "루틴 만들기",
                    onTap: () {
                      Log.info("FAB : 루틴 만들기");
                      // TODO: 루틴 만들기 로직
                    },
                  ),
                  SizedBox(height: 20.sp),
                  _buildFabItem(
                    iconPath: 'assets/icons/diet.png',
                    label: "식단 기록 하기",
                    onTap: () {
                      Log.info("FAB : 식단 기록 하기");
                      // TODO: 식단 기록 로직
                    },
                  ),
                ],
              ),
            ),
          ],
          // FAB 본체
          Container(
            width: 60.sp,
            height: 60.sp,
            margin: EdgeInsets.only(bottom: 70.sp),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.borderGreyColor,
                width: 2.sp,
              ),
            ),
            child: FloatingActionButton(
              shape: const CircleBorder(),
              backgroundColor: AppColors.textBackgroundColor,
              elevation: 0,
              highlightElevation: 0,
              onPressed: _homeController.toggleFab,
              // 0~1 구간을 0~45도(≈0.785398 rad)로 회전
              child: Transform.rotate(
                angle: _homeController.isFabOpen.value ? 0.785398 : 0,
                child: Icon(
                  Icons.add,
                  size: 30.sp,
                  color: AppColors.textGreyColor,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  /// FAB으로 펼칠 개별 아이템 빌더
  Widget _buildFabItem({
    required String iconPath,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        onTap();
        _homeController.toggleFab(); // 아이템 탭 후 FAB 닫기
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 아이템 레이블
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              label,
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
            ),
          ),

          const SizedBox(width: 8),

          /// 아이콘 버튼
          Container(
            width: 60.sp,
            height: 60.sp,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: AppColors.primaryColor2),
            child: Image.asset(
              iconPath,
              width: 35.sp,
              height: 35.sp,
            ),
          ),
        ],
      ),
    );
  }
}
