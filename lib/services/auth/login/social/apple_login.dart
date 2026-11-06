import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/screens/auth/join/join_screen.dart';
import 'package:hoho_hanja/screens/home/home_screen.dart';
import 'package:hoho_hanja/services/auth/login/social/email_check_service.dart';
import 'package:hoho_hanja/services/auth/my_goods_service.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';
import 'package:logger/logger.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

// 애플 로그인
Future<void> appleLogin() async {
  try {
    // Apple 로그인 요청
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    // Apple 은 이메일/이름을 "최초 로그인 1회"에만 내려준다.
    // 두 번째 로그인부터는 credential.email 이 null 이므로 identityToken(JWT)의 email 클레임으로 보완.
    final String email = credential.email ??
        _emailFromIdentityToken(credential.identityToken) ??
        '';
    final String nickName = credential.givenName ?? '';

    if (email.isEmpty) {
      Logger().e("Apple 로그인: 이메일을 가져오지 못함 (${credential.userIdentifier})");
      failDialog("로그인 실패",
          "Apple 계정 이메일을 확인할 수 없습니다.\n다른 로그인 방법을 이용하시거나 잠시 후 다시 시도해주세요.");
      return;
    }

    String result = await emailCheckService(email);
    // 연결 실패 등 확인 자체가 안 됐으면 가입 화면으로 보내지 않음 (안내창은 emailCheckService가 띄움)
    if (result != "0000" && result != "9999") return;
    if (result == "0000") {
      Logger().d(credential.userIdentifier);
      LoginData loginData = LoginData(id: email, nickName: nickName);
      final LoginDataController loginDataController =
          Get.put(LoginDataController(), permanent: true);
      loginDataController.setLoginData(loginData);

      await myGoodsService();
      // await loadProfileImage(loginDataController.loginData.value!.id);

      Get.offAll(() => const HomeScreen());
    } else {
      final joinController = Get.put(JoinTextController());
      joinController.emailController.text = email;
      joinController.nickNameController.text = nickName;

      Get.offAll(() => JoinScreen(method: "4"));
    }
  } on SignInWithAppleAuthorizationException catch (e) {
    // 사용자가 직접 취소한 경우는 조용히 종료
    if (e.code == AuthorizationErrorCode.canceled) return;
    Logger().e("Apple 로그인 실패: ${e.code} ${e.message}");
    failDialog("로그인 실패", "Apple 로그인 중 문제가 발생했습니다. 잠시 후 다시 시도해주세요.");
  } on PlatformException catch (e) {
    Logger().e("Apple 로그인 실패: $e");
    failDialog("로그인 실패", "Apple 로그인 중 문제가 발생했습니다. 잠시 후 다시 시도해주세요.");
  } catch (error) {
    Logger().e("Apple 로그인 실패: $error");
    failDialog("로그인 실패", "Apple 로그인 중 문제가 발생했습니다. 잠시 후 다시 시도해주세요.");
  }
}

// identityToken(JWT) payload 에서 email 클레임 추출 (서명 검증은 하지 않음 — 서버 검증 필요 시 별도 처리)
String? _emailFromIdentityToken(String? identityToken) {
  if (identityToken == null) return null;
  try {
    final parts = identityToken.split('.');
    if (parts.length != 3) return null;
    final payload =
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    final email = (jsonDecode(payload) as Map<String, dynamic>)['email'];
    return email is String && email.isNotEmpty ? email : null;
  } catch (e) {
    Logger().w("identityToken 파싱 실패: $e");
    return null;
  }
}
