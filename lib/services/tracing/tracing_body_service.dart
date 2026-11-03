import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/constants.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/data/models/tracing_menu_data.dart';
import 'package:hoho_hanja/screens/tracing/tracing_screen.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';
import 'package:logger/logger.dart';

// 연타로 화면이 여러 번 열리지 않도록 요청 중에는 무시
bool _isLoading = false;

// 따라쓰기
// isUnlocked: 이 급수 콘텐츠가 열려 있는지 (서버 lock == "Y")
Future<void> tracingBodyService(
    String phase, int openPage, bool isUnlocked) async {
  if (_isLoading) return;
  _isLoading = true;

  try {
    final connectivityController = Get.put(ConnectivityController());
    if (!await connectivityController.checkConnection()) {
      failDialog("연결 실패", "인터넷 연결을 확인해주세요");
      return;
    }

    String url = dotenv.get('TRACING_BODY_URL');

    final Map<String, dynamic> requestData = {
      'phase': phase,
    };
    // HTTP POST 요청
    final response = await dio.post(url, data: jsonEncode(requestData));

    // 응답을 성공적으로 받았을 때
    if (response.statusCode == 200) {
      final data = response.data;
      final List<dynamic> resultList =
          data is String ? json.decode(data) : data;

      // 메뉴가 없는 급수
      if (resultList.isEmpty) {
        failDialog('준비 중', '준비 중입니다.');
        return;
      }

      // 응답 데이터가 오류일 때("9999": 오류)
      final first = resultList.first;
      if (first is Map && first['result'] != null && first['result'] != '0000') {
        failDialog('불러오기 실패', '${first['message'] ?? ''}');
        return;
      }

      List<TracingMenuData> tracingMenuDataList = resultList.map((item) => TracingMenuData.fromJson(item)).toList();
      final TracingMenuDataController tracingMenuDataController = Get.put(TracingMenuDataController());
      tracingMenuDataController.setTracingMenuData(tracingMenuDataList);

      Get.to(
        () => TracingScreen(
          phase: phase,
          code: contentsCodes['tracing']!,
          openPage: openPage,
          isUnlocked: isUnlocked,
        ),
      );
    }
  }
  // 서버 응답 없음·시간 초과
  on DioException catch (e) {
    Logger().e('tracingBodyService = $e');
    failDialog('불러오기 실패', '잠시 후 다시 시도해주세요.');
  }
  // 응답 형식 오류
  catch (e) {
    Logger().e('tracingBodyService = $e');
    failDialog('불러오기 실패', '목록을 불러오지 못했습니다.');
  } finally {
    _isLoading = false;
  }
}
