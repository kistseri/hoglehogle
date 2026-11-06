import 'dart:convert';

import 'package:crypto/crypto.dart';

// 비밀번호 sha256 (서버가 이 값으로 로그인 확인)
// 안 쓰던 AES256·md5 함수와 .env의 AES 키(IV_KEY·SYMMETRIC_KEY)는 삭제 (C-13)
String sha256_convertHash(String password) {
  final bytes = utf8.encode(password);
  final hash = sha256.convert(bytes);
  return hash.toString();
}
