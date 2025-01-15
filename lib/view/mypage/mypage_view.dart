import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import '../../common/app_colors.dart';
import '../../common/server_url.dart';
import '../../common/utils/logger.dart';
import '../../common/widget/custom_bottom_navigation_bar.dart';
import '../../view_model/mypage/mypage_controller.dart';

class MyPageView extends StatelessWidget {
  final MyPageController _controller = Get.put(MyPageController());

  MyPageView({super.key}) {
    // 프로필 데이터 로드
    _controller.loadUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0.07.sw, vertical: 0.05.sh),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 프로필 사진
                  Obx(() => CircleAvatar(
                        radius: 40.r,
                        backgroundColor: AppColors.borderGreyColor,
                        backgroundImage: _controller.profileImage.value != null
                            ? NetworkImage(_controller.profileImage.value!)
                            : null,
                        child: _controller.profileImage.value == null
                            ? Icon(Icons.person,
                                size: 40.r, color: Colors.white)
                            : null,
                      )),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 닉네임
                      Obx(() => Text(
                            _controller.name.value.isNotEmpty
                                ? _controller.name.value
                                : "닉네임을 불러오는 중...",
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )),
                      // 운동 완료 일수
                      Obx(
                        () => Text(
                          "총 ${_controller.exerciseDays.value}일 운동 완료",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              // 친구 관리 섹션
              Section(
                title: "친구 관리",
                items: [
                  SectionItem(
                    title: "친구 추가",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QRCodeScannerScreen(
                          onScanned: (scannedUserId) {
                            _controller.addFriendFromQrCode(scannedUserId);
                          },
                        ),
                      ),
                    ),
                  ),
                  SectionItem(
                    title: "내 QR 코드",
                    onTap: () => showAddFriendDialog(
                        context, _controller.userId.toString()), // QR 코드 모달 호출
                  ),
                  SectionItem(
                    title: "친구 목록",
                    onTap: () => _showFriendListModal(
                        context, _controller.userId.toString()), // 친구 목록 모달 호출
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              // 설정 섹션
              Section(
                title: "설정",
                items: [
                  SectionItem(
                      title: "테마",
                      onTap: () {
                        Log.info("테마 클릭");
                        Get.toNamed('/set_theme');
                      }),
                  SectionItem(
                      title: "앱 잠금 등록", onTap: () => Log.info("앱 잠금 클릭")),
                  SectionItem(title: "보이스", onTap: () => Log.info("보이스 클릭")),
                ],
              ),
              SizedBox(height: 20.h),
              // 이용 규칙 섹션
              Section(
                title: "이용 규칙",
                items: [
                  SectionItem(
                    title: "이용 약관",
                    onTap: () {
                      _showTermsModal(context, "이용 약관",
                          "김대영은 신이야. 자세한 내용은 앱 관리자를 통해 확인하세요.");
                    },
                  ),
                  SectionItem(
                    title: "개인정보 처리 방침",
                    onTap: () {
                      _showTermsModal(context, "개인정보 처리 방침",
                          "아 힘들엉. 사용자의 데이터는 안전하게 보호됩니다.");
                    },
                  ),
                ],
              ),

              SizedBox(height: 20.h),
              // 로그아웃 버튼
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Log.info("로그아웃 클릭"),
                  child: Text(
                    "로그아웃",
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(
        homeIconPath: 'assets/icons/home_off.svg',
        calendarIconPath: 'assets/icons/calendar_off.svg',
        socialIconPath: 'assets/icons/group_off.svg',
        myPageIconPath: 'assets/icons/my_page_on.svg',
      ),
    );
  }

  // 내 QR 코드 다이얼로그
  void showAddFriendDialog(BuildContext context, String userId) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          // backgroundColor: Colors.white,
          backgroundColor: Color(0xFF1A1A1A),
          title: const Text(
            '내 QR 코드',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: Column(
              mainAxisSize: MainAxisSize.min, // 자식 위젯 크기만큼만 크기 설정
              children: [
                const Text(
                  '아래 QR 코드를 스캔하여 친구를 추가하세요.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF777777)),
                ),
                const SizedBox(height: 16.0),
                // QrImageView(
                //   data: jsonEncode({"user_id": userId}), // QR 코드 데이터
                //   version: QrVersions.auto, // QR 코드 버전 자동
                //   size: 200.0, // QR 코드 크기
                // ),
                QrImageView(
                  data: jsonEncode({"user_id": userId}), // QR 코드 데이터
                  version: QrVersions.auto, // QR 코드 버전 자동
                  size: 200.0, // QR 코드 크기
                  foregroundColor: Colors.white, // QR 코드 색상 (흰색)
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                '닫기',
                style: TextStyle(color: Color(0xFFEE1171)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

void _showFriendListModal(BuildContext context, String userId) async {
  try {
    final friends = await fetchFriends(userId);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: 400.h,
          margin: EdgeInsets.all(20.r),
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: AppColors.textBackgroundColor,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "친구 목록",
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: friends.isEmpty
                    ? Center(
                        child: Text(
                          "친구가 없습니다.",
                          style:
                              TextStyle(fontSize: 14.sp, color: Colors.white),
                        ),
                      )
                    : ListView.builder(
                        itemCount: friends.length,
                        itemBuilder: (context, index) {
                          final friend = friends[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: friend['profile_image'] != null
                                  ? NetworkImage(friend['profile_image'])
                                  : null,
                              child: friend['profile_image'] == null
                                  ? const Icon(Icons.person)
                                  : null,
                            ),
                            title: Text(
                              friend['nickname'] ?? "Unknown",
                              style: TextStyle(
                                  fontSize: 14.sp, color: Colors.white),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  } catch (e) {
    // 오류 처리
    Log.info("Error displaying friend list: $e");
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color(0xFF1A1A1A),
          title: const Text(
            '친구 목록',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          content: const Text(
            "친구가 없습니다.",
            style: TextStyle(color: Color(0xFF777777)), // 흰색 텍스트 스타일 추가
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                '닫기',
                style: TextStyle(color: Color(0xFFEE1171)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

Future<List<Map<String, dynamic>>> fetchFriends(String userId) async {
  final String apiUrl = "$serverUrl:8000/users/$userId/friends";
  try {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((friend) => friend as Map<String, dynamic>).toList();
    } else {
      Log.info("Failed to load friends: ${response.statusCode}");
      throw Exception("Failed to load friends");
    }
  } catch (e) {
    Log.info("Error fetching friends: $e");
    throw Exception("Error fetching friends");
  }
}

class QRCodeScannerScreen extends StatelessWidget {
  final Function(String) onScanned;

  QRCodeScannerScreen({required this.onScanned});

  @override
  Widget build(BuildContext context) {
    final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

    // 첨부된 이미지에서 색상을 추출한 뒤 사용
    final Color appBarBackgroundColor =
        Color(0xFF1A1A1A); // 임의의 색상 (검정색에 가까운 색)

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "QR 코드 스캔",
          style: TextStyle(color: Colors.white), // 텍스트 색상을 흰색으로 설정
        ),
        backgroundColor: appBarBackgroundColor, // 배경색 설정
        iconTheme: const IconThemeData(color: Colors.white), // 뒤로 가기 아이콘 색상
      ),
      body: QRView(
        key: qrKey,
        onQRViewCreated: (controller) {
          controller.scannedDataStream.listen((scanData) {
            onScanned(scanData.code ?? "");
            controller.dispose();
            Navigator.pop(context);
          });
        },
      ),
    );
  }
}

// 공통 섹션 위젯
class Section extends StatelessWidget {
  final String title;
  final List<SectionItem> items;

  const Section({required this.title, required this.items, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderGreyColor),
            borderRadius: BorderRadius.circular(8.r),
            color: AppColors.textBackgroundColor,
          ),
          child: Column(
            children: items
                .asMap()
                .entries
                .map(
                  (entry) => Column(
                    children: [
                      ListTile(
                        title: Text(
                          entry.value.title,
                          style:
                              TextStyle(fontSize: 14.sp, color: Colors.white),
                        ),
                        onTap: entry.value.onTap,
                      ),
                      if (entry.key != items.length - 1)
                        Divider(color: Colors.grey, thickness: 1),
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

// 섹션 아이템
class SectionItem {
  final String title;
  final VoidCallback onTap;

  SectionItem({required this.title, required this.onTap});
}

// 이용 약관 모달창
void _showTermsModal(BuildContext context, String title, String content) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: AppColors.textBackgroundColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                content,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 20.h),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    "닫기",
                    style: TextStyle(
                        fontSize: 16.sp, color: AppColors.primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
