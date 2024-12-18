import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/services/auth/update/nickname_update_service.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';
import 'package:logger/logger.dart';

// 닉네임 중복검사
Future<String> nicknameCheckService(String type, String nickname) async {
  final connectivityController = Get.put(ConnectivityController());

  if (connectivityController.isConnected.value) {
    String url = dotenv.get('NICKNAME_CHK_URL');
    Logger().d('호출');
    final Map<String, dynamic> requestData = {
      'nickname': nickname,
    };

    // HTTP POST 요청
    final response = await dio.post(url, data: jsonEncode(requestData));

    try {
      // 응답을 성공적으로 받았을 때
      if (response.statusCode == 200) {
        final Map<String, dynamic> result = json.decode(response.data);
        final resultValue = result['result'];

        // 응답 결과가 있는 경우
        if (resultValue == "0000") {
          if (type == 'update') {
            await nicknameUpdateService(nickname);
          }
          return 'available';
        }
        // 응답 데이터가 오류일 때("9999": 오류)
        else {
          if (type == 'join') {
            Logger().d('중복');
          }
          if (type == 'update') {
            failDialog('변경 실패', '${result['message']}');
          }
          return 'duplication';
        }
      }
    }
    // 예외처리
    catch (e) {
      Logger().d('e = $e');
      return '예외발생';
    }
  } else {
    failDialog("연결 실패", "인터넷 연결을 확인해주세요");
    return '인터넷 연결 확인';
  }
  return '';
}
