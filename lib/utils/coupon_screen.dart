import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/data/models/setting_data.dart';
import 'package:logger/logger.dart';

// 쿠폰 스크린 (Y = 안보임(심사중), N = 보임(심사끝))
Future<void> settingScreen() async {
  String url = dotenv.get('COUPON_SCREEN_URL');

  // HTTP POST 요청
  final response = await dio.post(url);

  try {
    // 응답을 성공적으로 받았을 때
    if (response.statusCode == 200) {
      final Map<String, dynamic> resultList = json.decode(response.data);
      // 응답 결과가 있는 경우
      if (resultList['result'] == "0000") {
        final yn = resultList['yn'];
        Logger().d('yn = $yn');
        final SettingDataController settingDataController =
            Get.put(SettingDataController());
        settingDataController.settinData(yn);
      }
      // 응답 데이터가 오류일 때("9999": 오류)
      else {
        Logger().d('${resultList['message']}');
      }
    }
  }
  // 예외처리
  catch (e) {
    Logger().d('e = $e');
  }
}
