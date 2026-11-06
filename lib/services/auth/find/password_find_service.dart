
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:hoho_hanja/utils/split_string.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';
import 'package:hoho_hanja/widgets/verification_screen.dart';

// 비밀번호 인증요청
Future<void> passwordFindService(String id, String phoneNumber) async {
  final connectivityController = Get.put(ConnectivityController());

  final phoneNumbers = splitPhoneNumber(phoneNumber);

  if (connectivityController.isConnected.value) {
    String url = dotenv.get('PASSWORD_FIND_URL');

    final Map<String, dynamic> requestData = {
      'id': id,
      'tel1': phoneNumbers['firstNum'],
      'tel2': phoneNumbers['middleNum'],
      'tel3': phoneNumbers['lastNum'],
    };

    // 요청·응답 처리를 공통 함수로 (시간 초과·서버 오류도 안내, C-17)
    final result = await postJson(url, requestData);
    if (result == null) {
      failDialog(networkFailTitle, networkFailMessage);
      return;
    }
    if (result['result'] == "0000") {
      // 인증번호 입력 화면
      Get.to(() => Verification(id: id, isJoin: false));
    }
    // 응답 데이터가 오류일 때("9999": 오류)
    else {
      failDialog('비밀번호 찾기 실패', '${result['message'] ?? ''}');
    }
  } else {
    failDialog("연결 실패", "인터넷 연결을 확인해주세요");
  }
}
