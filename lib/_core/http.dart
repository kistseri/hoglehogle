import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:logger/logger.dart';

final Dio dio = Dio(
  BaseOptions(
    baseUrl: "https://hohoschool.com/hogulAPI",
    contentType: "application/json; charset=utf-8",
  ),
);

/// 서버 인증서가 2026년 갱신되면서 신형 루트(Sectigo Root R46)로 체인이 바뀌었는데,
/// R46이 신뢰 저장소에 없는 구형 안드로이드 기기에서 CERTIFICATE_VERIFY_FAILED 로
/// 핸드셰이크가 실패한다. 번들된 R46 루트를 신뢰 목록에 추가해 해결한다.
/// (withTrustedRoots: true 로 기본 시스템 루트는 그대로 유지)
Future<void> setupDioCertificates() async {
  try {
    final certData = await rootBundle.load('assets/certs/sectigo_r46_root.pem');
    final context = SecurityContext(withTrustedRoots: true);
    try {
      context.setTrustedCertificatesBytes(certData.buffer.asUint8List());
    } on TlsException catch (e) {
      // 이미 신뢰 목록에 존재하면(최신 기기) 무시
      Logger().d('R46 cert already trusted: $e');
    }
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () => HttpClient(context: context),
    );
    // 별도 Dio() 인스턴스, Image.network 등 dart:io HttpClient 전체에도 적용
    HttpOverrides.global = _TrustedRootHttpOverrides(context);
    Logger().d('Dio SecurityContext configured with Sectigo Root R46');
  } catch (e) {
    // 설정 실패해도 앱 구동은 계속 (기본 어댑터 사용)
    Logger().e('setupDioCertificates error = $e');
  }
}

class _TrustedRootHttpOverrides extends HttpOverrides {
  _TrustedRootHttpOverrides(this._context);

  final SecurityContext _context;

  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      super.createHttpClient(context ?? _context);
}

/// POST 후 JSON 결과를 Map으로 돌려줌. 인터넷이 끊기거나 서버 오류·응답 형식이 이상하면 null.
/// (예외가 밖으로 새지 않도록 요청까지 전부 try 안에서)
Future<Map<String, dynamic>?> postJson(String url, [Map<String, dynamic>? data]) async {
  try {
    final response = await dio.post(url, data: data == null ? null : jsonEncode(data));
    if (response.statusCode != 200) return null;
    final body = response.data;
    final decoded = body is String ? jsonDecode(body) : body;
    return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
  } catch (e) {
    Logger().w('요청 실패 $url: $e');
    return null;
  }
}
