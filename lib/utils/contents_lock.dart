import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/data/models/contents_data.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/services/auth/my_goods_service.dart';
import 'package:hoho_hanja/services/purchase/product_service.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';
import 'package:logger/logger.dart';

// 콘텐츠 Lock 정보
Future<void> contentsLock(phase) async {
  final connectivityController = Get.put(ConnectivityController());
  final logincontroller = Get.put(LoginDataController(), permanent: true);

  if (!connectivityController.isConnected.value) {
    failDialog("연결 실패", "인터넷 연결을 확인해주세요");
    return;
  }

  // 로그인 정보가 없으면 요청하지 않음 (C-21)
  final id = logincontroller.userId;
  if (id == null) {
    Logger().w('contentsLock: 로그인 정보 없음');
    return;
  }

  // 요청·응답 처리를 공통 함수로 (시간 초과·서버 오류·빈 응답도 안전하게, C-17·C-20)
  final resultList = await postJsonList(dotenv.get('CONTENTS_LOCK_URL'), {'id': id, 'phase': phase});
  if (resultList == null) {
    // 홈 진입 때 여러 요청이 함께 나가므로 안내창은 띄우지 않음 (홈 타일을 누를 때 '불러오기 실패' 안내)
    Logger().w('contentsLock: 요청 실패');
    return;
  }
  if (resultList.isEmpty) {
    Logger().w('contentsLock: 빈 응답');
    return;
  }

  if (resultList.first['result'] == "0000") {
    final contentsDataList = resultList.map((item) => ContentsData.fromJson(item)).toList();
    final ContentsDataController contentsDataController = Get.put(ContentsDataController());
    contentsDataController.setContentsDataList(contentsDataList);
  }
  // 응답 데이터가 오류일 때("9999": 오류)
  else {
    failDialog('접근 실패', '${resultList.first['message'] ?? ''}');
  }
}

bool _unlocking = false;

// 컨텐츠 open. 성공하면 true (잠금 해제 창은 부른 쪽에서 닫음)
// '잠금해제' 연타로 다이아가 두 번 빠지지 않도록 요청 중에는 무시
Future<bool> contentsUnlock(String phase) async {
  if (_unlocking) return false;
  _unlocking = true;
  try {
    return await _unlock(phase);
  } finally {
    _unlocking = false;
  }
}

Future<bool> _unlock(String phase) async {
  final connectivityController = Get.put(ConnectivityController());
  final logincontroller = Get.put(LoginDataController(), permanent: true);

  if (!connectivityController.isConnected.value) {
    failDialog("연결 실패", "인터넷 연결을 확인해주세요");
    return false;
  }

  final id = logincontroller.userId;
  if (id == null) {
    Logger().w('contentsUnlock: 로그인 정보 없음');
    return false;
  }

  // 요청·응답 처리를 공통 함수로 (C-17)
  final result = await postJson(dotenv.get('CONTENTS_UNLOCK_URL'), {'id': id, 'phase': phase});
  if (result == null) {
    failDialog(networkFailTitle, networkFailMessage);
    return false;
  }

  final resultValue = result['result'];
  // 응답 결과가 있는 경우
  if (resultValue == "0000") {
    await myGoodsService();
    await contentsLock(phase);
    return true;
  }
  // 다이아가 부족할 때("9999") → 상점 상품 불러오기
  else if (resultValue == '9999') {
    await productService();
  } else {
    failDialog('잠금 해제 실패', '${result['message'] ?? '잠시 후 다시 시도해주세요.'}');
  }
  return false;
}
