import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:hoho_hanja/widgets/dialog/version_dialog.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

// 앱 버전 체크
Future<void> versionCheck() async {
  final connectivityController = Get.put(ConnectivityController());
  if (connectivityController.isConnected.value) {
    String url = dotenv.get('APP_VERSION_URL');

    // HTTP POST 요청
    final response = await dio.post(url);

    try {
      // 응답을 성공적으로 받았을 때
      if (response.statusCode == 200) {
        final List<dynamic> resultList = response.data;

        // 응답 결과가 있는 경우
        if (resultList[0]['result'] == "0000") {
          final packageInfo = await PackageInfo.fromPlatform();
          if (Platform.isAndroid) {
            if (resultList[0]['Androidver'] != packageInfo.version) {
              versionDialog("AOS");
            }
          }
          if (Platform.isIOS) {
            if (resultList[0]['ISOver'] != packageInfo.version) {
              versionDialog("IOS");
            }
          }
        }
        // 응답 데이터가 오류일 때("9999": 오류)
        else {
          Logger().d('${resultList[0]['message']}');
        }
      }
    }
    // 예외처리
    catch (e) {
      Logger().d('e = $e');
    }
  } else {}
}
