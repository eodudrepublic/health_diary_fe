import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import '../common/utils/logger.dart';

class AppUser {
  // 프라이빗 정적 인스턴스
  static final AppUser _instance = AppUser._internal();

  // 사용자 속성
  int? id;
  String? nickname;
  String? profileImageUrl;

  // 팩토리 생성자 - 동일한 인스턴스를 반환
  factory AppUser() {
    return _instance;
  }

  // 프라이빗 네임드 생성자
  AppUser._internal();

  // 사용자 데이터를 설정하는 메서드
  void setUser({
    required int id,
    String? nickname,
    String? profileImageUrl,
  }) {
    this.id = id;
    this.nickname = nickname;
    this.profileImageUrl = profileImageUrl;
    Log.trace(
        "AppUser 설정: id=$id, nickname=$nickname, profileImageUrl=$profileImageUrl");
  }

  // 사용자 데이터를 초기화하는 메서드
  void clearUser() {
    id = null;
    nickname = null;
    profileImageUrl = null;
    Log.info("AppUser 초기화됨");
  }

  // Kakao SDK의 User 객체를 AppUser로 변환하는 팩토리 생성자
  factory AppUser.fromKakaoUser(User kakaoUser) {
    Log.info("Kakao Socail Login :\n"
        "user_id : ${kakaoUser.id}\n"
        "nickname : ${kakaoUser.kakaoAccount?.profile?.nickname}\n"
        "profileImageUrl : ${kakaoUser.kakaoAccount?.profile?.profileImageUrl}");

    AppUser appUser = AppUser();
    appUser.setUser(
      id: kakaoUser.id,
      nickname: kakaoUser.kakaoAccount?.profile?.nickname,
      profileImageUrl: kakaoUser.kakaoAccount?.profile?.profileImageUrl,
    );
    return appUser;
  }
}
