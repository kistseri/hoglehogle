import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/screens/auth/find/password_reset_screen.dart';
import 'package:hoho_hanja/services/auth/join/join_service.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';
import 'package:logger/logger.dart';

// 전화번호 인증
Future<void> verificationService(String code, String id, bool isJoin) async {
  final connectivityController = Get.put(ConnectivityController());

  if (connectivityController.isConnected.value) {
    String url = dotenv.get('AUTH_CHECK_URL');


    final Map<String, dynamic> requestData = {
      'id': id,
      'authkey': code,
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
          if (isJoin) {
            joinService();
          } else {
            Get.to(() => PasswordResetScreen(id: id));
          }
        }
        // 응답 데이터가 오류일 때("9999": 오류)
        else {
          failDialog('인증 실패', '${resultList['message']}');
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
