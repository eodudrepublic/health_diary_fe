import 'dart:async';
import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import '../../common/utils/logger.dart';
import '../../model/camera_model.dart';
import '../../service/image_service.dart';

/// GetX를 활용한 카메라 제어 컨트롤러.
/// 카메라 초기화, 전/후면 카메라 전환, 사진 촬영 및 저장, 오버레이 추가 등의 작업을 처리합니다.
class MyCameraController extends GetxController with WidgetsBindingObserver {
  final List<CameraDescription> cameras; // 사용 가능한 카메라 목록
  late CameraController _cameraController; // 카메라 컨트롤러 인스턴스
  late Future<void> _initializeController; // 카메라 초기화 작업의 Future
  final currentDateTime = ''.obs; // 화면에 표시할 현재 날짜 및 시간
  final isInitialized = false.obs; // 카메라 초기화 상태
  final currentCameraIndex = 0.obs; // 현재 사용 중인 카메라의 인덱스
  // TODO : photoList로 사진 목록 보여줄 수 있을까?
  final photoList = <CameraModel>[].obs; // 촬영된 사진 리스트를 관리하는 Observable

  // 카메라 컨트롤러 접근을 위한 getter
  CameraController get cameraController => _cameraController;

  Timer? _timer; // 일정 주기로 현재 시간을 갱신하기 위한 타이머

  MyCameraController({required this.cameras});

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this); // 라이프사이클 관찰자 등록
    _initializeCamera(); // 사용 가능한 카메라 초기화
    _updateDateTime(); // 현재 날짜 및 시간 업데이트
    _timer = Timer.periodic(
        const Duration(seconds: 1), (_) => _updateDateTime()); // 1초마다 시간 갱신
  }

  @override
  void onClose() {
    _timer?.cancel(); // 타이머 해제
    WidgetsBinding.instance.removeObserver(this); // 라이프사이클 관찰자 해제
    _disposeCameraController(); // 카메라 컨트롤러 해제
    super.onClose();
  }

  /// 앱 라이프사이클 상태 변화 감지
  // TODO : 이거 이해해야함
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    Log.info("AppLifecycleState changed to: $state");

    switch (state) {
      case AppLifecycleState.inactive:
        Log.info("App is inactive. Disposing camera controller.");
        _disposeCameraController().then((_) {
          Log.info("Camera controller disposed successfully.");
        }).catchError((e) {
          Log.error("Error disposing camera controller: $e");
        });
        break;

      case AppLifecycleState.paused:
        Log.info("App is paused. Disposing camera controller.");
        _disposeCameraController().then((_) {
          Log.info("Camera controller disposed successfully.");
        }).catchError((e) {
          Log.error("Error disposing camera controller: $e");
        });
        break;

      case AppLifecycleState.resumed:
        Log.info("App is resumed. Initializing camera controller.");
        _initializeCamera().then((_) {
          Log.info("Camera controller initialized successfully.");
        }).catchError((e) {
          Log.error("Error initializing camera controller: $e");
        });
        break;

      case AppLifecycleState.detached:
        Log.info("App is detached.");
        break;

      default:
        Log.warning("Unhandled AppLifecycleState: $state");
        break;
    }
  }

  /// 카메라 컨트롤러를 안전하게 해제
  Future<void> _disposeCameraController() async {
    try {
      await _cameraController.dispose();
      isInitialized.value = false;
      Log.info("카메라 컨트롤러 해제됨.");
    } catch (e) {
      Log.error("카메라 컨트롤러 해제 오류: $e");
    }
  }

  /// 사용 가능한 카메라를 초기화하고 기본 카메라를 설정합니다.
  Future<void> _initializeCamera() async {
    if (cameras.isEmpty) {
      Log.error("사용 가능한 카메라가 없습니다.");
      return;
    }
    await _initCameraController(currentCameraIndex.value); // 기본 카메라를 초기화
  }

  /// 특정 인덱스의 카메라를 설정하고 초기화합니다.
  Future<void> _initCameraController(int index) async {
    try {
      _cameraController = CameraController(
        cameras[index], // 선택한 카메라
        ResolutionPreset.high, // 고화질 설정
        enableAudio: false, // 오디오 비활성화
      );
      _cameraController
          .lockCaptureOrientation(DeviceOrientation.portraitUp); // 세로 고정
      _initializeController = _cameraController.initialize().then((_) {
        isInitialized.value = true; // 초기화 완료 상태 설정
        Log.info("카메라 초기화 완료: ${cameras[index].lensDirection}");
      }).catchError((e) {
        Log.error("카메라 초기화 오류: $e"); // 초기화 오류 로그
      });
    } catch (e) {
      Log.error("카메라 컨트롤러 설정 오류: $e");
    }
  }

  /// 전/후면 카메라를 전환합니다.
  Future<void> switchCamera() async {
    if (cameras.length < 2) {
      Log.warning("전환할 수 있는 카메라가 충분하지 않습니다.");
      return; // 카메라가 두 개 미만일 경우 전환 불가
    }
    final newIndex =
        (currentCameraIndex.value + 1) % cameras.length; // 인덱스 업데이트
    currentCameraIndex.value = newIndex;
    await _disposeCameraController(); // 기존 카메라 해제
    await _initCameraController(newIndex); // 새로운 카메라 초기화
  }

  /// 사진을 촬영하고, 오버레이를 추가한 후 저장합니다.
  Future<void> takePicture(String category) async {
    if (!isInitialized.value) {
      Log.warning("카메라가 초기화되지 않았습니다.");
      return;
    }
    final permissionGranted = await _requestStoragePermission(); // 저장소 권한 요청
    if (!permissionGranted) {
      Log.warning("저장소 권한이 거부되었습니다.");
      return; // 권한 거부 시 종료
    }

    try {
      // 1) 사진 촬영
      final xFile = await _cameraController.takePicture(); // 사진 촬영
      final timestamp = DateTime.now(); // 현재 시간
      final overlayText = currentDateTime.value; // 날짜/시간 오버레이 텍스트

      // 2) 오버레이 추가
      final editedImage =
          await _addDateTimeToImage(xFile.path, overlayText); // 이미지에 오버레이 추가

      // 3) 이미지 파일 저장
      final filePath = await _saveImage(editedImage, category); // 수정된 이미지를 저장

      // 4) CameraModel 생성 및 리스트에 추가
      final model = CameraModel(imagePath: filePath, timestamp: timestamp);
      photoList.add(model);

      Log.info("사진이 저장되고 리스트에 추가되었습니다: $filePath");

      // 5) 저장 후 서버 업로드 (category에 따라 다른 엔드포인트 호출)
      if (category == "오운완") {
        Log.info("[오운완] 사진 업로드를 시작합니다...");
        await ImageService.uploadOwnPhoto(filePath);
      } else if (category == "식단기록") {
        Log.info("[식단기록] 사진 업로드를 시작합니다...");
        await ImageService.uploadMealPhoto(filePath);
      } else {
        Log.warning("알 수 없는 카테고리입니다. 업로드를 진행하지 않습니다.");
      }
    } catch (e) {
      Log.error("사진 촬영 실패: $e");
    }
  }

  /// 캡처된 사진을 저장하기 위한 저장소 권한 요청.
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      final sdkInt = await _getAndroidSdkInt();

      // 안드로이드 13(API 33) 이상
      if (sdkInt >= 33) {
        // 이미지 권한만 필요하다면 Permission.photos (permission_handler 10.x+)
        final statuses = await [Permission.photos].request();

        bool granted = false;
        for (var status in statuses.values) {
          if (status.isGranted) {
            granted = true;
          }
        }
        return granted;
      }
      // 안드로이드 12 이하
      else {
        final statuses = await [
          Permission.storage,
        ].request();

        bool granted = false;
        for (var status in statuses.values) {
          if (status.isGranted) {
            granted = true;
          }
        }
        return granted;
      }
    } else if (Platform.isIOS) {
      // iOS의 경우 Permission.photos 또는 Permission.photosAddOnly
      final statuses = await [Permission.photos].request();
      bool granted = false;
      for (var status in statuses.values) {
        if (status.isGranted) {
          granted = true;
        }
      }
      return granted;
    } else {
      // 기타 플랫폼(웹, 데스크톱 등)은 별도 처리
      return true;
    }
  }

  Future<int> _getAndroidSdkInt() async {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    return androidInfo.version.sdkInt;
  }

  /// 캡처된 사진에 날짜/시간 오버레이 추가.
  Future<List<int>> _addDateTimeToImage(String imagePath, String text) async {
    final bytes = await File(imagePath).readAsBytes(); // 이미지 파일 읽기
    final originalImg = img.decodeImage(bytes); // 이미지 디코딩

    if (originalImg == null) throw Exception("이미지를 디코딩할 수 없습니다.");

    img.drawString(
      originalImg,
      text, // 오버레이 텍스트
      font: img.arial48, // 폰트 및 크기
      x: 20, // 텍스트의 X 오프셋
      y: 20, // 텍스트의 Y 오프셋
      // TODO : 사진 배경에 따라 텍스트 색상 변경해주는 기능 추가
      color: img.ColorFloat32.rgb(255, 255, 255), // 흰색 텍스트 색상
    );
    return img.encodeJpg(originalImg); // 이미지를 JPG 형식으로 다시 인코딩
  }

  /// 편집된 이미지를 디바이스 저장소에 저장 후 파일 경로 반환
  Future<String> _saveImage(List<int> imageBytes, String category) async {
    // TODO : OurApp -> 앱 이름으로 변경
    final extDir =
        Directory("/storage/emulated/0/Pictures/OurApp/$category"); // 저장 경로
    if (!extDir.existsSync()) {
      extDir.createSync(recursive: true); // 디렉토리가 없으면 생성
    }

    final filePath = p.join(
        extDir.path, "photo_${DateTime.now().millisecondsSinceEpoch}.jpg");
    File(filePath).writeAsBytesSync(imageBytes); // 이미지를 저장
    // TODO : 사진 저장 후 갤러리 갱신
    return filePath;
  }

  /// 디바이스 갤러리를 엽니다.
  Future<void> openGallery() async {
    try {
      if (Platform.isAndroid) {
        // 안드로이드 갤러리 열기
        final intent = AndroidIntent(
          action: 'android.intent.action.VIEW',
          type: 'image/*',
        );
        await intent.launch();
      } else if (Platform.isIOS) {
        // iOS에서는 이미지 선택기를 대신 사용
        final picker = ImagePicker();
        final XFile? image =
            await picker.pickImage(source: ImageSource.gallery);
        if (image != null) {
          Log.info("선택된 이미지 경로: ${image.path}");
        }
      } else {
        Log.warning("갤러리를 열 수 없는 플랫폼입니다.");
      }
    } catch (e) {
      Log.error("갤러리 열기 에러: $e");
    }
  }

  /// 날짜 및 시간 갱신
  void _updateDateTime() {
    final now = DateTime.now();
    currentDateTime.value =
        "${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')} "
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }
}
