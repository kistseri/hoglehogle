import 'dart:async';

import 'package:flutter/services.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:hoho_hanja/data/models/product_data.dart';
import 'package:hoho_hanja/screens/purchase/purchase_screen.dart';
import 'package:hoho_hanja/services/purchase/purchase_controller.dart';
import 'package:hoho_hanja/services/purchase/verify_receipt_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

/// 가짜 스토어 (실제 결제 없음)
class FakeIap implements InAppPurchase {
  final updates = StreamController<List<PurchaseDetails>>.broadcast();
  final completed = <PurchaseDetails>[];
  PurchaseParam? lastParam;
  bool? lastAutoConsume;
  Object? buyError;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => updates.stream;

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async => completed.add(purchase);

  @override
  Future<bool> buyConsumable({required PurchaseParam purchaseParam, bool autoConsume = true}) async {
    lastParam = purchaseParam;
    lastAutoConsume = autoConsume;
    if (buyError != null) throw buyError!;
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// 가짜 결제 서버
class FakeServer {
  Map<String, dynamic>? Function(Map<String, dynamic> body) respond = (_) => status('GRANTED');
  final requests = <Map<String, dynamic>>[];
  Completer<void>? gate; // 응답을 잠시 붙잡아 동시 요청 확인

  static Map<String, dynamic> status(String s) => {
        'success': true,
        'response': {'status': s},
        'error': null,
      };

  Future<Map<String, dynamic>?> post(String url, Object data) async {
    expect(url, purchaseV2Url);
    requests.add(Map<String, dynamic>.from(data as Map));
    if (gate != null) await gate!.future;
    return respond(requests.last);
  }
}

PurchaseDetails purchase({
  String id = 'GPA.3312-1111',
  String product = 'dia_30',
  PurchaseStatus status = PurchaseStatus.purchased,
  String token = 'tok-1',
  bool pendingComplete = true,
}) =>
    PurchaseDetails(
      purchaseID: id,
      productID: product,
      verificationData: PurchaseVerificationData(
        localVerificationData: '{}',
        serverVerificationData: token,
        source: 'google_play',
      ),
      transactionDate: '1762400000000',
      status: status,
    )..pendingCompletePurchase = pendingComplete;

ProductDetails storeProduct(String id, String price) =>
    ProductDetails(id: id, title: id, description: '', price: price, rawPrice: 1200, currencyCode: 'KRW');

void main() {
  late FakeIap iap;
  late FakeServer server;
  late List<PurchaseDetails> consumed;
  late List<String> notices;
  late int granted;
  late List<PurchaseDetails> past;
  String? receipt;
  String? freshReceipt;

  PurchaseController make({required bool android}) => PurchaseController(
        iap: iap,
        post: server.post,
        isAndroid: android,
        appReceipt: () async => receipt,
        refreshReceipt: () async => freshReceipt,
        consume: (p) async => consumed.add(p),
        pastPurchases: () async => past,
        onGranted: () async => granted++,
        notify: (title, _) => notices.add(title),
      );

  setUp(() {
    iap = FakeIap();
    server = FakeServer();
    consumed = [];
    notices = [];
    granted = 0;
    past = [];
    receipt = 'BASE64RECEIPT';
    freshReceipt = null;
  });

  group('안드로이드: 서버 결과별 완료(소비) 처리', () {
    test('GRANTED → 소비 + 코인 갱신 + 구매 완료', () async {
      final c = make(android: true)..start('kid@hohoedu.com');
      final r = await c.deliver(purchase(), showResult: true);
      expect(r, PurchaseResult.granted);
      expect(consumed, hasLength(1));
      expect(granted, 1);
      expect(notices, ['구매 완료']);
      expect(server.requests.single, {
        'platform': 'google',
        'userId': 'kid@hohoedu.com',
        'productId': 'dia_30',
        'purchaseToken': 'tok-1',
        'transactionDate': '1762400000000',
      });
      expect(iap.completed, isEmpty); // 안드로이드는 consume이 확인 처리까지 함
    });

    test('ALREADY → 소비 + 코인 갱신 (중복 지급 없이 정리)', () async {
      server.respond = (_) => FakeServer.status('ALREADY');
      final c = make(android: true)..start('kid@hohoedu.com');
      expect(await c.deliver(purchase()), PurchaseResult.already);
      expect(consumed, hasLength(1));
      expect(granted, 1);
    });

    test('INVALID → 소비(계속 남지 않게), 지급 안내 없음', () async {
      server.respond = (_) => FakeServer.status('INVALID');
      final c = make(android: true)..start('kid@hohoedu.com');
      expect(await c.deliver(purchase(), showResult: true), PurchaseResult.invalid);
      expect(consumed, hasLength(1));
      expect(granted, 0);
      expect(notices, ['결제 확인 실패']);
    });

    test('RETRY → 소비하지 않음 (다음 실행 때 다시)', () async {
      server.respond = (_) => FakeServer.status('RETRY');
      final c = make(android: true)..start('kid@hohoedu.com');
      expect(await c.deliver(purchase(), showResult: true), PurchaseResult.retry);
      expect(consumed, isEmpty);
      expect(granted, 0);
      expect(notices, ['지급 지연']);
    });

    test('인터넷·서버 오류(null), 오류 응답, 이상한 응답 → 모두 RETRY, 소비 안 함', () async {
      final c = make(android: true)..start('kid@hohoedu.com');
      for (final res in <Map<String, dynamic>?>[
        null,
        {
          'success': false,
          'response': null,
          'error': {'message': '요청이 너무 많습니다.', 'status': 429}
        },
        {'success': true, 'response': 'GRANTED'},
        {'success': true, 'response': {'status': 'WHAT'}},
      ]) {
        server.respond = (_) => res;
        expect(await c.deliver(purchase()), PurchaseResult.retry, reason: '$res');
      }
      expect(consumed, isEmpty);
      expect(granted, 0);
    });

    test('실패 후 재시도에서 GRANTED면 그때 소비', () async {
      final answers = ['RETRY', 'GRANTED'];
      server.respond = (_) => FakeServer.status(answers.removeAt(0));
      final c = make(android: true)..start('kid@hohoedu.com');
      expect(await c.deliver(purchase()), PurchaseResult.retry);
      expect(consumed, isEmpty);
      expect(await c.deliver(purchase()), PurchaseResult.granted);
      expect(consumed, hasLength(1));
      expect(server.requests, hasLength(2));
    });

    test('같은 결제를 동시에 두 번 받아도 서버 요청은 1번', () async {
      final c = make(android: true)..start('kid@hohoedu.com');
      server.gate = Completer();
      final a = c.deliver(purchase());
      final b = c.deliver(purchase());
      expect(await b, PurchaseResult.retry); // 처리 중인 결제는 건너뜀 (완료 처리도 안 함)
      server.gate!.complete();
      expect(await a, PurchaseResult.granted);
      expect(server.requests, hasLength(1));
      expect(consumed, hasLength(1));
    });

    test('로그인 시 미소비 결제를 다시 처리 (승인 대기는 제외)', () async {
      past = [
        purchase(id: 'GPA.old', token: 'tok-old'),
        purchase(id: 'GPA.wait', token: 'tok-wait', status: PurchaseStatus.pending),
      ];
      make(android: true).start('kid@hohoedu.com');
      await pumpEventQueue();
      expect(server.requests.map((r) => r['purchaseToken']), ['tok-old']);
      expect(consumed.single.purchaseID, 'GPA.old');
      expect(notices, ['구매 완료']);
    });

    test('미소비 결제가 ALREADY·RETRY면 조용히 처리 (안내 없음)', () async {
      past = [purchase(id: 'a', token: 'a'), purchase(id: 'b', token: 'b')];
      server.respond = (body) => FakeServer.status(body['purchaseToken'] == 'a' ? 'ALREADY' : 'RETRY');
      make(android: true).start('kid@hohoedu.com');
      await pumpEventQueue();
      expect(consumed.map((p) => p.purchaseID), ['a']);
      expect(notices, isEmpty);
    });
  });

  group('iOS: 서버 결과별 finish 처리', () {
    test('GRANTED → finish, 영수증·거래 ID 전송', () async {
      final c = make(android: false)..start('kid@hohoedu.com');
      expect(await c.deliver(purchase(id: '2000000912345678')), PurchaseResult.granted);
      expect(iap.completed, hasLength(1));
      expect(consumed, isEmpty);
      expect(server.requests.single, {
        'platform': 'apple',
        'userId': 'kid@hohoedu.com',
        'productId': 'dia_30',
        'transactionId': '2000000912345678',
        'receiptData': 'BASE64RECEIPT',
        'transactionDate': '1762400000000',
      });
    });

    test('INVALID → finish', () async {
      server.respond = (_) => FakeServer.status('INVALID');
      final c = make(android: false)..start('kid@hohoedu.com');
      await c.deliver(purchase(id: '1'));
      expect(iap.completed, hasLength(1));
    });

    test('RETRY → finish 안 함 (iOS가 다음 실행 때 다시 보내줌)', () async {
      server.respond = (_) => FakeServer.status('RETRY');
      final c = make(android: false)..start('kid@hohoedu.com');
      await c.deliver(purchase(id: '1'));
      expect(iap.completed, isEmpty);
    });

    test('RETRY면 영수증을 새로 받아 한 번 더 보내고, 그때 GRANTED면 finish', () async {
      freshReceipt = 'FRESHRECEIPT';
      server.respond = (body) => FakeServer.status(body['receiptData'] == 'FRESHRECEIPT' ? 'GRANTED' : 'RETRY');
      final c = make(android: false)..start('kid@hohoedu.com');
      expect(await c.deliver(purchase(id: '1')), PurchaseResult.granted);
      expect(server.requests.map((r) => r['receiptData']), ['BASE64RECEIPT', 'FRESHRECEIPT']);
      expect(iap.completed, hasLength(1));
    });

    test('새 영수증도 RETRY거나 영수증이 그대로면 finish 안 함', () async {
      server.respond = (_) => FakeServer.status('RETRY');
      final c = make(android: false)..start('kid@hohoedu.com');
      freshReceipt = 'BASE64RECEIPT'; // 바뀌지 않음 → 다시 보내지 않음
      await c.deliver(purchase(id: '1'));
      expect(server.requests, hasLength(1));
      freshReceipt = 'FRESHRECEIPT';
      await c.deliver(purchase(id: '1'));
      expect(server.requests, hasLength(3));
      expect(iap.completed, isEmpty);
    });

    test('안드로이드는 RETRY여도 영수증 새로 받기 없음', () async {
      freshReceipt = 'FRESHRECEIPT';
      server.respond = (_) => FakeServer.status('RETRY');
      final c = make(android: true)..start('kid@hohoedu.com');
      await c.deliver(purchase());
      expect(server.requests, hasLength(1));
    });

    test('StoreKit2 JWS가 있으면 JWS와 영수증을 함께 보냄', () async {
      final c = make(android: false)..start('kid@hohoedu.com');
      await c.deliver(purchase(id: '2000000912345678', token: 'eyJhbGciOiJFUzI1NiJ9.eyJ0eCI6MX0.c2ln'));
      expect(server.requests.single['jws'], 'eyJhbGciOiJFUzI1NiJ9.eyJ0eCI6MX0.c2ln');
      expect(server.requests.single['receiptData'], 'BASE64RECEIPT');
      expect(iap.completed, hasLength(1));
    });

    test('앱 영수증이 없어도 JWS가 있으면 JWS만 보냄', () async {
      receipt = null;
      final c = make(android: false)..start('kid@hohoedu.com');
      expect(await c.deliver(purchase(id: '1', token: 'h.p.s')), PurchaseResult.granted);
      expect(server.requests.single.containsKey('receiptData'), isFalse);
      expect(server.requests.single['jws'], 'h.p.s');
    });

    test('앱 영수증이 없으면 서버에 안 보내고 RETRY', () async {
      receipt = null;
      final c = make(android: false)..start('kid@hohoedu.com');
      expect(await c.deliver(purchase(id: '1')), PurchaseResult.retry);
      expect(server.requests, isEmpty);
      expect(iap.completed, isEmpty);
    });
  });

  group('전역 리스너', () {
    test('결제 화면 밖에서 온 결제도 리스너가 처리', () async {
      make(android: false).start('kid@hohoedu.com');
      iap.updates.add([purchase(id: '1')]);
      await pumpEventQueue();
      expect(server.requests, hasLength(1));
      expect(iap.completed, hasLength(1));
      expect(notices, ['구매 완료']);
    });

    test('같은 사용자로 start를 두 번 해도 리스너는 하나', () async {
      make(android: false)
        ..start('kid@hohoedu.com')
        ..start('kid@hohoedu.com');
      iap.updates.add([purchase(id: '1')]);
      await pumpEventQueue();
      expect(server.requests, hasLength(1));
    });

    test('로그아웃(stop) 뒤에는 처리하지 않고, 다른 계정으로 로그인하면 그 계정으로', () async {
      final c = make(android: false)..start('kid@hohoedu.com');
      c.stop();
      iap.updates.add([purchase(id: '1')]);
      await pumpEventQueue();
      expect(server.requests, isEmpty);

      c.start('other@hohoedu.com');
      iap.updates.add([purchase(id: '1')]);
      await pumpEventQueue();
      expect(server.requests.single['userId'], 'other@hohoedu.com');
    });

    test('승인 대기는 안내만, 서버 요청·완료 처리 없음, 버튼 막지 않음', () async {
      final c = make(android: true)..start('kid@hohoedu.com');
      c.busy.value = true;
      await c.handleUpdates([purchase(status: PurchaseStatus.pending)]);
      expect(notices, ['결제 대기']);
      expect(server.requests, isEmpty);
      expect(consumed, isEmpty);
      expect(c.busy.value, isFalse);
    });

    test('결제 오류·취소는 지급 없이 정리하고 버튼 다시 사용 가능', () async {
      final c = make(android: false)..start('kid@hohoedu.com');
      c.busy.value = true;
      await c.handleUpdates([purchase(id: '1', status: PurchaseStatus.error)]);
      expect(c.busy.value, isFalse);
      expect(notices, ['결제 실패']);
      c.busy.value = true;
      await c.handleUpdates([purchase(id: '2', status: PurchaseStatus.canceled)]);
      expect(c.busy.value, isFalse);
      expect(iap.completed.map((p) => p.purchaseID), ['1', '2']);
      expect(server.requests, isEmpty);
    });
  });

  group('결제 시작', () {
    test('자동 소비 끄고 사용자 표시값 넣음', () async {
      final c = make(android: true)..start('kid@hohoedu.com');
      await c.buy(storeProduct('dia_30', '₩1,200'));
      expect(iap.lastAutoConsume, isFalse);
      expect(iap.lastParam!.applicationUserName, purchaseUserKey('kid@hohoedu.com'));
      expect(iap.lastParam!.productDetails.id, 'dia_30');
      expect(c.busy.value, isTrue);
    });

    test('결제한 상품의 스토어 가격 문자열을 예전 앱처럼 함께 보냄', () async {
      final c = make(android: true)..start('kid@hohoedu.com');
      await c.buy(storeProduct('dia_30', '₩4,200'));
      await c.deliver(purchase());
      expect(server.requests.single['price'], '₩4,200');
      expect(server.requests.single['transactionDate'], '1762400000000');
    });

    test('iOS는 autoConsume true (플러그인 요구), finish는 서버 결과 보고 따로', () async {
      final c = make(android: false)..start('kid@hohoedu.com');
      await c.buy(storeProduct('dia_30', '₩4,200'));
      expect(iap.lastAutoConsume, isTrue);
      expect(iap.lastParam!.applicationUserName, purchaseUserKey('kid@hohoedu.com'));
    });

    test('iOS 결제 창에서 취소(userCancelled)하면 안내 없이 버튼 다시 사용', () async {
      final c = make(android: false)..start('kid@hohoedu.com');
      iap.buyError = PlatformException(code: 'userCancelled', message: 'StoreKitError');
      await c.buy(storeProduct('dia_30', '₩4,200'));
      expect(c.busy.value, isFalse);
      expect(notices, isEmpty);
    });

    test('같은 상품의 이전 결제가 남아 있으면 이전 결제 처리 중 안내', () async {
      final c = make(android: false)..start('kid@hohoedu.com');
      iap.buyError = PlatformException(code: 'storekit_duplicate_product_object');
      await c.buy(storeProduct('dia_30', '₩4,200'));
      expect(c.busy.value, isFalse);
      expect(notices, ['이전 결제 처리 중']);
    });

    test('그 밖의 결제 시작 오류는 결제 실패 안내', () async {
      final c = make(android: false)..start('kid@hohoedu.com');
      iap.buyError = PlatformException(code: 'storekit_error');
      await c.buy(storeProduct('dia_30', '₩4,200'));
      expect(c.busy.value, isFalse);
      expect(notices, ['결제 실패']);
    });

    test('로그인 전에는 결제 시작 안 함', () async {
      final c = make(android: true);
      await c.buy(storeProduct('dia_30', '₩1,200'));
      expect(iap.lastParam, isNull);
      expect(notices, ['결제 실패']);
    });

    test('진행 중이면 다시 눌러도 결제 1번', () async {
      final c = make(android: true)..start('kid@hohoedu.com');
      await c.buy(storeProduct('dia_30', '₩1,200'));
      iap.lastParam = null;
      await c.buy(storeProduct('dia_30', '₩1,200'));
      expect(iap.lastParam, isNull);
    });

    test('사용자 표시값은 서버(UserKey.of)와 같은 UUID 모양', () {
      expect(purchaseUserKey('kid@hohoedu.com'), '5ff89a53-17bf-0c61-0e74-9517b5404430');
    });
  });

  group('상품 매칭', () {
    ProductData server(String name, int dia) =>
        ProductData(productName: name, dia: dia, color: '0xFF00AAFF', price: 9999, coin: 0);

    test('서버 순서대로, 스토어에 있는 상품만, 가격은 스토어 값', () {
      final list = matchStoreProducts(
        [server('dia_30', 30), server('dia_40', 40), server('dia_50', 50)],
        [storeProduct('dia_50', '₩2,000'), storeProduct('dia_30', '₩1,200'), storeProduct('etc', '₩1')],
      );
      expect(list.map((p) => p.data.dia), [30, 50]);
      expect(list.map((p) => p.store.id), ['dia_30', 'dia_50']);
      expect(list.map((p) => p.store.price), ['₩1,200', '₩2,000']);
    });

    test('스토어 상품이 하나도 없으면 빈 목록', () {
      expect(matchStoreProducts([server('dia_30', 30)], []), isEmpty);
    });
  });
}
