import 'package:get/get.dart';

import '../../common/app_colors.dart';
import '../../model/theme_model.dart';

class ThemeController extends GetxController {
  // 현재 테마 (기본값: 다크)
  Rx<MyTheme> currentTheme = MyTheme.dark.obs;

  // 테마 변경 시 AppColors.backgroundColor 를 함께 교체해주는 함수
  void changeTheme(MyTheme theme) {
    currentTheme.value = theme;

    if (theme == MyTheme.light) {
      AppColors.backgroundColor = AppColors.lightBackgroundColor;
    } else {
      AppColors.backgroundColor = AppColors.darkBackgroundColor;
    }

    // TODO : 텍스트색도 변경해줘야 할듯?
  }
}
