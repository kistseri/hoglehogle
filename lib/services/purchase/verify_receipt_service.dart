import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:logger/logger.dart';

/// 결제 서버 v2: 검증 + 중복 확인 + 다이아 지급을 서버가 한 번에 처리 (C-05, R-03)
/// http 사용 (11/06 결정): cafe24 https(443)가 Tomcat에 연결되지 않음(403).
/// 남의 영수증 가로채기·중복 지급은 서버의 사용자 확인·영수증표로 막힘. https가 연결되면 https로 바꾸고
/// AndroidManifest의 usesCleartextTraffic 삭제 (R-11, C-14)
const String purchaseV2Url = 'http://stst88981.cafe24.com/api/v2/purchase';

/// 서버 처리 결과
/// - granted: 이번에 지급됨, already: 이미 지급된 결제 → 둘 다 결제 완료 처리
/// - invalid: 가짜·취소·다른 상품 → 다시 보내도 안 되므로 완료 처리(계속 남지 않게)
/// - retry: 서버·스토어·인터넷 문제 → 완료 처리하지 않고 다음 앱 실행 때 다시
enum PurchaseResult { granted, already, invalid, retry }

typedef PostJsonFn = Future<Map<String, dynamic>?> Function(String url, Object data);

/// 결제 서버에 보내고 결과 받기. 요청 실패·형식 오류는 retry
Future<PurchaseResult> requestPurchaseV2(Map<String, dynamic> body, {PostJsonFn post = postJson}) async {
  final res = await post(purchaseV2Url, body);
  // 디버그 빌드에서만 출력 (영수증 원문은 남기지 않음)
  Logger().d('결제 서버 응답 ${body['productId']}: $res');
  final response = res?['response'];
  final status = response is Map ? response['status'] : null;
  return switch (status) {
    'GRANTED' => PurchaseResult.granted,
    'ALREADY' => PurchaseResult.already,
    'INVALID' => PurchaseResult.invalid,
    _ => PurchaseResult.retry,
  };
}

/// 결제에 붙이는 사용자 표시값 (서버 UserKey.of와 같은 계산).
/// sha256(id) 앞 32자리를 UUID 모양으로: iOS StoreKit2 appAccountToken이 UUID만 받음.
/// 안드로이드는 obfuscatedAccountId로 영수증에 남아 서버가 사용자 일치를 확인함 (R-06)
String purchaseUserKey(String userId) {
  final h = sha256.convert(utf8.encode(userId)).toString();
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20, 32)}';
}

/// iOS 앱 영수증(base64). 없으면 null
Future<String?> getAppReceipt() async {
  try {
    return await const MethodChannel("app_receipt_channel").invokeMethod<String>("getAppReceipt");
  } on PlatformException catch (e) {
    Logger().e("영수증을 가져오지 못함: $e");
    return null;
  }
}
