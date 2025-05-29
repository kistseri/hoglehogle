import 'package:get/get.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/screens/auth/join/join_screen.dart';
import 'package:hoho_hanja/screens/home/home_screen.dart';
import 'package:hoho_hanja/services/auth/login/social/email_check_service.dart';
import 'package:hoho_hanja/services/auth/my_goods_service.dart';
import 'package:hoho_hanja/utils/load_profile_image.dart';
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

    String result = await emailCheckService(credential.email ?? '');
    if (result == "0000") {
      Logger().d(credential.userIdentifier);
      LoginData loginData = LoginData(
          id: credential.email ?? '', nickName: credential.givenName ?? '');
      final LoginDataController loginDataController =
          Get.put(LoginDataController(), permanent: true);
      loginDataController.setLoginData(loginData);

      await myGoodsService();
      await loadProfileImage(loginDataController.loginData.value!.id);

      Get.offAll(() => const HomeScreen());
    } else {
      final joinController = Get.put(JoinTextController());
      joinController.emailController.text = credential.email ?? '';
      joinController.nickNameController.text = credential.givenName ?? '';

      Get.offAll(() => JoinScreen(method: "4"));
    }
  } catch (error) {
    Logger().e("Apple 로그인 실패: $error");
  }
}
