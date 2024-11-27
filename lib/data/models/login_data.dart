import 'package:get/get.dart';

class LoginData {
  String nickName;
  final String id;

  LoginData({
    required this.nickName,
    required this.id,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      nickName: json['nickname'] ?? "",
      id: json['id'] ?? "",
    );
  }
}

// 데이터 컨트롤러
class LoginDataController extends GetxController {
  var loginData = Rx<LoginData?>(null);

  void setLoginData(LoginData loginData) {
    this.loginData.value = loginData;
  }

  void updateNickname(String newNickname) {
    if (loginData.value != null) {
      loginData.value!.nickName = newNickname;
      loginData.refresh();
    }
  }
}
