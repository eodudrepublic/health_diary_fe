import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:health_diary_fe/common/app_colors.dart';
import '../../../common/utils/logger.dart';

/// 확장 가능한 FAB 위젯
class ExpandableFab extends StatefulWidget {
  final Function(bool)? onStateChange; // 상태 변경을 알리기 위한 콜백

  const ExpandableFab({super.key, this.onStateChange});

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  bool _isFabOpen = false;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  /// FAB 열기/닫기 상태 전환
  void _toggleFab() {
    setState(() {
      _isFabOpen = !_isFabOpen;
      if (_isFabOpen) {
        _fabAnimationController.forward();
      } else {
        _fabAnimationController.reverse();
      }
      // 부모에게 상태 변경 알리기
      if (widget.onStateChange != null) {
        widget.onStateChange!(_isFabOpen);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomRight, // FAB와 메뉴를 우측 하단에 정렬
      children: [
        // 메뉴 아이템
        if (_isFabOpen) ...[
          Padding(
            padding: EdgeInsets.only(
              bottom: 150.sp,
            ),
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
            onPressed: _toggleFab,
            child: AnimatedBuilder(
              animation: _fabAnimationController,
              builder: (context, child) {
                // 0~1 구간을 0~45도(≈0.785398 rad)로 회전
                return Transform.rotate(
                  angle: _fabAnimationController.value * 0.785398,
                  child: Icon(
                    Icons.add,
                    size: 30.sp,
                    color: AppColors.textGreyColor,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
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
        _toggleFab(); // 아이템 탭 후 FAB 닫기
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
