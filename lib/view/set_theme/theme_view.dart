import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../common/app_colors.dart';
import '../../model/theme_model.dart';
import '../../view_model/set_theme/theme_controller.dart';

class ThemeView extends StatelessWidget {
  ThemeView({super.key});

  // ThemeController 주입
  final ThemeController _controller = Get.put(ThemeController());

  @override
  Widget build(BuildContext context) {
    // 상태 표시줄 높이를 가져오기
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Obx(
      () {
        // currentTheme 값에 따라 Stack 순서를 뒤집어서 배치
        final bool isDark = _controller.currentTheme.value == MyTheme.dark;

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

                /// 뒤로가기 버튼 + 제목
                Container(
                  height: 0.1.sh,
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    children: [
                      // 뒤로가기 아이콘
                      Container(
                        width: 80.sp,
                        height: 60.sp,
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () {
                            Get.back();
                          },
                          icon: Icon(Icons.arrow_back_rounded,
                              color: AppColors.textGreyColor, size: 30.sp),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 60.sp,
                        alignment: Alignment.center,
                        child: Text(
                          "테마 설정",
                          style: TextStyle(
                            color: AppColors.textGreyColor,
                            fontSize: 25.sp, // 텍스트 크기
                          ),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(width: 80.sp),
                    ],
                  ),
                ),

                // Stack 으로 카드 2개를 겹쳐서 배치
                SizedBox(height: 20.h),
                SizedBox(
                  height: 0.4.sh,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // 현재 테마가 dark 이면 dark 카드가 뒤로,
                      // 아니면 light 카드가 뒤로 깔림
                      Positioned(
                        top: 0,
                        child: isDark ? _darkThemeCard() : _lightThemeCard(),
                      ),

                      // 반대쪽 카드가 위로 오도록
                      Positioned(
                        top: 80.sp, // 살짝 아래로 내려서 겹치는 느낌
                        child: isDark ? _lightThemeCard() : _darkThemeCard(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 라이트 테마 카드 위젯
  Widget _lightThemeCard() {
    return GestureDetector(
      onTap: () {
        _controller.changeTheme(MyTheme.light);
      },
      child: Container(
        width: 0.86.sw,
        height: 0.23.sh,
        alignment: Alignment.topLeft,
        padding: EdgeInsets.all(15.sp),
        decoration: BoxDecoration(
          color: AppColors.lightThemeCardColdr,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/icons/sun.png", width: 40.sp, height: 40.sp),
            Padding(
              padding: EdgeInsets.only(left: 8.sp, right: 12.sp),
              child: Text(
                "Light",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              "라이트 테마",
              style: TextStyle(
                color: AppColors.textGreyColor,
                fontSize: 15.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 다크 테마 카드 위젯
  Widget _darkThemeCard() {
    return GestureDetector(
      onTap: () {
        _controller.changeTheme(MyTheme.dark);
      },
      child: Container(
        width: 0.86.sw,
        height: 0.23.sh,
        alignment: Alignment.topLeft,
        padding: EdgeInsets.all(15.sp),
        decoration: BoxDecoration(
          color: AppColors.textBackgroundColor,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/icons/moon.png", width: 40.sp, height: 40.sp),
            Padding(
              padding: EdgeInsets.only(left: 8.sp, right: 12.sp),
              child: Text(
                "Dark",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              "밤에도 눈이 편안해요",
              style: TextStyle(
                color: AppColors.textGreyColor,
                fontSize: 15.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
