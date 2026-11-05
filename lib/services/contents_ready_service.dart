import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:logger/logger.dart';

/// 콘텐츠 준비 여부 (그 급수에 문제가 있는지 서버에 물어봄)
///
/// 각 콘텐츠의 문제 API(DEFINE_URL·BAKE_URL·COOKIE_URL·IDIOM_URL)는 잠금과 상관없이 급수만 보내면 되고,
/// 문제가 없는 급수면 빈 목록이 온다. 그래서 잠금 해제 구매창을 띄우기 전에 확인해서,
/// 아직 문제가 없으면 '준비 중'을 띄워 다이아를 쓰지 않게 한다.
///
/// 확인하지 못하면(인터넷·서버 오류) 준비된 것으로 보고 원래대로 구매창을 띄움.
Future<bool> isContentReady(String urlKey, String phase) async {
  try {
    final response = await dio.post(dotenv.get(urlKey), data: jsonEncode({'phase': phase}));
    if (response.statusCode != 200) return true;

    final data = response.data;
    final List<dynamic> resultList = data is String ? json.decode(data) : data;
    if (resultList.isEmpty) return false;
    return resultList[0]['result'] == '0000';
  } catch (e) {
    Logger().w('isContentReady($urlKey, $phase) = $e');
    return true;
  }
}
