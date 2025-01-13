import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:android_intent_plus/android_intent.dart';
import 'package:camera/camera.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;
import '../../common/utils/logger.dart';
import 'home_view.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({super.key, required this.cameras});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  late CameraController _controller; // 카메라 컨트롤러
  late Future<void> _initializeController; // 컨트롤러 초기화 Future
  String _currentDateTime = ''; // 화면에 표시할 현재 시간
  Timer? _timer; // 1초마다 시간 갱신
  int _currentCameraIndex = 0; // 전/후면 카메라 인덱스 추적

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 카메라 초기화
    _initCameraController(_currentCameraIndex);

    // 1초마다 현재 시간 갱신
    _updateDateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateDateTime();
    });
  }

  /// 생명주기 감지 - 화면 전환 등
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // 앱이 비활성화될 때 카메라 해제, 다시 돌아오면 재초기화
    if (_controller.value.isInitialized) {
      if (state == AppLifecycleState.inactive) {
        _controller.dispose();
      } else if (state == AppLifecycleState.resumed) {
        _initCameraController(_currentCameraIndex);
      }
    }
  }

  /// 특정 인덱스 카메라로 초기화 + 세로 고정
  Future<void> _initCameraController(int cameraIndex) async {
    if (widget.cameras.isEmpty) return;

    _controller = CameraController(
      widget.cameras[cameraIndex],
      ResolutionPreset.high,
      enableAudio: false,
    );
    // 세로 고정 (기본 방향)
    _controller.lockCaptureOrientation(DeviceOrientation.portraitUp);

    _initializeController = _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    }).catchError((e) {
      Log.error("카메라 초기화 에러: $e");
    });
  }

  /// 날짜 및 시간 갱신
  void _updateDateTime() {
    final now = DateTime.now();
    final formatted =
        "${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')} "
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    setState(() {
      _currentDateTime = formatted;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// 1) 저장소 권한 요청 로직 수정
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

  /// 2) 사진 촬영 -> 외부 저장소(Pictures/OurApp 폴더)에 저장 -> MediaScanner
  Future<void> _takePicture() async {
    try {
      // 카메라 초기화 대기
      await _initializeController;

      // 저장소 권한 요청
      final permissionStatus = await _requestStoragePermission();
      if (!permissionStatus) {
        Log.warning("저장소 접근 권한이 없습니다.");
        return;
      }

      // 사진 촬영
      final xFile = await _controller.takePicture();
      final dateTime = DateTime.now();
      final overlayText =
          "${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')} "
          "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";

      // 날짜/시간 오버레이 추가
      final editedImage = await _addDateTimeToImage(xFile.path, overlayText);

      // === 변경된 저장 로직: 외부 저장소/Public Pictures 폴더에 저장 ===
      // getExternalStorageDirectory() 는 /Android/data/ 패키지명 내부폴더이므로
      // 실제 갤러리에서 안 보일 수 있습니다.
      // 대신 getExternalStoragePublicDirectory 사용
      Directory extDir = Directory(
        "/storage/emulated/0/Pictures/OurApp", // 직접 경로 지정 (혹은 Environment.DIRECTORY_PICTURES)
      );

      // 폴더가 없으면 생성
      if (!extDir.existsSync()) {
        extDir.createSync(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = p.join(extDir.path, "photo_with_date_$timestamp.jpg");
      File(filePath).writeAsBytesSync(editedImage);

      // === 갤러리에 반영(스캐닝) ===
      if (Platform.isAndroid) {
        try {
          // 방법1) 안드로이드 명령어 am broadcast
          final result = await Process.run('am', [
            'broadcast',
            '-a',
            'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
            '-d',
            'file://$filePath'
          ]);
          Log.info("MediaScanner broadcast result: $result");
        } catch (e) {
          Log.error("MediaScanner failed: $e");
        }
      }

      Log.info("Image saved at $filePath");
    } catch (e) {
      Log.error("촬영 실패: $e");
    }
  }

  /// 이미지에 날짜/시간 오버레이
  Future<List<int>> _addDateTimeToImage(String imagePath, String text) async {
    // 파일 읽기
    final bytes = await File(imagePath).readAsBytes();
    final originalImg = img.decodeImage(bytes);

    if (originalImg == null) {
      throw Exception("이미지를 디코딩할 수 없습니다.");
    }

    // 텍스트 그리기
    img.drawString(
      originalImg,
      text,
      font: img.arial48, // 기본 Arial 폰트 사용 (큰 사이즈)
      x: 20, // X 좌표
      y: 20, // Y 좌표
      color: img.ColorFloat32.rgb(255, 255, 255), // 흰색 텍스트
    );

    // JPG 인코딩
    return img.encodeJpg(originalImg);
  }

  // iOS + 안드로이드 13 분기 처리를 위해 permission_handler + device_info_plus 사용
  // _requestStoragePermission(), _getAndroidSdkInt() 위쪽에서 이미 구현

  Future<void> _openGalleryApp() async {
    try {
      if (Platform.isAndroid) {
        final AndroidIntent intent = AndroidIntent(
          action: 'android.intent.action.VIEW',
          type: 'image/*',
          // 필요에 따라 특정 URI를 설정할 수 있습니다.
          // data: Uri.parse('content://media/internal/images/media'),
        );
        await intent.launch();
      } else if (Platform.isIOS) {
        // iOS에서는 Photos 앱을 직접 열 수 있는 방법이 없음
        // 대신, 이미지 선택기를 사용하여 사진 라이브러리를 엽니다.
        await _openImagePicker();
      } else {
        Log.warning("지원되지 않는 플랫폼입니다.");
      }
    } catch (e) {
      Log.error("갤러리 열기 에러: $e");
    }
  }

  /// iOS에서 갤러리를 여는 대체 방법 (이미지 선택기)
  Future<void> _openImagePicker() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        // 선택된 이미지를 처리할 수 있습니다.
        Log.info("선택된 이미지 경로: ${image.path}");
      }
    } catch (e) {
      Log.error("이미지 선택기 열기 에러: $e");
    }
  }

  /// 카메라 전환 (전면 <-> 후면)
  Future<void> _switchCamera() async {
    if (widget.cameras.length < 2) {
      Log.warning("사용 가능한 카메라가 한 대뿐이거나 없음");
      return;
    }
    _currentCameraIndex = (_currentCameraIndex + 1) % widget.cameras.length;

    // 기존 컨트롤러 해제 후 새 컨트롤러 초기화
    await _controller.dispose();
    _initCameraController(_currentCameraIndex);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("사진촬영", style: TextStyle(fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.offAll(() => HomeView()),
        ),
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeController,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              _controller.value.isInitialized) {
            final int sensorOrientation =
                widget.cameras[_currentCameraIndex].sensorOrientation;
            final double previewRotation = sensorOrientation * math.pi / 180;

            return Stack(
              children: [
                // 카메라 프리뷰
                Transform.rotate(
                  angle: previewRotation,
                  child: CameraPreview(_controller),
                ),

                // 날짜/시간 오버레이
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: Colors.black54,
                    child: Text(
                      _currentDateTime,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),

                // 하단 버튼들
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 갤러리 열기
                      IconButton(
                        icon: const Icon(Icons.photo_library,
                            size: 30, color: Colors.white),
                        onPressed: _openGalleryApp,
                      ),
                      const SizedBox(width: 40),

                      // 사진 촬영
                      FloatingActionButton(
                        backgroundColor: Colors.white,
                        onPressed: _takePicture,
                        child: const Icon(Icons.camera,
                            size: 28, color: Colors.black),
                      ),
                      const SizedBox(width: 40),

                      // 카메라 전환
                      IconButton(
                        icon: const Icon(Icons.loop,
                            size: 30, color: Colors.white),
                        onPressed: _switchCamera,
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            // 카메라 초기화 중인 경우 로딩 인디케이터 표시
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
