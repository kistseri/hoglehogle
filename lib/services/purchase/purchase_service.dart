import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/constants.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/data/models/product_data.dart';
import 'package:hoho_hanja/screens/purchase/purchase_screen.dart';
import 'package:hoho_hanja/services/auth/my_goods_service.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:logger/logger.dart';

// 상품 정보 불러오기
Future<void> purchaseService(PurchaseDetails purchaseDetails, price) async {
  final connectivityController = Get.put(ConnectivityController());
  final loginDataController = Get.put(LoginDataController());
  final productController = Get.put(ProductDataController());

  if (connectivityController.isConnected.value) {
    String url = dotenv.get('PURCHASE_URL');
    String id = loginDataController.loginData.value!.id;

    final matchingProduct = productController.productData!.firstWhere(
        (product) => product.productName == purchaseDetails.productID);

    final Map<String, dynamic> requestData = {
      'id': id,
      'dia': matchingProduct.dia,
      'coin': matchingProduct.coin ?? 0,
      'package_name': 'com.hohoedu.hoglehogle',
      'product_name': purchaseDetails.productID,
      'price': price,
      'transaction_id': purchaseDetails.purchaseID,
      'transaction_date': purchaseDetails.transactionDate,
      'platform': purchaseDetails.verificationData.source,
      'status': purchaseDetails.status.name,
    };

    Logger().d('json = ${jsonEncode(requestData)}');

    // HTTP POST 요청
    final response = await dio.post(url, data: jsonEncode(requestData));

    try {
      // 응답을 성공적으로 받았을 때
      if (response.statusCode == 200) {
        final Map<String, dynamic> resultList = json.decode(response.data);
        final resultValue = resultList['result'];

        // 응답 결과가 있는 경우
        if (resultValue == "0000") {
          await myGoodsService();
        }
        // 응답 데이터가 오류일 때("9999": 오류)
        else {
          Logger().d('${resultList['message']}');
        }
      }
    }
    // 예외처리
    catch (e) {
      Logger().d('e = $e');
    }
  } else {}
}
