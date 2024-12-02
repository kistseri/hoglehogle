import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';
import 'package:logger/logger.dart';

// 이메일 검사
Future<dynamic> emailCheckService(String email) async {
  final connectivityController = Get.put(ConnectivityController());

  if (connectivityController.isConnected.value) {
    String url = dotenv.get('EMAIL_CHK_URL');

    final Map<String, dynamic> requestData = {
      'id': email,
    };

    // HTTP POST 요청
    final response = await dio.post(url, data: jsonEncode(requestData));
    try {
      // 응답을 성공적으로 받았을 때
      if (response.statusCode == 200) {
        final Map<String, dynamic> result = json.decode(response.data);
        final resultValue = result['result'];
        // "0000" == 존재하는 이메일
        // "9999" == 존재하지 않는 이메일
        Logger().d(resultValue);
        return resultValue;
      }
      return "${response.statusCode}";
    }
    // 예외처리
    catch (e) {
      Logger().d('e = $e');
      return "$e";
    }
  } else {
    failDialog("연결 실패", "인터넷 연결을 확인해주세요");
    return "연결 실패";
  }
}
