import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/data/models/contents_data.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/services/auth/my_goods_service.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';
import 'package:hoho_hanja/widgets/dialog/unlock_dilog.dart';
import 'package:logger/logger.dart';

// 콘텐츠 Lock 정보
Future<void> contentsLock(phase) async {
  final connectivityController = Get.put(ConnectivityController());
  final logincontroller = Get.put(LoginDataController(), permanent: true);

  if (connectivityController.isConnected.value) {
    String url = dotenv.get('CONTENTS_LOCK_URL');

    final Map<String, dynamic> requestData = {
      'id': logincontroller.loginData.value!.id,
      'phase': phase,
    };

    // HTTP POST 요청
    final response = await dio.post(url, data: jsonEncode(requestData));

    try {
      // 응답을 성공적으로 받았을 때
      if (response.statusCode == 200) {
        final List<dynamic> resultList = json.decode(response.data);

        final resultValue = resultList[0]['result'];

        // 응답 결과가 있는 경우
        if (resultValue == "0000") {
          List<ContentsData> contentsDataList =
              resultList.map((item) => ContentsData.fromJson(item)).toList();

          final ContentsDataController contentsDataController =
              Get.put(ContentsDataController());
          contentsDataController.setContentsDataList(contentsDataList);
        }
        // 응답 데이터가 오류일 때("9999": 오류)
        else {
          failDialog('접근 실패', '${resultList[0]['message']}');
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

// 컨텐츠 open
Future<void> contentsUnlock(String phase) async {
  final connectivityController = Get.put(ConnectivityController());
  final logincontroller = Get.put(LoginDataController(), permanent: true);

  if (connectivityController.isConnected.value) {
    String url = dotenv.get('CONTENTS_UNLOCK_URL');

    final Map<String, dynamic> requestData = {
      'id': logincontroller.loginData.value!.id,
      'phase': phase,
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
          await myGoodsService();
          await contentsLock(phase);
          Get.back();
        }
        // 응답 데이터가 오류일 때("9999": 오류)
        else {
          unlockDialog('알림', '${resultList['message']}');
          await Future.delayed(
            const Duration(seconds: 2),
            () {
              Get.back();
            },
          );
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
