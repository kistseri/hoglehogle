import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/constants.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/data/models/rank_data.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:logger/logger.dart';

Future<void>? _running;

// 랭킹 불러오기
// 실패해도 팝업은 띄우지 않고 상태만 바꿈 (랭킹 화면에서 안내 + 다시 시도).
// 홈 시작·랭킹 탭 진입이 겹쳐도 요청은 한 번만 보냄.
Future<void> rankService() {
  return _running ??= _load().whenComplete(() => _running = null);
}

Future<void> _load() async {
  final connectivityController = Get.put(ConnectivityController());
  final rankDataController = Get.put(RankDataController());

  if (!connectivityController.isConnected.value) {
    rankDataController.setError('인터넷 연결을 확인해주세요');
    return;
  }

  rankDataController.setLoading();
  try {
    final response = await dio.post(
      dotenv.get('RANK_COPY_URL'),
      data: jsonEncode({'ym': GetCurrentYM.ym}),
    );
    if (response.statusCode != 200) {
      rankDataController.setError('랭킹을 불러오지 못했어요');
      return;
    }
    final data = response.data is String ? json.decode(response.data) : response.data;
    final List<dynamic> resultList = data is List ? data : [];

    // 이번 달 기록이 아직 없으면 서버가 빈 목록을 보냄 (매월 1일 초기화 직후)
    if (resultList.isEmpty) {
      rankDataController.setRankData([]);
      return;
    }
    if (resultList[0]['result']?.toString() != '0000') {
      rankDataController.setError('${resultList[0]['message'] ?? '랭킹을 불러오지 못했어요'}');
      return;
    }
    rankDataController.setRankData(
      resultList.whereType<Map<String, dynamic>>().map(RankData.fromJson).toList(),
    );
  } catch (e) {
    Logger().w('랭킹 불러오기 실패: $e');
    rankDataController.setError('랭킹을 불러오지 못했어요');
  }
}
