import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyPageController extends GetxController {
  // 사용자 이름
  final RxString name = "이현정".obs;

  // 사용자 프로필 이미지 URL (초기값 null)
  final RxnString profileImage = RxnString();

  // 총 운동 완료 일수
  final RxInt exerciseDays = 10.obs;

  get showDetails => null;

  // 데이터 초기화 (백엔드 연동 시 업데이트 가능)
  void initializeData({required String userName, String? userImage, required int totalDays}) {
    name.value = userName;
    profileImage.value = userImage;
    exerciseDays.value = totalDays;
  }
}
