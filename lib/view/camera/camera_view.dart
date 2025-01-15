import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:health_diary_fe/common/app_colors.dart';
import '../../view_model/camera/camera_controller.dart';

class CameraView extends StatelessWidget {
  final String imageTitle; // 화면 제목

  const CameraView({super.key, required this.imageTitle});

  @override
  Widget build(BuildContext context) {
    // MyCameraController 인스턴스를 찾음
    final controller = Get.find<MyCameraController>();

    return Obx(() {
      // 카메라가 초기화되지 않은 경우 로딩 화면 표시
      if (!controller.isInitialized.value) {
        return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator()),
        );
      }

      // 현재 카메라의 센서 회전값 계산
      final sensorOrientation = controller
          .cameras[controller.currentCameraIndex.value].sensorOrientation;
      final previewRotation = sensorOrientation * 3.14159265359 / 180;

      return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Stack(
          children: [
            /// 카메라 프리뷰 표시 (회전값 적용)
            Positioned.fill(
              child: Transform.rotate(
                angle: previewRotation, // 회전 적용
                child: CameraPreview(controller.cameraController),
              ),
            ),

            /// 화면 상단 뒤로가기 버튼 + 제목
            Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  alignment: Alignment.bottomCenter,
                  height: (0.5.sh - 0.5.sw) - 70.sp,
                  child: Row(
                    children: [
                      // 뒤로가기 아이콘
                      Container(
                        width: 80.sp,
                        height: 60.sp,
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          onPressed: () {
                            Get.back();
                          },
                          icon: Icon(Icons.arrow_back_rounded,
                              color: AppColors.textGreyColor, size: 40.sp),
                        ),
                      ),
                      Spacer(),
                      Container(
                        height: 60.sp,
                        alignment: Alignment.center,
                        child: Text(
                          imageTitle,
                          style: TextStyle(
                            color: AppColors.textGreyColor,
                            fontSize: 35.sp, // 텍스트 크기
                          ),
                        ),
                      ),
                      Spacer(),
                      SizedBox(
                        width: 80.sp,
                      )
                    ],
                  ),
                )),

            /// 카메라 미리보기 좌측상단에 날짜 및 시간 오버레이
            Positioned(
              top: (0.5.sh - 0.5.sw) + 16,
              left: 16,
              child: Text(
                controller.currentDateTime.value,
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),

            /// 하단 버튼: 갤러리 열기, 카메라 전환 및 사진 촬영
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 갤러리 열기 버튼
                  IconButton(
                    icon: SvgPicture.asset(
                      "assets/icons/gallery.svg",
                      width: 40.sp,
                      height: 40.sp,
                    ),
                    onPressed: controller.openGallery, // 갤러리 열기 함수 호출
                  ),
                  // 사진 촬영 버튼
                  IconButton(
                    icon: SvgPicture.asset(
                      "assets/icons/shutter.svg",
                      width: 70.sp,
                      height: 70.sp,
                    ),
                    onPressed: () => controller.takePicture(imageTitle),
                  ),
                  // 전/후면 카메라 전환 버튼
                  IconButton(
                    icon: SvgPicture.asset(
                      "assets/icons/switch.svg",
                      width: 40.sp,
                      height: 40.sp,
                    ),
                    onPressed: controller.switchCamera,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
