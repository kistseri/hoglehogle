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
    // 서버가 응답하지 않을 때 무한히 기다리지 않도록 시간 제한 (C-16)
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
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

/// 서버 응답 본문을 Dart 값으로 바꿈.
/// 지금 서버는 JSON을 문자열로 내려주지만, Content-Type이 application/json으로 바뀌면
/// Dio가 이미 Map/List로 풀어서 주므로 두 경우 모두 처리 (C-18)
dynamic decodeBody(dynamic body) {
  if (body is String) return body.trim().isEmpty ? null : jsonDecode(body);
  return body;
}

/// 응답이 Map이면 그대로, [Map, ...] 리스트면 첫 번째 Map. 비어 있거나 형식이 다르면 null (C-20)
Map<String, dynamic>? firstJsonMap(dynamic decoded) {
  if (decoded is Map) return Map<String, dynamic>.from(decoded);
  if (decoded is List && decoded.isNotEmpty && decoded.first is Map) {
    return Map<String, dynamic>.from(decoded.first as Map);
  }
  return null;
}

/// 응답을 Map 리스트로. Map 하나만 오면 [Map]. 형식이 다르면 빈 리스트
List<Map<String, dynamic>> jsonMapList(dynamic decoded) {
  if (decoded is Map) return [Map<String, dynamic>.from(decoded)];
  if (decoded is List) {
    return decoded.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
  }
  return [];
}

/// POST 후 디코딩한 응답을 돌려줌. 인터넷이 끊기거나 시간 초과·서버 오류·응답 형식이 이상하면 null.
/// (예외가 밖으로 새지 않도록 요청까지 전부 try 안에서)
/// [data]는 Map 또는 toJson()이 있는 객체
Future<dynamic> postDecoded(String url, [Object? data]) async {
  try {
    final response = await dio.post(url, data: data == null ? null : jsonEncode(data));
    if (response.statusCode != 200) return null;
    return decodeBody(response.data);
  } catch (e) {
    Logger().w('요청 실패 $url: $e');
    return null;
  }
}

/// POST 후 JSON 결과를 Map으로 돌려줌 ([Map] 리스트면 첫 번째). 실패하면 null.
Future<Map<String, dynamic>?> postJson(String url, [Object? data]) async {
  return firstJsonMap(await postDecoded(url, data));
}

/// POST 후 JSON 결과를 Map 리스트로 돌려줌. 요청 자체가 실패하면 null, 응답이 비어 있으면 빈 리스트.
Future<List<Map<String, dynamic>>?> postJsonList(String url, [Object? data]) async {
  final decoded = await postDecoded(url, data);
  if (decoded == null) return null;
  return jsonMapList(decoded);
}

/// 서버 요청이 실패했을 때 쓰는 공통 안내 문구
const String networkFailTitle = '연결 실패';
const String networkFailMessage = '서버와 연결하지 못했습니다.\n잠시 후 다시 시도해주세요.';
