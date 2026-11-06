
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/screens/auth/find/password_reset_screen.dart';
import 'package:hoho_hanja/services/auth/join/join_service.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';

// 전화번호 인증
Future<void> verificationService(String code, String id, bool isJoin) async {
  final connectivityController = Get.put(ConnectivityController());

  if (connectivityController.isConnected.value) {
    String url = dotenv.get('AUTH_CHECK_URL');


    final Map<String, dynamic> requestData = {
      'id': id,
      'authkey': code,
    };


    // 요청·응답 처리를 공통 함수로 (시간 초과·서버 오류도 안내, C-17)
    final result = await postJson(url, requestData);
    if (result == null) {
      failDialog(networkFailTitle, networkFailMessage);
      return;
    }
    if (result['result'] == "0000") {
      if (isJoin) {
        await joinService(); // 가입 요청이 끝날 때까지 기다림 (C-40)
      } else {
        Get.to(() => PasswordResetScreen(id: id));
      }
    }
    // 응답 데이터가 오류일 때("9999": 오류)
    else {
      failDialog('인증 실패', '${result['message'] ?? ''}');
    }
  } else {
    failDialog("연결 실패", "인터넷 연결을 확인해주세요");
  }
}
