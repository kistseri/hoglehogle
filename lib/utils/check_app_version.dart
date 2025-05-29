import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:hoho_hanja/widgets/dialog/version_dialog.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';

// 앱 버전 체크
Future<bool> versionCheck() async {
  final connectivityController = Get.put(ConnectivityController());
  if (connectivityController.isConnected.value) {
    String url = dotenv.get('APP_VERSION_URL');

    try {
      final response = await dio.post(url);

      if (response.statusCode == 200) {
        final List<dynamic> resultList = response.data;
        final packageInfo = await PackageInfo.fromPlatform();

        if (resultList[0]['result'] == "0000") {
          if (Platform.isAndroid &&
              resultList[0]['Androidver'] != packageInfo.version) {
            await versionDialog("AOS");
            return false; // 버전 불일치
          }

          if (Platform.isIOS &&
              resultList[0]['ISOver'] != packageInfo.version) {
            await versionDialog("IOS");
            return false; // 버전 불일치
          }
        }
      }
    } catch (e) {
      Logger().d('e = $e');
    }
  }

  return true; // 버전 이상 없음 or 네트워크 없음
}