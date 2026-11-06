import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/data/models/matching_menu_data.dart';
import 'package:hoho_hanja/screens/matching/matching_menu_screen.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';
import 'package:logger/logger.dart';

// 연타로 화면이 여러 번 열리지 않도록 요청 중에는 무시
bool _isLoading = false;

// 한자맞추기 메뉴
// isUnlocked: 이 급수 콘텐츠가 열려 있는지 (서버 lock == "Y")
Future<void> matchingBodyService(String phase, int openPage, bool isUnlocked) async {
  if (_isLoading) return;
  _isLoading = true;

  try {
    final connectivityController = Get.put(ConnectivityController());
    if (!await connectivityController.checkConnection()) {
      failDialog("연결 실패", "인터넷 연결을 확인해주세요");
      return;
    }

    // 단원 목록은 따라쓰기 메뉴를 그대로 사용
    String url = dotenv.get('TRACING_BODY_URL');

    final Map<String, dynamic> requestData = {
      'phase': phase,
    };
    // HTTP POST 요청
    final response = await dio.post(url, data: jsonEncode(requestData));

    // 응답을 성공적으로 받았을 때
    if (response.statusCode == 200) {
      final data = response.data;
      final List<dynamic> resultList = data is String ? json.decode(data) : data;

      // 메뉴가 없는 급수
      if (resultList.isEmpty) {
        failDialog('알림', '준비 중입니다.');
        return;
      }

      // 응답 데이터가 오류일 때("9999": 오류)
      final first = resultList.first;
      if (first is Map && first['result'] != null && first['result'] != '0000') {
        failDialog('불러오기 실패', '${first['message'] ?? ''}');
        return;
      }

      List<MatchingMenuData> matchingMenuDataList = resultList.map((item) => MatchingMenuData.fromJson(item)).toList();
      final MatchingMenuDataController matchingMenuDataController = Get.put(MatchingMenuDataController());
      matchingMenuDataController.setMatchingMenuData(matchingMenuDataList);

      Get.to(
        () => MatchingMenuScreen(
          phase: phase,
          openPage: openPage,
          isUnlocked: isUnlocked,
        ),
      );
    }
  }
  // 서버 응답 없음·시간 초과
  on DioException catch (e) {
    Logger().e('matchingBodyService = $e');
    failDialog('불러오기 실패', '잠시 후 다시 시도해주세요.');
  }
  // 응답 형식 오류
  catch (e) {
    Logger().e('matchingBodyService = $e');
    failDialog('불러오기 실패', '목록을 불러오지 못했습니다.');
  } finally {
    _isLoading = false;
  }
}
