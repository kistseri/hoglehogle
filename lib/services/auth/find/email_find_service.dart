import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/screens/auth/find/email_confirm_screen.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:hoho_hanja/utils/split_string.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';
import 'package:logger/logger.dart';

// 이메일 찾기
Future<void> emailFindService(String phoneNumber) async {
  final connectivityController = Get.put(ConnectivityController());

  final phoneNumbers = splitPhoneNumber(phoneNumber);

  if (connectivityController.isConnected.value) {
    String url = dotenv.get('EMAIL_FIND_URL');

    final Map<String, dynamic> requestData = {
      'tel1': phoneNumbers['firstNum'],
      'tel2': phoneNumbers['middleNum'],
      'tel3': phoneNumbers['lastNum'],
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
          Get.to(
            () => EmailConfirmScreen(
                id: result['id'], nickName: result['nickname']),
          );
        }
        // 응답 데이터가 오류일 때("9999": 오류)
        else {
          failDialog('변경 실패', '${result['message']}');
          // return '변경실패, ${result['message']}';
        }
      } else {
        // return '변경실패';
      }
    }
    // 예외처리
    catch (e) {
      Logger().d('e = $e');
      // return '예외발생';
    }
  } else {
    failDialog("연결 실패", "인터넷 연결을 확인해주세요");
  }
}