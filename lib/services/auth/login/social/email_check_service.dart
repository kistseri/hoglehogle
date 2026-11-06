
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';

// 이메일 검사
Future<dynamic> emailCheckService(String email) async {
  final connectivityController = Get.put(ConnectivityController());

  if (connectivityController.isConnected.value) {
    String url = dotenv.get('EMAIL_CHK_URL');

    final Map<String, dynamic> requestData = {
      'id': email,
    };

    // 요청·응답 처리를 공통 함수로 (C-17)
    // "0000" == 존재하는 이메일, "9999" == 존재하지 않는 이메일
    final result = await postJson(url, requestData);
    if (result == null) {
      failDialog(networkFailTitle, networkFailMessage);
      return "연결 실패";
    }
    return result['result'];
  } else {
    failDialog("연결 실패", "인터넷 연결을 확인해주세요");
    return "연결 실패";
  }
}
