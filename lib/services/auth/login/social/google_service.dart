import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/screens/auth/join/join_screen.dart';
import 'package:hoho_hanja/screens/home/home_screen.dart';
import 'package:hoho_hanja/services/auth/login/social/email_check_service.dart';
import 'package:hoho_hanja/services/auth/my_goods_service.dart';
import 'package:hoho_hanja/utils/load_profile_image.dart';
import 'package:logger/logger.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();

Future<void> googleLogin() async {
  final JoinTextController joinController = Get.put(JoinTextController());
  try {
    // 구글 로그인 시도
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser != null) {
      String result = await emailCheckService(googleUser.email);
      if (result == '0000') {
        LoginData loginData = LoginData(
            id: googleUser.email, nickName: googleUser.displayName ?? "");
        final LoginDataController loginDataController =
            Get.put(LoginDataController(), permanent: true);
        loginDataController.setLoginData(loginData);

        await myGoodsService();
        await loadProfileImage(loginDataController.loginData.value!.id);

        Get.offAll(() => const HomeScreen());
      } else {
        joinController.emailController.text = googleUser.email;
        joinController.nickNameController.text = googleUser.displayName ?? '';
        Get.offAll(() => JoinScreen(method: "3"));
      }
    } else {
      Logger().w("구글 로그인 취소됨");
    }
  } catch (error) {
    Logger().e('구글 로그인 중 에러 발생: $error');
  }
}

Future<void> googleLogout() async {
  await googleSignIn.signOut();
}
