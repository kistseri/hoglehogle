import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/utils/logout.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';
import 'package:hoho_hanja/widgets/dialog/withdraw_dialog.dart';

// 회원 탈퇴
Future<void> withdrawService() async {
  final connectivityController = Get.put(ConnectivityController());
  final loginDataController = Get.put(LoginDataController());
  final id = loginDataController.loginData.value?.id;

  if (!connectivityController.isConnected.value) {
    failDialog("연결 실패", "인터넷 연결을 확인해주세요");
    return;
  }
  if (id == null || id.isEmpty) {
    failDialog('회원 탈퇴 실패', '로그인 정보를 찾을 수 없어요.\n다시 로그인해주세요.');
    return;
  }

  final result = await postJson(dotenv.get('WITHDRAW_URL'), {'id': id});
  if (result == null) {
    failDialog('회원 탈퇴 실패', '잠시 후 다시 시도해주세요.');
    return;
  }
  if (result['result'] == "0000") {
    // 저장된 로그인·소셜 연결을 지우고 안내 후 로그인 화면으로
    await clearLoginState(unlinkSocial: true);
    withdrawDialog();
  } else {
    failDialog('회원 탈퇴 실패', '${result['message'] ?? '잠시 후 다시 시도해주세요.'}');
  }
}
