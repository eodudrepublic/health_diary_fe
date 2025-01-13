import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:health_diary_fe/view/calendar/calendar_view.dart';
import 'package:health_diary_fe/view/home/camera_test.dart';
import 'package:health_diary_fe/view/home/home_view.dart';
import 'package:health_diary_fe/view/login/login_view.dart';
import 'package:health_diary_fe/view/mypage/mypage_view.dart';
import 'package:health_diary_fe/view/social/social_view.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'common/key.dart';
import 'common/utils/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 화면 세로 모드로 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // KakaoSdk 초기화
  KakaoSdk.init(nativeAppKey: myNativeAppKey);
  Log.wtf("KakaoSdk initialized : ${await KakaoSdk.origin} -> 이게 왜 키 해쉬예요 ㅅㅂ");

  // 카메라 초기화 (전/후면 카메라만 필터링)
  List<CameraDescription> filteredCameras = [];
  try {
    final allCameras = await availableCameras();
    filteredCameras = allCameras
        .where((camera) =>
            camera.lensDirection == CameraLensDirection.front ||
            camera.lensDirection == CameraLensDirection.back)
        .toList();

    if (filteredCameras.isNotEmpty) {
      Log.info("카메라 필터링 완료: ${filteredCameras.length}개 카메라");
    } else {
      Log.warning("사용 가능한 전/후면 카메라가 없습니다.");
    }
  } catch (e) {
    Log.error("카메라 초기화 중 오류 발생: $e");
  }

  runApp(MyApp(cameras: filteredCameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(400, 860),
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Health Diary',
          home: cameras.isNotEmpty
              ? CameraScreen(cameras: cameras)
              : const Scaffold(
                  body: Center(child: Text('사용 가능한 카메라가 없습니다.')),
                ),
          getPages: [
            /// 로그인
            GetPage(name: '/login', page: () => LoginView()),

            /// 메인 탭 1 : 홈
            GetPage(name: '/home', page: () => HomeView()),

            /// 메인 탭 2 : 달력
            GetPage(name: '/calendar', page: () => CalendarView()),

            /// 메인 탭 3 : 소셜
            GetPage(name: '/social', page: () => SocialView()),

            /// 메인 탭 4 : 마이페이지
            GetPage(name: '/mypage', page: () => MyPageView()),
          ],
        );
      },
    );
  }
}
