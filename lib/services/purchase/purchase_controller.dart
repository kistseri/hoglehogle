import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/services/auth/my_goods_service.dart';
import 'package:hoho_hanja/services/purchase/verify_receipt_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:logger/logger.dart';

/// 등록된 결제 컨트롤러를 돌려줌. 없으면(핫 리로드 등으로 main을 안 거친 경우) 만들고,
/// 로그인한 상태인데 리스너가 아직 없으면 시작
PurchaseController ensurePurchaseController() {
  final c = Get.isRegistered<PurchaseController>()
      ? Get.find<PurchaseController>()
      : Get.put(PurchaseController(), permanent: true);
  final id = Get.isRegistered<LoginDataController>() ? Get.find<LoginDataController>().userId : null;
  if (id != null) c.start(id);
  return c;
}

/// 앱 전체 결제 처리 (C-04). main에서 permanent로 1개 만들고, 로그인하면 start, 로그아웃하면 stop.
/// 결제 화면 밖에서 끝난 결제(승인 대기 후 승인, 앱 강제 종료 후 재실행)도 여기서 받아 처리.
/// 결제 화면은 [busy]만 보고 버튼을 막음.
class PurchaseController extends GetxController {
  PurchaseController({
    InAppPurchase? iap,
    PostJsonFn? post,
    bool? isAndroid,
    Future<String?> Function()? appReceipt,
    Future<String?> Function()? refreshReceipt,
    Future<void> Function(PurchaseDetails)? consume,
    Future<List<PurchaseDetails>> Function()? pastPurchases,
    Future<void> Function()? onGranted,
    void Function(String title, String message)? notify,
  })  : _iapOverride = iap,
        _post = post ?? postJson,
        _isAndroid = isAndroid ?? Platform.isAndroid,
        _appReceipt = appReceipt ?? getAppReceipt,
        _refreshReceipt = refreshReceipt,
        _consume = consume,
        _pastPurchases = pastPurchases,
        _onGranted = onGranted ?? myGoodsService,
        _notify = notify ?? ((t, m) => Get.snackbar(t, m, snackPosition: SnackPosition.BOTTOM));

  final InAppPurchase? _iapOverride;
  final PostJsonFn _post;
  final bool _isAndroid;
  final Future<String?> Function() _appReceipt;
  final Future<String?> Function()? _refreshReceipt;
  final Future<void> Function(PurchaseDetails)? _consume;
  final Future<List<PurchaseDetails>> Function()? _pastPurchases;
  final Future<void> Function() _onGranted;
  final void Function(String, String) _notify;

  // 테스트에서는 플러그인을 만들지 않도록 처음 쓸 때 가져옴
  InAppPurchase get _iap => _iapOverride ?? InAppPurchase.instance;

  /// 결제 진행 중 (결제 화면 버튼 막기·로딩 표시)
  final busy = false.obs;

  StreamSubscription<List<PurchaseDetails>>? _sub;
  String? _userId;
  // 리스너와 미소비 결제 복구가 같은 결제를 동시에 보내지 않도록
  final Set<String> _inFlight = {};

  String? get userId => _userId;

  /// 스토어 표시 가격 (productId → "₩4,200"). 예전 앱처럼 지급 요청 price로 보냄. 결제 화면이 채움
  final Map<String, String> storePrices = {};

  /// 로그인 후 호출. 같은 사용자면 다시 등록하지 않음
  void start(String userId) {
    if (_sub != null && _userId == userId) return;
    stop();
    _userId = userId;
    _sub = _iap.purchaseStream.listen(handleUpdates, onError: (e) => Logger().e('결제 스트림 오류: $e'));
    // 안드로이드는 앱을 다시 켜도 끝나지 않은 결제를 스트림으로 주지 않으므로 직접 조회 (C-03).
    // iOS(StoreKit2)는 리스너를 붙이면 끝나지 않은 거래를 다시 보내줌.
    if (_isAndroid) recoverAndroidPurchases();
  }

  /// 로그아웃 시 호출
  void stop() {
    _sub?.cancel();
    _sub = null;
    _userId = null;
    busy.value = false;
  }

  @override
  void onClose() {
    stop();
    super.onClose();
  }

  /// 결제 시작. 자동 소비는 끄고 지급이 확인된 뒤에 소비 (C-02)
  Future<void> buy(ProductDetails product) async {
    final id = _userId;
    if (id == null) {
      _notify('결제 실패', '로그인 정보를 확인할 수 없습니다.\n다시 로그인해주세요.');
      return;
    }
    if (busy.value) return;
    busy.value = true;
    storePrices[product.id] = product.price;
    try {
      final started = await _iap.buyConsumable(
        purchaseParam: PurchaseParam(productDetails: product, applicationUserName: purchaseUserKey(id)),
        // Android만 자동 소비를 끔. iOS 플러그인은 false면 assert로 막음 (iOS는 finish를 completePurchase로 따로 함)
        autoConsume: !_isAndroid,
      );
      if (!started) busy.value = false;
    } on PlatformException catch (e) {
      busy.value = false;
      // iOS(StoreKit2)는 결제 창에서 취소하면 예외로 알려줌. 사용자가 취소한 것이라 안내 없음
      if (e.code == 'userCancelled') return;
      if (e.code == 'storekit_duplicate_product_object') {
        // 같은 상품의 이전 결제가 아직 지급 확인 전이라 iOS가 새 결제를 막음. 앱을 다시 켜면 이전 결제부터 처리됨
        _notify('이전 결제 처리 중', '이전에 결제한 같은 상품을 아직 처리하고 있습니다.\n앱을 다시 실행하면 자동으로 지급됩니다.');
        return;
      }
      Logger().e('결제 시작 실패: $e');
      _notify('결제 실패', '결제를 시작하지 못했습니다.\n잠시 후 다시 시도해주세요.');
    } catch (e) {
      Logger().e('결제 시작 실패: $e');
      busy.value = false;
      _notify('결제 실패', '결제를 시작하지 못했습니다.\n잠시 후 다시 시도해주세요.');
    }
  }

  Future<void> handleUpdates(List<PurchaseDetails> list) async {
    for (final p in list) {
      switch (p.status) {
        case PurchaseStatus.pending:
          // 보호자 승인 등은 며칠 걸릴 수 있어 버튼을 막아 두지 않음. 승인되면 리스너가 받아 지급
          busy.value = false;
          _notify('결제 대기', '결제 승인을 기다리고 있습니다.\n승인되면 자동으로 지급됩니다.');
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await deliver(p, showResult: true);
          break;
        case PurchaseStatus.error:
          Logger().e('결제 오류: ${p.error}');
          busy.value = false;
          await _completeIfNeeded(p);
          _notify('결제 실패', '결제 중 오류가 발생했습니다.');
          break;
        case PurchaseStatus.canceled:
          busy.value = false;
          await _completeIfNeeded(p);
          break;
      }
    }
  }

  /// 결제 서버에 보내고, 결과가 확정(지급·이미 지급·무효)일 때만 결제를 끝냄 (C-03, C-05).
  /// retry면 끝내지 않아서 다음 실행 때 다시 처리됨.
  Future<PurchaseResult> deliver(PurchaseDetails p, {bool showResult = false}) async {
    final key = p.purchaseID ?? p.verificationData.serverVerificationData;
    if (!_inFlight.add(key)) return PurchaseResult.retry;
    try {
      final result = await _send(p);
      Logger().d('결제 처리 결과 ${p.productID}: $result');
      if (result != PurchaseResult.retry) await _finish(p);
      if (result == PurchaseResult.granted || result == PurchaseResult.already) await _onGranted();
      if (showResult) _showResult(result);
      return result;
    } finally {
      _inFlight.remove(key);
      busy.value = false;
    }
  }

  Future<PurchaseResult> _send(PurchaseDetails p) async {
    final id = _userId;
    if (id == null) return PurchaseResult.retry;
    final Map<String, dynamic> body;
    if (_isAndroid) {
      body = {
        'platform': 'google',
        'userId': id,
        'productId': p.productID,
        // 안드로이드 serverVerificationData = purchaseToken
        'purchaseToken': p.verificationData.serverVerificationData,
        ..._legacyFields(p),
      };
    } else {
      // StoreKit2는 serverVerificationData가 애플이 서명한 거래 JWS. 결제 즉시 서버가 판정할 수 있어 우선 사용.
      // 앱 영수증은 StoreKit1 기기·예전 서버용으로 함께 보냄 (결제 직후엔 방금 거래가 없을 수 있음)
      final sv = p.verificationData.serverVerificationData;
      final jws = sv.split('.').length == 3 ? sv : null;
      final receipt = await _appReceipt();
      final hasReceipt = receipt != null && receipt.isNotEmpty;
      if (p.purchaseID == null || (jws == null && !hasReceipt)) return PurchaseResult.retry;
      body = {
        'platform': 'apple',
        'userId': id,
        'productId': p.productID,
        'transactionId': p.purchaseID,
        if (jws != null) 'jws': jws,
        if (hasReceipt) 'receiptData': receipt,
        ..._legacyFields(p),
      };
    }
    final result = await requestPurchaseV2(body, post: _post);
    if (_isAndroid || result != PurchaseResult.retry) return result;

    // iOS(StoreKit2)는 결제 직후 앱 영수증에 방금 거래가 아직 없을 수 있음 → 영수증을 새로 받아 한 번 더
    final fresh = await _freshReceipt();
    if (fresh == null || fresh.isEmpty || fresh == body['receiptData']) return result;
    return requestPurchaseV2({...body, 'receiptData': fresh}, post: _post);
  }

  Future<String?> _freshReceipt() async {
    try {
      if (_refreshReceipt != null) return await _refreshReceipt();
      final data = await _iap
          .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>()
          .refreshPurchaseVerificationData();
      return data?.serverVerificationData;
    } catch (e) {
      Logger().w('영수증 새로 받기 실패: $e');
      return null;
    }
  }

  /// 메인 API purchase.html에 예전 앱이 보내던 값 (스토어 가격 문자열·결제 시각). 없으면 서버가 채움
  Map<String, String> _legacyFields(PurchaseDetails p) => {
        if (storePrices[p.productID] != null) 'price': storePrices[p.productID]!,
        if (p.transactionDate != null) 'transactionDate': p.transactionDate!,
      };

  /// 안드로이드: 소비(확인 처리 포함, 같은 상품 다시 구매 가능). iOS: finish
  Future<void> _finish(PurchaseDetails p) async {
    try {
      if (_isAndroid) {
        final consume = _consume ??
            (p) => _iap.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>().consumePurchase(p);
        await consume(p);
      } else if (p.pendingCompletePurchase) {
        await _iap.completePurchase(p);
      }
    } catch (e) {
      // 다음 실행 때 다시 받으면 서버가 ALREADY로 답하므로 중복 지급 없음
      Logger().e('결제 완료 처리 실패: $e');
    }
  }

  Future<void> _completeIfNeeded(PurchaseDetails p) async {
    if (!p.pendingCompletePurchase) return;
    try {
      await _iap.completePurchase(p);
    } catch (e) {
      Logger().e('결제 정리 실패: $e');
    }
  }

  /// 안드로이드 미소비 결제 다시 처리 (앱 시작·로그인 시, C-03). 결과 안내는 지급됐을 때만
  Future<void> recoverAndroidPurchases() async {
    try {
      final past = await (_pastPurchases ?? _queryAndroidPast)();
      for (final p in past.where((p) => p.status == PurchaseStatus.purchased)) {
        final result = await deliver(p);
        if (result == PurchaseResult.granted) _showResult(result);
      }
    } catch (e) {
      Logger().e('미소비 결제 조회 실패: $e');
    }
  }

  Future<List<PurchaseDetails>> _queryAndroidPast() async {
    final res = await _iap.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>().queryPastPurchases();
    return res.pastPurchases;
  }

  void _showResult(PurchaseResult result) {
    switch (result) {
      case PurchaseResult.granted:
      case PurchaseResult.already:
        _notify('구매 완료', '다이아 구매가 완료되었습니다.');
      case PurchaseResult.invalid:
        _notify('결제 확인 실패', '결제를 확인할 수 없습니다.\n문제가 계속되면 고객센터로 문의해주세요.');
      case PurchaseResult.retry:
        _notify('지급 지연', '결제는 접수되었지만 아직 지급하지 못했습니다.\n앱을 다시 실행하면 자동으로 지급됩니다.');
    }
  }
}
