
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/data/DTO/requestDTO/joinDTO.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';
import 'package:hoho_hanja/widgets/verification_screen.dart';

// 안심톡 코드 요청
Future<void> getAuthCode() async {
  final connectivityController = Get.put(ConnectivityController());
  final joinDTOController = Get.put(JoinReqDTOController());
  if (connectivityController.isConnected.value) {
    String url = dotenv.get('SEND_TEL_URL');

    String? firstNum = joinDTOController.joinDTO!.tel1;
    String? middleNum = joinDTOController.joinDTO!.tel2;
    String? lastNum = joinDTOController.joinDTO!.tel3;

    final Map<String, dynamic> requestData = {
      'id': joinDTOController.joinDTO!.email,
      'tel1': firstNum,
      'tel2': middleNum,
      'tel3': lastNum,
    };

    // 요청·응답 처리를 공통 함수로 (시간 초과·서버 오류도 안내, C-17)
    final result = await postJson(url, requestData);
    if (result == null) {
      failDialog(networkFailTitle, networkFailMessage);
      return;
    }
    if (result['result'] == "0000") {
      Get.to(() => Verification(
            id: joinDTOController.joinDTO!.email,
            isJoin: true,
          ));
    }
    // 응답 데이터가 오류일 때("9999": 오류)
    else {
      failDialog('회원가입 실패', '${result['message'] ?? ''}');
    }
  } else {
    failDialog("연결 실패", "인터넷 연결을 확인해주세요");
  }
}
