import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/app_colors.dart';
import '../../common/widget/custom_bottom_navigation_bar.dart';

class MyPageView extends StatelessWidget {
  MyPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.07.sw, vertical: 0.05.sh),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 프로필 섹션
              Row(
                children: [
                  CircleAvatar(
                    radius: 40.r,
                    backgroundColor: AppColors.borderGreyColor,
                    backgroundImage: null, // 프로필 이미지는 null로 기본 설정
                    child: Icon(Icons.person, size: 40.r, color: Colors.white),
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "이현정", // 닉네임
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        "총 10일 운동 완료", // 운동 완료 정보
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              // 친구 관리 섹션
              Section(
                title: "친구 관리",
                items: [
                  SectionItem(title: "친구 추가", onTap: () => print("친구 추가 클릭")),
                  SectionItem(
                    title: "내 QR 코드",
                    onTap: () => _showQrCodeModal(context), // QR 코드 모달 호출
                  ),
                  SectionItem(
                    title: "친구 목록",
                    onTap: () => _showFriendListModal(context), // 친구 목록 모달 호출
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              // 설정 섹션
              Section(
                title: "설정",
                items: [
                  SectionItem(title: "테마", onTap: () => print("테마 클릭")),
                  SectionItem(title: "앱 잠금 등록", onTap: () => print("앱 잠금 클릭")),
                  SectionItem(title: "보이스", onTap: () => print("보이스 클릭")),
                ],
              ),
              SizedBox(height: 20.h),
              // 이용 규칙 섹션
              Section(
                title: "이용 규칙",
                items: [
                  SectionItem(title: "이용 약관", onTap: () => print("이용 약관 클릭")),
                  SectionItem(
                      title: "개인정보 처리 방침",
                      onTap: () => print("개인정보 처리 방침 클릭")),
                ],
              ),
              SizedBox(height: 20.h),
              // 로그아웃 버튼
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => print("로그아웃 클릭"),
                  child: Text(
                    "로그아웃",
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        homeIconPath: 'assets/icons/home_off.svg',
        calendarIconPath: 'assets/icons/calendar_off.svg',
        socialIconPath: 'assets/icons/group_off.svg',
        myPageIconPath: 'assets/icons/my_page_on.svg',
      ),
    );
  }

  // QR 코드 모달
  void _showQrCodeModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: 300.h,
          margin: EdgeInsets.all(20.r),
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: AppColors.textBackgroundColor,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "내 QR 코드",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20.h),
              Container(
                width: 150.w,
                height: 150.w,
                color: Colors.white, // 임시 QR 코드 배경색
                child: Center(
                  child: Text(
                    "QR CODE",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                "QR 코드를 스캔하여 친구를 추가하세요",
                style: TextStyle(fontSize: 14.sp, color: Colors.grey),
              ),
            ],
          ),
        );
      },
    );
  }

  // 친구 목록 모달
  void _showFriendListModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: 400.h,
          margin: EdgeInsets.all(20.r),
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: AppColors.textBackgroundColor,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "친구 목록",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: ListView.builder(
                  itemCount: 10, // 예제 데이터: 10명의 친구
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        "친구 $index",
                        style: TextStyle(fontSize: 14.sp, color: Colors.white),
                      ),
                      onTap: () => print("친구 $index 클릭"),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// 공통 섹션 위젯
class Section extends StatelessWidget {
  final String title;
  final List<SectionItem> items;

  const Section({required this.title, required this.items, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderGreyColor),
            borderRadius: BorderRadius.circular(8.r),
            color: AppColors.textBackgroundColor,
          ),
          child: Column(
            children: items
                .asMap()
                .entries
                .map(
                  (entry) => Column(
                children: [
                  ListTile(
                    title: Text(
                      entry.value.title,
                      style:
                      TextStyle(fontSize: 14.sp, color: Colors.white),
                    ),
                    onTap: entry.value.onTap,
                  ),
                  if (entry.key != items.length - 1)
                    Divider(color: Colors.grey, thickness: 1),
                ],
              ),
            )
                .toList(),
          ),
        ),
      ],
    );
  }
}

// 섹션 아이템
class SectionItem {
  final String title;
  final VoidCallback onTap;

  SectionItem({required this.title, required this.onTap});
}
