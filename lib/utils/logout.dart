import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/data/models/contents_data.dart';
import 'package:hoho_hanja/data/models/goods_data.dart';
import 'package:hoho_hanja/data/models/rank_data.dart';
import 'package:hoho_hanja/screens/auth/login/local_login_screen.dart';
import 'package:hoho_hanja/screens/auth/login/social_login_screen.dart';
import 'package:hoho_hanja/services/auth/login/auto_login.dart';
import 'package:hoho_hanja/services/auth/login/social/google_service.dart';
import 'package:hoho_hanja/services/auth/login/social/kakao_service.dart';
import 'package:hoho_hanja/services/purchase/purchase_controller.dart';

// 중복 탭 막기
bool _loggingOut = false;

/// 로그아웃: 로그인 화면으로 보낸 뒤 저장된 로그인·소셜 로그인을 지움
Future<void> logout() async {
  if (_loggingOut) return;
  _loggingOut = true;
  try {
    Get.offAll(() => const LoginScreen());
    await clearLoginState();
  } finally {
    _loggingOut = false;
  }
}

/// 기기에 남은 로그인 흔적 지우기 (로그아웃·탈퇴 공통)
/// - 자동 로그인 정보, 이메일 로그인 입력칸
/// - 카카오·구글 로그인 (다음에 다른 계정을 고를 수 있도록). 애플은 앱에서 해제하는 기능이 없음.
/// - 코인·다이아·랭킹·콘텐츠 잠금 정보 (다음 계정에 이전 계정 값이 잠깐 보이지 않도록)
/// 마이룸 옷·옷장은 다음 로그인 때 계정이 바뀌면 resetFor가 지움.
/// 로그인 정보(LoginDataController)는 아직 떠 있는 화면이 읽을 수 있어 그대로 두고, 다음 로그인 때 덮어씀.
Future<void> clearLoginState({bool unlinkSocial = false}) async {
  // 결제 리스너 해제 (끝나지 않은 결제는 다음 로그인 때 다시 받아 처리)
  if (Get.isRegistered<PurchaseController>()) Get.find<PurchaseController>().stop();

  final storage = Get.put(const FlutterSecureStorage());
  try {
    await storage.delete(key: storedLoginKey);
  } catch (_) {}

  final loginController = Get.put(LoginController());
  final autoLoginCheckController = Get.put(AutoLoginCheckController());
  loginController.emailController.clear();
  loginController.passwordController.clear();
  autoLoginCheckController.isChecked.value = false;

  if (Get.isRegistered<GoodsDataController>()) {
    Get.find<GoodsDataController>().setGoodsData(GoodsData(coin: 0, dia: 0));
  }
  if (Get.isRegistered<RankDataController>()) {
    Get.find<RankDataController>().setRankData([]);
  }
  if (Get.isRegistered<ContentsDataController>()) {
    Get.find<ContentsDataController>().clear();
  }

  await Future.wait([
    kakaoSignOut(unlink: unlinkSocial),
    googleSignOut(disconnect: unlinkSocial),
  ]);
}
