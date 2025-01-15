import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../common/app_colors.dart';
import '../../common/widget/custom_bottom_navigation_bar.dart';
import '../../view_model/social/social_controller.dart';

class SocialView extends GetView<SocialController> {
  const SocialView({super.key});

  @override
  Widget build(BuildContext context) {
    // 컨트롤러 등록
    final SocialController _controller = Get.put(SocialController());

    // 상태 표시줄 높이를 가져오기
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // 상태 표시줄 높이만큼 간격
          SizedBox(height: statusBarHeight),

          /// + 버튼 (오운완 사진 BottomSheet 띄우기)
          Container(
            height: 0.04.sh + 0.14.sw,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.symmetric(horizontal: 0.07.sw),
            child: SizedBox(
              width: 0.04.sh,
              height: 0.04.sh,
              child: ElevatedButton(
                onPressed: () {
                  // 1) BottomSheet 보여주기 전, 내가 올린 오운완 사진 목록 가져오기
                  _controller.fetchOwnPhotosForSheet().then((_) {
                    // 2) BottomSheet 띄우기
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.black54,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(15.r),
                        ),
                      ),
                      builder: (_) {
                        return Obx(() {
                          final photos = _controller.ownPhotos;
                          if (photos.isEmpty) {
                            return SizedBox(
                              height: 0.5.sh,
                              child: const Center(
                                child: Text(
                                  "오운완 사진이 없습니다.",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                          }
                          return SizedBox(
                            height: 0.5.sh,
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.sp),
                                  child: Text(
                                    "내 오운완 사진 선택",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GridView.builder(
                                    physics: const BouncingScrollPhysics(),
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3, // 3열
                                      crossAxisSpacing: 8.sp,
                                      mainAxisSpacing: 8.sp,
                                    ),
                                    itemCount: photos.length,
                                    itemBuilder: (context, index) {
                                      final photo = photos[index];
                                      final photoId = photo["id"];
                                      final path = photo["photo_path"] ?? "";

                                      // 로컬 경로라고 가정
                                      Widget imageWidget;
                                      if (path.isNotEmpty &&
                                          File(path).existsSync()) {
                                        imageWidget = Image.file(
                                          File(path),
                                          fit: BoxFit.cover,
                                        );
                                      } else {
                                        // 파일이 없으면 대체 위젯
                                        imageWidget = Container(
                                          color: Colors.grey,
                                          child: Center(
                                            child: Text(
                                              "No file",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12.sp,
                                              ),
                                            ),
                                          ),
                                        );
                                      }

                                      return GestureDetector(
                                        onTap: () async {
                                          // 선택한 사진을 SNS에 업로드
                                          await _controller
                                              .uploadSocialPhoto(photoId);
                                          // 업로드 완료 후 BottomSheet 닫기
                                          Navigator.pop(context);
                                        },
                                        child: imageWidget,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        });
                      },
                    );
                  });
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
                ),
              ),
            ),
          ),

          /// 소셜 사진들 불러와서 표시할 수 있는 부분
          Expanded(
            child: Obx(() {
              final photos = _controller.socialPhotos;
              if (photos.isEmpty) {
                return const Center(
                  child: Text(
                    "SNS에 업로드된 사진이 없습니다.",
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }

              // CalendarView의 _buildOwnPhotosGrid와 유사하게, 로컬 파일 경로로 가정
              return Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: 0.05.sw, vertical: 0.02.sh),
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3열
                    crossAxisSpacing: 8.sp,
                    mainAxisSpacing: 8.sp,
                  ),
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final item = photos[index];
                    final path = item["photo_path"] ?? "";

                    // 로컬 경로라고 가정
                    if (path.isNotEmpty && File(path).existsSync()) {
                      return Image.file(
                        File(path),
                        fit: BoxFit.cover,
                      );
                    } else {
                      // 파일이 없거나 존재하지 않을 시 대체 컨테이너
                      return Container(
                        color: Colors.grey,
                        child: const Center(
                          child: Text(
                            "No file",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }
                  },
                ),
              );
            }),
          ),
        ],
      ),

      /// 하단 네비게이션 바
      bottomNavigationBar: const CustomBottomNavigationBar(
        homeIconPath: 'assets/icons/home_off.svg',
        calendarIconPath: 'assets/icons/calendar_off.svg',
        socialIconPath: 'assets/icons/group_on.svg',
        myPageIconPath: 'assets/icons/my_page_off.svg',
      ),
    );
  }
}
