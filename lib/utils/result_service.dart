
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:logger/logger.dart';

// 결과값 입력
// 성공하면 지급된 코인 수(숫자 문자열), 실패하면 '잘못된 응답' (결과창은 숫자가 아니면 '-'와 다시 저장 버튼 표시)
Future<String> resultService(code, count) async {
  final connectivityController = Get.put(ConnectivityController());
  final loginController = Get.put(LoginDataController());

  if (!connectivityController.isConnected.value) {
    // 바로 뒤에 결과창이 뜨므로 실패 안내창을 따로 띄우지 않음 (결과창 코인이 '-' 로 표시됨)
    Logger().w('resultService: 인터넷 연결 없음');
    return '잘못된 응답';
  }

  // 로그인 정보가 없으면 요청하지 않음 (C-21)
  final id = loginController.userId;
  if (id == null) {
    Logger().w('resultService: 로그인 정보 없음');
    return '잘못된 응답';
  }

  // 요청·응답 처리를 공통 함수로 (시간 초과·서버 오류·빈 응답도 안전하게, C-18·C-20)
  final result = await postJson(dotenv.get('RESULT_URL'), {'id': id, 'code': code, 'cnt': count});
  if (result == null || result['result'] != "0000" || result['coin'] == null) {
    Logger().w('resultService: 저장 실패 ${result?['message']}');
    return '잘못된 응답';
  }
  return '${result['coin']}';
}
