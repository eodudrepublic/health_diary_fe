import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:get/get.dart';
import '../../common/utils/logger.dart';
import 'home_view.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({super.key, required this.camera});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  String _currentDateTime = '';
  Timer? _timer;
  int rotation = 0; // 회전 상태

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _controller.initialize();

    // 초기 날짜와 시간 설정
    _updateDateTime();

    // 1초마다 날짜와 시간을 업데이트
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateDateTime());
  }

  void _updateDateTime() {
    final now = DateTime.now();
    final formattedDateTime =
        "${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')} "
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    setState(() {
      _currentDateTime = formattedDateTime;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;

      final image = await _controller.takePicture();
      final dateTime = DateTime.now();
      final overlayText =
          "${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')} "
          "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}";

      final editedImage = await _addDateTimeToImage(image.path, overlayText);

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/photo_with_date_$timestamp.jpg';
      File(filePath).writeAsBytesSync(editedImage);

      Log.info("Image saved at $filePath");
    } catch (e) {
      Log.error(e);
    }
  }

  Future<List<int>> _addDateTimeToImage(String imagePath, String text) async {
    // 이미지 파일 읽기
    final imageBytes = await File(imagePath).readAsBytes();
    final image = img.decodeImage(imageBytes)!;

    img.drawString(
      image,
      text,
      font: img.arial48,
      x: 20,
      y: 20,
      color: img.ColorFloat32.rgb(255, 255, 255),
    );
    Log.trace(
        "_addDateTimeToImage called -> 이미지 경로 : $imagePath, 넣을 텍스트 : $text");

    // JPG로 인코딩 후 반환
    return img.encodeJpg(image);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          "사진촬영",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Get.offAll(() => HomeView()); // 뒤로가기 버튼 동작
          },
        ),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                // 카메라 미리보기
                Center(
                  child: Transform.rotate(
                    angle: 90 * 3.1415926535 / 180,
                    child: AspectRatio(
                      //aspectRatio: _controller.value.aspectRatio,
                      aspectRatio: 1,
                      child: CameraPreview(_controller),
                    ),
                  ),
                ),
                // 날짜 및 시간 오버레이 (카메라 미리보기 위에 표시)
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: Colors.black54,
                    child: Text(
                      _currentDateTime,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
                // 하단 버튼 (사진 촬영, 갤러리, 카메라 전환)
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.photo_library, size: 30, color: Colors.white),
                        onPressed: () {
                          Log.info("Open gallery");
                        },
                      ),
                      const SizedBox(width: 40),
                      FloatingActionButton(
                        backgroundColor: Colors.white,
                        onPressed: _takePicture,
                        child: const Icon(Icons.camera, size: 28, color: Colors.black),
                      ),
                      const SizedBox(width: 40),
                      IconButton(
                        icon: const Icon(Icons.loop, size: 30, color: Colors.white),
                        onPressed: () {
                          Log.info("Switch camera");
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      backgroundColor: Colors.black,
    );
  }
}
