import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/services/auth/update/nickname_update_service.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';
import 'package:logger/logger.dart';

// 닉네임 중복검사
// 'available' = 사용 가능 (type이 'update'면 변경까지 성공), 'duplication' = 중복,
// 'fail' = 변경 실패, '예외발생' = 서버 응답 없음, '인터넷 연결 확인'
Future<String> nicknameCheckService(String type, String nickname) async {
  final connectivityController = Get.put(ConnectivityController());

  if (!connectivityController.isConnected.value) {
    failDialog("연결 실패", "인터넷 연결을 확인해주세요");
    return '인터넷 연결 확인';
  }

  final result = await postJson(dotenv.get('NICKNAME_CHK_URL'), {'nickname': nickname});
  Logger().d(result);
  if (result == null) {
    if (type == 'update') failDialog('변경 실패', '잠시 후 다시 시도해주세요.');
    return '예외발생';
  }

  if (result['result'] == "0000") {
    if (type == 'update') {
      return await nicknameUpdateService(nickname) ? 'available' : 'fail';
    }
    return 'available';
  }

  // 응답 데이터가 오류일 때("9999": 중복 등)
  if (type == 'join') Logger().d('중복');
  if (type == 'update') failDialog('변경 실패', '${result['message'] ?? '사용할 수 없는 닉네임이에요.'}');
  return 'duplication';
}
