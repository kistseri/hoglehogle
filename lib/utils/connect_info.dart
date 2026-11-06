
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';
import 'package:logger/logger.dart';

// 콘텐츠 접속 정보 (접속 기록용이라 실패해도 콘텐츠 진입은 막지 않음)
Future<void> connectInfo(code) async {
  final connectivityController = Get.put(ConnectivityController());
  final logincontroller = Get.put(LoginDataController(), permanent: true);
  if (!connectivityController.isConnected.value) {
    failDialog("연결 실패", "인터넷 연결을 확인해주세요");
    return;
  }

  // 로그인 정보가 없으면 요청하지 않음 (C-21)
  final id = logincontroller.userId;
  if (id == null) {
    Logger().w('connectInfo: 로그인 정보 없음');
    return;
  }

  // 요청·응답 처리를 공통 함수로 (C-18)
  final result = await postJson(dotenv.get('CONNECT_INFO_URL'), {'id': id, 'code': code});
  if (result == null) {
    Logger().w('connectInfo: 요청 실패');
    return;
  }
  if (result['result'] != "0000") {
    failDialog('접근 실패', '${result['message'] ?? ''}');
  }
}
