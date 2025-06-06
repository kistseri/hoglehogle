import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/data/DTO/requestDTO/loginDTO.dart';
import 'package:hoho_hanja/screens/auth/login/local_login_screen.dart';
import 'package:hoho_hanja/screens/auth/login/social_login_screen.dart';
import 'package:hoho_hanja/services/auth/login/login_service.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';

/////////////////
// 자동 로그인 //
/////////////////

// 기기에 저장된 유저 정보 컨트롤러
class CheckStoredUserInfoController extends GetxController {
  AutoLoginCheckController autoLoginCheckController =
      Get.put(AutoLoginCheckController());

  final storage = Get.put(const FlutterSecureStorage()); // 기기의 보안 저장소

  late String storedUserId;
  late String storedUserPassword;

  checkStoredUserInfo() async {
    // read 함수를 통해 key값에 맞는 정보를 불러옴(불러오는 타입은 String 데이터가 없다면 null)
    String? userInfo = await storage.read(key: "login");

    if (userInfo != null) {
      storedUserId = userInfo.split(" ")[1];
      storedUserPassword = userInfo.split(" ")[3];
      autoLoginCheckController.isChecked.value = true;
      return true;
    } else {
      storedUserId = '';
      storedUserPassword = '';
      return false;
    }
  }
}

// 자동 로그인 수행
Future<Widget> checkAndPerformAutoLogin() async {
  final autoLoginController = Get.put(AutoLoginCheckController());
  final checkStoredUserInfoController =
      Get.put(CheckStoredUserInfoController());
  final connectivityController = Get.put(ConnectivityController());

  // 기기에 저장된 유저 정보 유무
  bool isUserInfoStored =
      await checkStoredUserInfoController.checkStoredUserInfo();
  // 자동 로그인 체크 유무
  bool isAutoLoginChecked = autoLoginController.isChecked.value;

  final id = checkStoredUserInfoController.storedUserId;
  final pwd = checkStoredUserInfoController.storedUserPassword;
  final LoginDTO loginDTO = LoginDTO(email: id, shaPassword: pwd);

  // 네트워크 연결 확인
  if (connectivityController.isConnected.value) {
    // 기기에 저장된 로그인 정보가 있고, 자동 로그인 체크 된 경우
    // 자동 로그인 후 홈 화면으로 이동
    if (isUserInfoStored && isAutoLoginChecked) {
      loginService(loginDTO, isAutoLoginChecked);
      return Container();
    } else {
      return const LoginScreen();
    }
  } else {
    failDialog("연결 실패", "인터넷 연결을 확인해주세요");
    return const LoginScreen();
  }
}
