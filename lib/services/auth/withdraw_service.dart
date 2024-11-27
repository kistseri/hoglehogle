import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';
import 'package:hoho_hanja/widgets/dialog/withdraw_dialog.dart';
import 'package:logger/logger.dart';

// 회원 탈퇴
Future<void> withdrawService() async {
  final connectivityController = Get.put(ConnectivityController());
  final loginDataController = Get.put(LoginDataController());

  if (connectivityController.isConnected.value) {
    String url = dotenv.get('WITHDRAW_URL');

    final Map<String, dynamic> requestData = {
      'id': loginDataController.loginData.value!.id,
    };

    // HTTP POST 요청
    final response = await dio.post(url, data: jsonEncode(requestData));
    Logger().d(response);
    try {
      // 응답을 성공적으로 받았을 때
      if (response.statusCode == 200) {
        final Map<String, dynamic> resultList = json.decode(response.data);
        final resultValue = resultList['result'];

        // 응답 결과가 있는 경우
        if (resultValue == "0000") {
          withdrawDialog();
        }
        // 응답 데이터가 오류일 때("9999": 오류)
        else {
          failDialog('회원 탈퇴 실패', '${resultList['message']}');
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
