import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityController extends GetxController {
  var isConnected = false.obs;
  final Connectivity connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    connectivity.onConnectivityChanged.listen(updateConnectionStatus);
    checkInitialConnection();
  }

  Future<void> checkInitialConnection() async {
    await checkConnection();
  }

  // 지금 바로 연결 상태를 확인해 isConnected에 반영하고 그 결과를 반환한다.
  // (앱 시작 직후처럼 Rx 초기값(false)에 의존하면 안 되는 곳에서 사용)
  Future<bool> checkConnection() async {
    final result = await connectivity.checkConnectivity();
    updateConnectionStatus(result);
    return isConnected.value;
  }

  void updateConnectionStatus(List<ConnectivityResult> result) {
    // 연결 수단(와이파이·데이터·유선·VPN 등)이 하나라도 있으면 연결된 것으로 본다.
    // 빈 리스트이거나 none만 있으면 연결 안 됨.
    isConnected.value =
        result.any((r) => r != ConnectivityResult.none);
  }
}
