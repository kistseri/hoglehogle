import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/services/auth/my_goods_service.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';

// 쿠폰 등록 (성공하면 true, 창 닫기·안내는 부르는 쪽에서)
Future<bool> couponService(String coupon) async {
  final connectivityController = Get.put(ConnectivityController());
  final loginDataController = Get.put(LoginDataController());
  final id = loginDataController.loginData.value?.id;

  if (!connectivityController.isConnected.value) {
    failDialog("연결 실패", "인터넷 연결을 확인해주세요");
    return false;
  }
  if (id == null || id.isEmpty) {
    failDialog('등록 실패', '로그인 정보를 찾을 수 없어요.\n다시 로그인해주세요.');
    return false;
  }

  final result = await postJson(dotenv.get('COUPON_URL'), {'id': id, 'coupon': coupon});
  if (result == null) {
    failDialog('등록 실패', '잠시 후 다시 시도해주세요.');
    return false;
  }
  if (result['result'] == "0000") {
    myGoodsService(); // 쿠폰으로 받은 코인·다이아 반영
    return true;
  }
  failDialog('등록 실패', '${result['message'] ?? '쿠폰 번호를 확인해주세요.'}');
  return false;
}
