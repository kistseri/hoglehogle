import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/data/models/tracing_data.dart';
import 'package:hoho_hanja/screens/tracing/tracing_widgets/tracing_write.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';
import 'package:logger/logger.dart';

// 연타로 화면이 여러 번 열리지 않도록 요청 중에는 무시
bool _isLoading = false;

// 따라쓰기
// gubun: 메뉴 항목의 구분값, isUnlocked: 이 급수 콘텐츠가 열려 있는지
Future<void> tracingService(String phase, String gubun, String code,
    int openPage, bool isUnlocked) async {
  if (_isLoading) return;
  _isLoading = true;

  try {
    final connectivityController = Get.put(ConnectivityController());
    if (!await connectivityController.checkConnection()) {
      failDialog("연결 실패", "인터넷 연결을 확인해주세요");
      return;
    }

    String url = dotenv.get('TRACING_URL');

    final Map<String, dynamic> requestData = {
      'phase': phase,
      'gubun': gubun,
    };

    // HTTP POST 요청
    final response = await dio.post(url, data: jsonEncode(requestData));

    // 응답을 성공적으로 받았을 때
    if (response.statusCode == 200) {
      final data = response.data;
      final List<dynamic> resultList =
          data is String ? json.decode(data) : data;

      // 글자가 없는 단원
      if (resultList.isEmpty) {
        failDialog('준비 중', '준비 중입니다.');
        return;
      }

      final resultValue = resultList[0]['result'];

      // 응답 결과가 있는 경우
      if (resultValue == "0000") {
        List<TracingData> tracingDataList =
            resultList.map((item) => TracingData.fromJson(item)).toList();

        final TracingDataController tracingDataController =
            Get.put(TracingDataController());
        tracingDataController.setTracingData(tracingDataList);

        Get.to(() => TracingWrite(
              code: code,
              openPage: isUnlocked ? resultList.length : openPage,
            ));
      }
      // 응답 데이터가 오류일 때("9999": 오류)
      else {
        failDialog('불러오기 실패', '${resultList[0]['message'] ?? ''}');
      }
    }
  }
  // 서버 응답 없음·시간 초과
  on DioException catch (e) {
    Logger().e('tracingService = $e');
    failDialog('불러오기 실패', '잠시 후 다시 시도해주세요.');
  }
  // 응답 형식 오류
  catch (e) {
    Logger().e('tracingService = $e');
    failDialog('불러오기 실패', '글자를 불러오지 못했습니다.');
  } finally {
    _isLoading = false;
  }
}
