import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/app_colors.dart';
import '../../common/widget/custom_bottom_navigation_bar.dart';

class SocialView extends StatelessWidget {
  const SocialView({super.key});

  @override
  Widget build(BuildContext context) {
    // 상태 표시줄 높이를 가져오기
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // 상태 표시줄 높이만큼 간격을 주기
          SizedBox(height: statusBarHeight),

          /// 오운완 사진 추가
          Container(
            height: 0.04.sh + 0.14.sw,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.symmetric(horizontal: 0.07.sw),
            child: SizedBox(
              width: 0.04.sh,
              height: 0.04.sh,
              child: ElevatedButton(
                  onPressed: () {
                    // TODO : 갤러리에서 오운완 사진 찾아서 올릴 수 있도록 기능 구현
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: EdgeInsets.zero,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.r),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.add,
                      color: AppColors.backgroundColor,
                      size: 20.sp,
                    ),
                  )),
            ),
          ),

          /// 소셜 사진들 불러와서 표시할 수 있는 부분
          // TODO : 서버에서 오운완 사진들 불러와서, 아마 GridView?로 표시하도록 구현
          Expanded(child: Container())
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        homeIconPath: 'assets/icons/home_off.svg',
        calendarIconPath: 'assets/icons/calendar_off.svg',
        socialIconPath: 'assets/icons/group_on.svg',
        myPageIconPath: 'assets/icons/my_page_off.svg',
      ),
    );
  }
}
