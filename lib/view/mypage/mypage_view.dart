import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../common/app_colors.dart';
import '../../view_model/mypage/mypage_controller.dart';
import '../../common/widget/custom_bottom_navigation_bar.dart';

class MyPageView extends StatelessWidget {
  final MyPageController _controller = Get.put(MyPageController());

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
              Row(
                children: [
                  Obx(() => CircleAvatar(
                    radius: 40.r,
                    backgroundColor: AppColors.borderGreyColor,
                    backgroundImage: _controller.profileImage.value != null
                        ? NetworkImage(_controller.profileImage.value!)
                        : null,
                    child: _controller.profileImage.value == null
                        ? Icon(Icons.person, size: 40.r, color: Colors.white)
                        : null,
                  )),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => Text(
                        _controller.name.value,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )),
                      Obx(() => Text(
                        "총 ${_controller.exerciseDays.value}일 운동 완료",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey,
                        ),
                      )),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              Section(title: "친구 관리", items: [
                "친구 추가",
                "내 QR 코드",
                "친구 목록",
              ]),
              SizedBox(height: 20.h),
              Section(title: "설정", items: [
                "테마",
                "앱 잠금 등록",
                "보이스",
              ]),
              SizedBox(height: 20.h),
              Section(title: "이용 규칙", items: [
                "이용 약관",
                "개인정보 처리 방침",
              ]),
              SizedBox(height: 20.h),
              Center(
                child: TextButton(
                  onPressed: () => print("로그아웃 클릭"),
                  child: Text(
                    "로그아웃",
                    style: TextStyle(fontSize: 16.sp, color: Colors.red),
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
}

class Section extends StatelessWidget {
  final String title;
  final List<String> items;

  const Section({required this.title, required this.items, Key? key}) : super(key: key);

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
              color: Colors.pink,
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
                .map((item) => ListTile(
              title: Text(
                item,
                style: TextStyle(fontSize: 14.sp, color: Colors.white),
              ),
              onTap: () => print("$item 클릭"),
            ))
                .toList(),
          ),
        ),
      ],
    );
  }
}
