import 'package:get/get.dart';
import '../../common/utils/logger.dart';

class HomeController extends GetxController {
  // FAB의 열림/닫힘 상태
  final RxBool isFabOpen = false.obs;

  // FAB 상태 변경 메서드
  void toggleFab() {
    isFabOpen.value = !isFabOpen.value;
    Log.info("FAB 상태 변경 : ${isFabOpen.value}");
  }

  // FAB 닫기 메서드
  void closeFab() {
    if (isFabOpen.value) {
      isFabOpen.value = false;
      Log.info("FAB 닫힘");
    }
  }
}
