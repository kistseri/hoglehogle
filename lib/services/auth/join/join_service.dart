
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/data/DTO/requestDTO/joinDTO.dart';
import 'package:hoho_hanja/screens/auth/login/social_login_screen.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';

// 회원가입 요청
Future<void> joinService() async {
  final connectivityController = Get.put(ConnectivityController());
  final joinDTOController = Get.put(JoinReqDTOController(), permanent: true);

  if (connectivityController.isConnected.value) {
    String url = dotenv.get('JOIN_URL');

    // 요청·응답 처리를 공통 함수로 (시간 초과·서버 오류도 안내, C-17)
    final result = await postJson(url, joinDTOController.joinDTO);
    if (result == null) {
      failDialog(networkFailTitle, networkFailMessage);
      return;
    }
    if (result['result'] == "0000") {
      Get.offAll(() => const LoginScreen());
    }
    // 응답 데이터가 오류일 때("9999": 오류)
    else {
      failDialog('회원가입 실패', '${result['message'] ?? ''}');
    }
  } else {
    failDialog("연결 실패", "인터넷 연결을 확인해주세요");
  }
}
