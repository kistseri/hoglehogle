import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/screens/auth/login/local_login_screen.dart';

void logout() async {
  String? userInfo = "";
  final storage = Get.put(const FlutterSecureStorage());
  userInfo = await storage.read(key: "login");

  // 기기에 저장된 유저정보가 있는 경우 삭제
  if (userInfo != null) {
    await storage.delete(key: "login");
  }

  final loginController = Get.put(LoginController());
  final autoLoginCheckController = Get.put(AutoLoginCheckController());

  // 초기화
  loginController.emailController.clear();
  loginController.passwordController.clear();
  autoLoginCheckController.isChecked.value = false;
}
