import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/data/DTO/requestDTO/loginDTO.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/screens/auth/login/local_login_screen.dart';
import 'package:hoho_hanja/screens/home/home_screen.dart';
import 'package:hoho_hanja/services/auth/my_goods_service.dart';
import 'package:hoho_hanja/utils/load_profile_image.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';
import 'package:logger/logger.dart';

// 로그인 요청
Future<void> loginService(LoginDTO loginDTO, bool isAutoLoginChecked) async {
  final connectivityController = Get.put(ConnectivityController());
  final LoginController loginController = Get.put(LoginController());

  // 네트워크 연결 확인
  if (connectivityController.isConnected.value) {
    final storage = Get.find<FlutterSecureStorage>();

    String url = dotenv.get('LOGIN_URL');

    try {
      if (loginDTO.email != "" || loginDTO.shaPassword != "") {
        // HTTP POST 요청
        final response = await dio.post(url, data: loginDTO.toJson());
        // 응답을 성공적으로 받았을 때
        if (response.statusCode == 200) {
          final resultList = json.decode(response.data);

          final resultValue = resultList['result'];

          // 응답 결과가 있는 경우
          if (resultValue == "0000") {
            LoginData loginData = LoginData.fromJson(resultList);
            final LoginDataController loginDataController =
                Get.put(LoginDataController(), permanent: true);
            loginDataController.setLoginData(loginData);

            if (isAutoLoginChecked) {
              await storage.write(
                  key: 'login',
                  value:
                      'id ${loginDTO.email} password ${loginDTO.shaPassword}');
            }
            // await getToken();

            await myGoodsService();
            await loadProfileImage(loginDataController.loginData.value!.id);
            Get.offAll(() => const HomeScreen());
          }
          // 응답 데이터가 오류일 때("9999": 오류)
          else {
            failDialog('로그인 실패', '${resultList['message']}');

            // 아이디, 비밀번호 입력 초기화
            loginController.emailController.text = "";
            loginController.passwordController.text = "";
          }
        }
        // 응답을 받지 못했을 때
      } else {
        failDialog('로그인 실패', '아이디와 비밀번호를 입력해주세요.');
      }
    } catch (e) {
      Logger().d('e = $e');
    }
  } else {
    failDialog("연결 실패", "인터넷 연결을 확인해주세요");
  }
}
