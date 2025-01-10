import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import '../common/utils/logger.dart';

class KakaoLoginApi {
  /// 카카오 로그인 메서드
  Future<User?> signWithKakao() async {
    final UserApi api = UserApi.instance;
    try {
      if (await isKakaoTalkInstalled()) {
        // 카카오톡으로 로그인 시도
        try {
          await UserApi.instance.loginWithKakaoTalk();
        } catch (error) {
          Log.error('카카오톡으로 로그인 실패: $error');
          // 카카오톡으로 로그인 실패 시 카카오 계정으로 로그인 시도
          if (error is PlatformException && error.code == 'CANCELED') {
            // 사용자가 로그인 시도를 취소한 경우
            Log.error('사용자가 로그인 시도를 취소했습니다.');
            return null;
          }
          await UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        Log.warning('카카오톡이 설치되어 있지 않습니다. -> 카카오 계정으로 로그인');
        // 카카오톡이 설치되어 있지 않으면 카카오 계정으로 로그인
        await UserApi.instance.loginWithKakaoAccount();
      }
      Log.info('카카오톡으로 로그인 성공');
      // 로그인 성공 후 사용자 정보 가져오기
      return await api.me();
    } catch (error) {
      Log.error('카카오톡으로 로그인 실패: $error');
      return null;
    }
  }

  /// 카카오 로그아웃 메서드
  Future<void> logout() async {
    try {
      await UserApi.instance.logout();
      Log.info('카카오 로그아웃 성공');
    } catch (error) {
      Log.error('카카오 로그아웃 실패: $error');
      rethrow; // 에러를 호출자에게 전달하여 추가 처리를 가능하게 함
    }
  }
}
