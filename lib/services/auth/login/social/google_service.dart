import 'dart:io' show Platform;

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/screens/auth/join/join_screen.dart';
import 'package:hoho_hanja/screens/home/home_screen.dart';
import 'package:hoho_hanja/services/auth/login/social/email_check_service.dart';
import 'package:hoho_hanja/services/auth/my_goods_service.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';
import 'package:logger/logger.dart';

// google_sign_in 7.x: 싱글톤 + initialize()는 앱 실행 중 딱 한 번만 호출해야 함.
final GoogleSignIn googleSignIn = GoogleSignIn.instance;
Future<void>? _googleInit;

Future<void> _ensureGoogleInitialized() {
  return _googleInit ??= () async {
    // Android(Credential Manager)는 "웹 애플리케이션" OAuth 클라이언트 ID가 필수.
    // google-services.json 을 쓰지 않으므로 .env 의 GOOGLE_SERVER_CLIENT_ID 로 전달.
    final String serverClientId =
        dotenv.maybeGet('GOOGLE_SERVER_CLIENT_ID') ?? '';
    await googleSignIn.initialize(
      serverClientId: serverClientId.isEmpty ? null : serverClientId,
    );
  }()
      .catchError((Object e) {
    // 초기화 실패 시 다음 시도에서 다시 초기화하도록 초기화 상태를 비움.
    _googleInit = null;
    throw e;
  });
}

Future<void> googleLogin() async {
  if (Platform.isAndroid &&
      (dotenv.maybeGet('GOOGLE_SERVER_CLIENT_ID') ?? '').isEmpty) {
    Logger().e('GOOGLE_SERVER_CLIENT_ID 가 .env 에 없습니다.');
    failDialog("로그인 실패", "구글 로그인 설정이 완료되지 않았습니다.\n관리자에게 문의해주세요.");
    return;
  }

  try {
    await _ensureGoogleInitialized();

    // 구글 로그인 시도 (취소 시 GoogleSignInException(canceled) 발생)
    final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

    final String result = await emailCheckService(googleUser.email);
    // 연결 실패 등 확인 자체가 안 됐으면 가입 화면으로 보내지 않음 (안내창은 emailCheckService가 띄움)
    if (result != "0000" && result != "9999") return;
    if (result == '0000') {
      LoginData loginData = LoginData(
          id: googleUser.email, nickName: googleUser.displayName ?? "");
      final LoginDataController loginDataController =
          Get.put(LoginDataController(), permanent: true);
      loginDataController.setLoginData(loginData);

      await myGoodsService();
      // await loadProfileImage(loginDataController.loginData.value!.id);

      Get.offAll(() => const HomeScreen());
    } else {
      final JoinTextController joinController = Get.put(JoinTextController());
      joinController.emailController.text = googleUser.email;
      joinController.nickNameController.text = googleUser.displayName ?? '';
      Get.offAll(() => JoinScreen(method: "3"));
    }
  } on GoogleSignInException catch (e) {
    if (e.code == GoogleSignInExceptionCode.canceled) {
      // 사용자가 직접 취소 (설정 오류여도 canceled 로 올 수 있어 로그는 남김)
      Logger().w("구글 로그인 취소됨: ${e.description}");
      return;
    }
    Logger().e('구글 로그인 중 에러 발생: ${e.code} ${e.description}');
    failDialog("로그인 실패", "구글 로그인 중 문제가 발생했습니다. 잠시 후 다시 시도해주세요.");
  } catch (error) {
    Logger().e('구글 로그인 중 에러 발생: $error');
    failDialog("로그인 실패", "구글 로그인 중 문제가 발생했습니다. 잠시 후 다시 시도해주세요.");
  }
}

Future<void> googleLogout() async {
  await _ensureGoogleInitialized();
  await googleSignIn.signOut();
}

/// 구글 로그인 해제 (로그아웃: signOut, 탈퇴: disconnect). 구글로 로그인하지 않았거나 실패해도 조용히 넘어감.
Future<void> googleSignOut({bool disconnect = false}) async {
  try {
    await _ensureGoogleInitialized();
    disconnect ? await googleSignIn.disconnect() : await googleSignIn.signOut();
  } catch (e) {
    Logger().d('구글 로그아웃 건너뜀: $e');
  }
}
