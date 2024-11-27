import 'package:get/get.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/screens/auth/join/join_screen.dart';
import 'package:hoho_hanja/screens/home/home_screen.dart';
import 'package:hoho_hanja/services/auth/login/social/email_check_service.dart';
import 'package:hoho_hanja/services/auth/my_goods_service.dart';
import 'package:hoho_hanja/utils/load_profile_image.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:logger/logger.dart';

Future<void> kakaoLogin() async {
  try {
    final joinController = Get.put(JoinTextController());
    // 카카오 계정으로 로그인 시도
    if (await isKakaoTalkInstalled()) {
      await UserApi.instance.loginWithKakaoTalk();

      final data = await UserApi.instance.me();

      String result = await emailCheckService(data.kakaoAccount!.email ?? '');
      if (result == "0000") {
        LoginData loginData = LoginData(
            id: data.kakaoAccount!.email ?? '',
            nickName: data.kakaoAccount!.name ?? '');
        final LoginDataController loginDataController =
            Get.put(LoginDataController(), permanent: true);
        loginDataController.setLoginData(loginData);

        await myGoodsService();
        await loadProfileImage(loginDataController.loginData.value!.id);

        Get.offAll(() => const HomeScreen());
      } else {
        joinController.emailController.text = data.kakaoAccount!.email ?? '';
        joinController.nickNameController.text =
            data.kakaoAccount!.profile!.nickname ?? '';

        Get.offAll(() => JoinScreen(method: "2"));
      }
    } else {
      await UserApi.instance.loginWithKakaoAccount(prompts: [Prompt.login]);

      final data = await UserApi.instance.me();

      String result = await emailCheckService(data.kakaoAccount!.email ?? '');

      if (result == "0000") {
        LoginData loginData = LoginData(
            id: data.kakaoAccount!.email ?? '',
            nickName: data.kakaoAccount!.name ?? '');
        final LoginDataController loginDataController =
            Get.put(LoginDataController(), permanent: true);
        loginDataController.setLoginData(loginData);

        await myGoodsService();
        await loadProfileImage(loginDataController.loginData.value!.id);

        Get.offAll(() => const HomeScreen());
      } else {
        joinController.emailController.text = data.kakaoAccount!.email ?? '';
        joinController.nickNameController.text =
            data.kakaoAccount!.profile!.nickname ?? '';

        Get.offAll(() => JoinScreen(method: "2"));
      }
    }
  } catch (error) {
    Logger().e('로그인 중 에러 발생: $error');
  }
}

Future<void> kakaoLogout() async {
  await UserApi.instance.unlink();
}
