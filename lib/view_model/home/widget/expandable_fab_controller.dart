import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../../../common/utils/logger.dart';
import '../../../view/home/camera_test.dart';
import '../../../view/home/widget/expandable_fab.dart';

class ExpandableFabController extends GetxController {
  // 카메라 리스트를 저장하는 변수
  List<CameraDescription>? cameras;

  // 초기화
  @override
  void onInit() async {
    super.onInit();
    try {
      cameras = await availableCameras();
      if (cameras == null || cameras!.isEmpty) {
        Log.error("사용 가능한 카메라가 없습니다.");
      } else {
        Log.info("카메라 초기화 완료: ${cameras!.length}대의 카메라 사용 가능");
      }
    } catch (e) {
      Log.error("카메라 초기화 중 오류 발생: $e");
    }
  }

  // 사진 촬영 버튼 로직
  void onCameraTap() {
    Log.info("FAB : 오운완 촬영하기");
    if (cameras != null && cameras!.isNotEmpty) {
      Get.to(() => CameraScreen(camera: cameras!.first)); // 첫 번째 카메라를 사용
    } else {
      Log.error("사용 가능한 카메라가 없습니다.");
    }
  }

  // 루틴 만들기 버튼 로직
  void onCreateRoutineTap() {
    Log.info("FAB : 루틴 만들기");
    // TODO: 루틴 생성 화면으로 이동 로직 추가
  }

  // 식단 기록 버튼 로직
  void onRecordDietTap() {
    Log.info("FAB : 식단 기록하기");
    // TODO: 식단 기록 화면으로 이동 로직 추가
  }
}
