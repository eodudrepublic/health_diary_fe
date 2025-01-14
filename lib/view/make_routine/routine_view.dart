import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/app_colors.dart';
import '../../common/widget/custom_bottom_navigation_bar.dart';

class RoutineView extends StatefulWidget {
  const RoutineView({super.key});

  @override
  State<RoutineView> createState() => _RoutineViewState();
}

class _RoutineViewState extends State<RoutineView> {
  @override
  Widget build(BuildContext context) {
    // 상태 표시줄 높이를 가져오기
    final double statusBarHeight = MediaQuery.of(context).padding.top;

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
              // TODO : 여기에 검색창
            ),
            Expanded(
              child: ListView(
                children: [
                  // TODO : 여기에 "$serverUrl:8000/exercises"에서 받아온 운동 리스트를 표시
                ],
              ),
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
