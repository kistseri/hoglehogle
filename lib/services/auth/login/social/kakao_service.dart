import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/screens/auth/join/join_screen.dart';
import 'package:hoho_hanja/screens/home/home_screen.dart';
import 'package:hoho_hanja/services/auth/login/social/email_check_service.dart';
import 'package:hoho_hanja/services/auth/my_goods_service.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:logger/logger.dart';

Future<void> kakaoLogin() async {
  try {
    // 카카오톡이 설치돼 있으면 카카오톡으로, 실패하면 카카오계정 로그인으로 전환.
    if (await isKakaoTalkInstalled()) {
      try {
        await UserApi.instance.loginWithKakaoTalk();
      } catch (error) {
        // 사용자가 직접 취소한 경우에는 계정 로그인으로 넘어가지 않고 종료.
        if (error is PlatformException && error.code == 'CANCELED') {
          return;
        }
        // 카카오톡 로그인 실패(미설치 상태 변화, 계정 연결 안 됨 등) → 계정 로그인으로 전환.
        await UserApi.instance.loginWithKakaoAccount(prompts: [Prompt.login]);
      }
    } else {
      await UserApi.instance.loginWithKakaoAccount(prompts: [Prompt.login]);
    }

    await _handleKakaoUser();
  } catch (error) {
    if (error is PlatformException && error.code == 'CANCELED') {
      return;
    }
    Logger().e('카카오 로그인 중 에러 발생: $error');
    failDialog("로그인 실패", "카카오 로그인 중 문제가 발생했습니다. 잠시 후 다시 시도해주세요.");
  }
}

// 로그인 토큰을 받은 뒤 사용자 정보로 로그인/가입 분기 처리
Future<void> _handleKakaoUser() async {
  final User data = await UserApi.instance.me();

  final String? email = data.kakaoAccount?.email;

  // 이메일 제공에 동의하지 않았거나 받지 못한 경우: 빈 이메일로 진행하지 않고 안내.
  if (email == null || email.isEmpty) {
    failDialog(
      "이메일 동의 필요",
      "카카오 로그인 시 이메일 제공에 동의해야 이용할 수 있습니다.\n카카오 계정 설정에서 이메일 제공에 동의한 뒤 다시 시도해주세요.",
    );
    return;
  }

  // 이름 권한이 없거나 닉네임이 없을 수 있으므로 null 안전 처리 + 기본값.
  final String nickName =
      data.kakaoAccount?.name ?? data.kakaoAccount?.profile?.nickname ?? '';

  final String result = await emailCheckService(email);

  if (result == "0000") {
    final loginData = LoginData(id: email, nickName: nickName);
    final loginDataController = Get.put(LoginDataController(), permanent: true);
    loginDataController.setLoginData(loginData);

    await myGoodsService();

    Get.offAll(() => const HomeScreen());
  } else {
    final joinController = Get.put(JoinTextController());
    joinController.emailController.text = email;
    joinController.nickNameController.text = nickName;

    Get.offAll(() => JoinScreen(method: "2"));
  }
}

Future<void> kakaoLogout() async {
  await UserApi.instance.unlink();
}

/// 카카오 로그인 해제 (로그아웃: logout, 탈퇴: unlink). 카카오로 로그인하지 않았거나 실패해도 조용히 넘어감.
Future<void> kakaoSignOut({bool unlink = false}) async {
  try {
    unlink ? await UserApi.instance.unlink() : await UserApi.instance.logout();
  } catch (e) {
    Logger().d('카카오 로그아웃 건너뜀: $e');
  }
}
