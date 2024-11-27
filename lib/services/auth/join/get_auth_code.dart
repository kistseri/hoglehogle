import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/data/DTO/requestDTO/joinDTO.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';
import 'package:hoho_hanja/widgets/verification_screen.dart';
import 'package:logger/logger.dart';

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

    // HTTP POST 요청
    final response = await dio.post(url, data: jsonEncode(requestData));

    try {
      // 응답을 성공적으로 받았을 때
      if (response.statusCode == 200) {
        final resultList = json.decode(response.data);

        final resultValue = resultList['result'];

        // 응답 결과가 있는 경우
        if (resultValue == "0000") {
          Get.to(() => Verification(
                id: joinDTOController.joinDTO!.email,
                isJoin: true,
              ));
        }
        // 응답 데이터가 오류일 때("9999": 오류)
        else {
          failDialog('회원가입 실패', '${resultList['message']}');
        }
      }
    }
    // 예외처리
    catch (e) {
      Logger().d('e = $e');
    }
  } else {
    failDialog("연결 실패", "인터넷 연결을 확인해주세요");
  }
}
