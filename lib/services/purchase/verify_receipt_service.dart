import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/services/purchase/purchase_service.dart';
import 'package:hoho_hanja/utils/formatter.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

Future<bool> verifyGoogleReceipt(PurchaseDetails purchaseDetails, String price) async {
  const url = 'http://stst88981.cafe24.com/api/verify-receipt/google';

  // ✅ 구글은 purchaseToken만 추출
  final Map<String, dynamic> verificationData = jsonDecode(
    purchaseDetails.verificationData.localVerificationData,
  );

  final requestData = {
    'packageName': 'com.hohoedu.hoglehogle',
    'productId': purchaseDetails.productID,
    'token': verificationData['purchaseToken'],
  };

  return _sendVerifyRequest(url, requestData, purchaseDetails, price);
}

class ReceiptHelper {
  static const _channel = MethodChannel("app_receipt_channel");

  static Future<String?> getAppReceipt() async {
    try {
      final receipt = await _channel.invokeMethod<String>("getAppReceipt");
      return receipt;
    } on PlatformException catch (e) {
      print("❌ Failed to get receipt: $e");
      return null;
    }
  }
}

Future<bool> verifyAppleReceipt(PurchaseDetails purchaseDetails, String price, {String? statusOverride}) async {
  const url = 'http://stst88981.cafe24.com/api/verify-receipt/apple';
  // const url = 'http://192.168.0.28:8080/api/verify-receipt/apple';

  final receiptData = await ReceiptHelper.getAppReceipt();

  print('===== receiptData: $receiptData =====');
  if (receiptData == null || receiptData.isEmpty) {
    print('===== receiptData NULL =====');
    Logger().e("❌ No App Receipt available");
    return false;
  }

  final requestData = {
    'receiptData':  receiptData,
  };

  return _sendVerifyRequest(url, requestData, purchaseDetails, price);
}

// 공통 처리
Future<bool> _sendVerifyRequest(String url, Map<String, dynamic> requestData, PurchaseDetails purchaseDetails, String price) async {
  try {
    Logger().d(requestData);
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestData),
    );
    print('===== Response: ${response.body} ====='); // ✅ 추가
    print('===== StatusCode: ${response.statusCode} ====='); // ✅ 추가
    Logger().d('Response: ${response.body}');

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      print('===== StatusCode: $result ====='); // ✅ 추가
      print('=================${result['status']}=============');
      if (result['status'] == 0) {
        await purchaseService(purchaseDetails, price);
        return true;
      }
      if (result['purchaseState'] == 0 || result['acknowledged'] == true) {
        await purchaseService(purchaseDetails, price);
        return true;
      }

      Logger().w('검증 실패: ${result['status'] ?? result['message']}');
    } else {
      Logger().e('HTTP Error: ${response.statusCode}');
    }
  } catch (e, st) {
    Logger().e('검증 요청 예외 $e, $st');
  }
  return false;
}
