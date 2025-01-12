import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../app_colors.dart';
import '../utils/logger.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final String homeIconPath;
  final String calendarIconPath;
  final String socialIconPath;
  final String myPageIconPath;

  const CustomBottomNavigationBar({
    super.key,
    required this.homeIconPath,
    required this.calendarIconPath,
    required this.socialIconPath,
    required this.myPageIconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65.sp,
      color: AppColors.backgroundColor,
      alignment: Alignment.topCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildIconButton(
            iconPath: homeIconPath,
            iconSize: 30.sp,
            onPressed: () {
              Log.info("BNB :  Home 버튼 터치 -> HomeView");
              Get.offNamed('/home');
            },
          ),
          _buildIconButton(
            iconPath: calendarIconPath,
            iconSize: 30.sp,
            onPressed: () {
              Log.info("BNB :  Calendar 버튼 터치 -> CalendarView");
              Get.offNamed('/calendar');
            },
          ),
          _buildIconButton(
            iconPath: socialIconPath,
            iconSize: 25.sp,
            onPressed: () {
              Log.info("BNB :  Group 버튼 터치 -> GroupView");
              Get.offNamed('/social');
            },
          ),
          _buildIconButton(
            iconPath: myPageIconPath,
            iconSize: 30.sp,
            onPressed: () {
              Log.info("BNB :  MyPage 버튼 터치 -> MyPageView");
              Get.offNamed('/mypage');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required String iconPath,
    required double iconSize,
    VoidCallback? onPressed,
  }) {
    return IconButton(
      icon: SvgPicture.asset(
        iconPath,
        width: iconSize,
        height: iconSize,
      ),
      onPressed: onPressed,
    );
  }
}
