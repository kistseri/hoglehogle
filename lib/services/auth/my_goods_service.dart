
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/data/models/goods_data.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';
import 'package:logger/logger.dart';

// 마지막으로 코인 정보를 받아 온 시각 (앱바가 생길 때마다 같은 요청을 반복하지 않도록, C-44)
DateTime? _lastGoodsFetch;

/// 앱바·홈처럼 화면이 생길 때마다 불리는 곳에서 사용.
/// 최근 [maxAge] 안에 받아 온 적이 있으면 요청하지 않음.
/// 코인이 바뀌는 곳(게임 종료·구매·쿠폰·잠금 해제)은 지금처럼 myGoodsService()를 바로 부름.
Future<void> refreshGoodsIfStale({Duration maxAge = const Duration(seconds: 30)}) async {
  final last = _lastGoodsFetch;
  if (last != null && DateTime.now().difference(last) < maxAge) return;
  await myGoodsService();
}

// 나의 코인
Future<void> myGoodsService() async {
  final connectivityController = Get.put(ConnectivityController());
  final loginController = Get.put(LoginDataController());
  if (!connectivityController.isConnected.value) {
    failDialog("연결 실패", "인터넷 연결을 확인해주세요");
    return;
  }

  // 로그인 정보가 없으면 요청하지 않음 (C-21)
  final id = loginController.userId;
  if (id == null) {
    Logger().w('myGoodsService: 로그인 정보 없음');
    return;
  }

  // 요청·응답 처리를 공통 함수로 (시간 초과·서버 오류·빈 응답도 안전하게, C-17·C-20)
  // 앱바·홈 등 여러 곳에서 자주 불리므로 요청 실패 시 안내창은 띄우지 않음
  final result = await postJson(dotenv.get('MY_GOODS_URL'), {'id': id});
  if (result == null) {
    Logger().w('myGoodsService: 요청 실패');
    return;
  }

  // 응답 결과가 있는 경우
  if (result['result'] == "0000") {
    GoodsData goodsData = GoodsData.fromJson(result);
    final GoodsDataController goodsDataController = Get.put(GoodsDataController(), permanent: true);
    goodsDataController.setGoodsData(goodsData);
    _lastGoodsFetch = DateTime.now();
  }
  // 응답 데이터가 오류일 때("9999": 오류)
  else {
    failDialog('불러오기 실패', '${result['message'] ?? ''}');
  }
}
