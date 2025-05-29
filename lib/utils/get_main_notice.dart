import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:hoho_hanja/widgets/dialog/notice_dialog.dart';
import 'package:hoho_hanja/widgets/dialog/version_dialog.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 앱 버전 체크
Future<void> mainNotice() async {
  final prefs = await SharedPreferences.getInstance();
  final connectivityController = Get.find<ConnectivityController>();
  if (connectivityController.isConnected.value) {
    String url = dotenv.get('MAIN_NOTICE_URL');
    // HTTP POST 요청
    final response = await dio.post(url);

    try {
      // 응답을 성공적으로 받았을 때
      if (response.statusCode == 200) {
        final dynamic resultData = response.data;

        // 응답 결과가 있는 경우
        if (resultData['result'] == "0000") {
          final noticeKey = resultData['index'];
          final isHidden = prefs.getBool(noticeKey) ?? false;

          if (resultData['tag'] == "Y" && !isHidden) {
            showNoticeDialog(
              resultData['title'],
              resultData['message'],
              onDoNotShowAgain: () {
                prefs.setBool(noticeKey, true);
                prefs.get(noticeKey);
              },
            );
          }
        }
        // 응답 데이터가 오류일 때("9999": 오류)
        else {
          Logger().d('${resultData['message']}');
        }
      }
    }
    // 예외처리
    catch (e) {
      Logger().d('e = $e');
    }
  } else {}
}
