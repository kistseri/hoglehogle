
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:hoho_hanja/widgets/dialog/notice_dialog.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 메인 공지
Future<void> mainNotice() async {
  final prefs = await SharedPreferences.getInstance();
  final connectivityController = Get.find<ConnectivityController>();
  if (!connectivityController.isConnected.value) return;

  // 요청·응답 처리를 공통 함수로 (실패하면 공지 없이 넘어감, C-17)
  final resultData = await postJson(dotenv.get('MAIN_NOTICE_URL'));
  if (resultData == null) return;

  // 응답 결과가 있는 경우
  if (resultData['result'] == "0000") {
    final noticeKey = '${resultData['index']}';
    final isHidden = prefs.getBool(noticeKey) ?? false;
    if (resultData['tag'] == "Y" && !isHidden) {
      showNoticeDialog(
        '${resultData['title'] ?? ''}',
        '${resultData['message'] ?? ''}',
        onDoNotShowAgain: () {
          prefs.setBool(noticeKey, true);
        },
      );
    }
  }
  // 응답 데이터가 오류일 때("9999": 오류)
  else {
    Logger().d('${resultData['message']}');
  }
}
