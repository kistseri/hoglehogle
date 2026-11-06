import 'package:get/get.dart';
import 'package:hoho_hanja/data/models/json_parse.dart';
import 'package:hoho_hanja/services/purchase/purchase_controller.dart';

class LoginData {
  String nickName;
  final String id;

  LoginData({
    required this.nickName,
    required this.id,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      nickName: jsonStr(json['nickname']),
      id: jsonStr(json['id']),
    );
  }
}

// 데이터 컨트롤러
class LoginDataController extends GetxController {
  var loginData = Rx<LoginData?>(null);

  /// 로그인한 사용자 id. 로그인 정보가 없으면 null (loginData.value! 강제 언랩 대신 사용, C-21)
  String? get userId => loginData.value?.id;

  void setLoginData(LoginData loginData) {
    this.loginData.value = loginData;
    // 로그인(일반·소셜·자동 모두 여기를 지남) 후 결제 리스너 시작 (C-04)
    if (Get.isRegistered<PurchaseController>()) Get.find<PurchaseController>().start(loginData.id);
  }

  void updateNickname(String newNickname) {
    if (loginData.value != null) {
      loginData.value!.nickName = newNickname;
      loginData.refresh();
    }
  }
}
