import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String masterKey = dotenv.get('IV_KEY');
String symmetricKey = dotenv.get('SYMMETRIC_KEY');

//sha256 암호화
String sha256_convertHash(String password) {
  final bytes = utf8.encode(password);
  final hash = sha256.convert(bytes);
  return hash.toString();
}

// md5 암호화
String md5_convertHash(String password) {
  final bytes = utf8.encode(password);
  final hash = md5.convert(bytes);
  return hash.toString();
}

// AES256으로 암호화
String aes256_convertHash(String phoneNumber) {
  final key = Key.fromUtf8(symmetricKey);
  final iv = IV.fromUtf8(masterKey);
  final encrypter = Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));
  final encrypted = encrypter.encrypt(phoneNumber, iv: iv);
  final hexString = hex.encode(encrypted.bytes);
  return hexString;
}
