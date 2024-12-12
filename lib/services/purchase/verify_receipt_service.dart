import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/services/purchase/purchase_service.dart';
import 'package:hoho_hanja/utils/formatter.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logger/logger.dart';

// 결제 내역 검증하기
Future<void> verifyReceiptService(
    PurchaseDetails purchaseDetails, int price, platform) async {
  final connectivityController = Get.put(ConnectivityController());

  if (connectivityController.isConnected.value) {
    String url = '';
    // URL 설정
    if (platform == 'google') {
      url = 'http://ststallpass.cafe24.com/api/verify-receipt/google';
    } else if (platform == 'apple') {
      url = 'http://ststallpass.cafe24.com/api/verify-receipt/apple';
    }

    // 요청 데이터 생성
    final Map<String, dynamic> requestData = {
      'packageName': 'com.hohoedu.hoglehogle',
      'productId': purchaseDetails.productID,
      'token': purchaseDetails.verificationData.serverVerificationData,
      'receiptData': purchaseDetails.verificationData.localVerificationData,
    };
    Logger().d(jsonEncode(requestData));

    try {
      // HTTP POST 요청
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestData),
      );

      // 응답 처리
      if (response.statusCode == 200) {
        final dynamic resultList = jsonDecode(response.body);

        if (resultList['message'] != "null") {
          // 성공 로직 추가
          await purchaseService(purchaseDetails, price);
          Logger().d('검증 완료');
        } else {
          Logger().d('Error: ${resultList['message']}');
        }
      } else {
        Logger().d('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      Logger().d('Exception: $e');
    }
  } else {
    Logger().d('No internet connection.');
  }
}
