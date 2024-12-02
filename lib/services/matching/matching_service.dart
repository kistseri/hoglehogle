import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/data/models/matching_data.dart';
import 'package:hoho_hanja/screens/matching/matching_screen.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';
import 'package:logger/logger.dart';

// 한자 맞추기
Future<void> matchingService(String phase, int? openPage) async {
  final connectivityController = Get.put(ConnectivityController());

  if (connectivityController.isConnected.value) {
    String url = dotenv.get('MATCHING_URL');

    final Map<String, dynamic> requestData = {
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
          List<MatchingData> matchingDataList =
              resultList.map((item) => MatchingData.fromJson(item)).toList();
          final MatchingDataController matchingController =
              Get.put(MatchingDataController());
          matchingController.setMatchingDataList(matchingDataList);

          Get.to(() => MatchingScreen(
                openPage: openPage,
                phase: phase,
              ));
        }
        // 응답 데이터가 오류일 때("9999": 오류)
        else {
          failDialog('불러오기 실패', '${resultList[0]['message']}');
          // Get.to(() => JoinVerification());
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
