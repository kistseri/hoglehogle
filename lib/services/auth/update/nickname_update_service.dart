import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';

// 닉네임 변경 (성공하면 true)
Future<bool> nicknameUpdateService(String nickname) async {
  final connectivityController = Get.put(ConnectivityController());
  final loginController = Get.put(LoginDataController());
  final id = loginController.loginData.value?.id;

  if (!connectivityController.isConnected.value) {
    failDialog("연결 실패", "인터넷 연결을 확인해주세요");
    return false;
  }
  if (id == null || id.isEmpty) {
    failDialog('변경 실패', '로그인 정보를 찾을 수 없어요.\n다시 로그인해주세요.');
    return false;
  }

  final result = await postJson(dotenv.get('NICKNAME_URL'), {'id': id, 'nickname': nickname});
  if (result == null) {
    failDialog('변경 실패', '잠시 후 다시 시도해주세요.');
    return false;
  }
  if (result['result'] == "0000") {
    loginController.updateNickname(nickname);
    return true;
  }
  failDialog('변경 실패', '${result['message'] ?? '잠시 후 다시 시도해주세요.'}');
  return false;
}
