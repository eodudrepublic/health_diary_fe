import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_diary_fe/view/home/widget/expandable_fab.dart';
import '../../common/app_colors.dart';
import '../../common/utils/logger.dart';
import '../../common/widget/custom_bottom_navigation_bar.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _isFabOpen = false;

  /// FAB 상태 변경을 위한 콜백 함수
  void _onFabStateChanged(bool isOpen) {
    Log.info("_onFabStateChanged called : $isOpen");
    setState(() {
      _isFabOpen = isOpen;
    });
  }

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
                groupIconPath: 'assets/icons/group_off.svg',
                myPageIconPath: 'assets/icons/my_page_off.svg',
              ),
            ],
          ),
          // FAB가 열려 있을 때 오버레이 추가
          if (_isFabOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  // TODO : 현재 아래의 _onFabStateChanged가 FAB에 영향을 주지 못함. 함수가 호출되어 "_onFabStateChanged called : false"가 나와도 FAB가 닫히지 않음
                  // 외부를 탭하면 FAB 닫기
                  _onFabStateChanged(false);
                },
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
        ],
      ),

      // FAB 대신 ExpandableFab 위젯 사용
      floatingActionButton: ExpandableFab(
        onStateChange: _onFabStateChanged,
      ),
    );
  }
}
