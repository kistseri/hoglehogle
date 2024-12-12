import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/constants.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/data/models/product_data.dart';
import 'package:hoho_hanja/screens/purchase/purchase_screen.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:logger/logger.dart';

// 상품 정보 불러오기
Future<void> productService() async {
  final connectivityController = Get.put(ConnectivityController());
  if (connectivityController.isConnected.value) {
    String url = dotenv.get('PRODUCT_URL');

    // HTTP POST 요청
    final response = await dio.post(url);

    try {
      // 응답을 성공적으로 받았을 때
      if (response.statusCode == 200) {
        final List<dynamic> resultList = response.data;

        // 응답 결과가 있는 경우
        if (resultList[0]['result'] == "0000") {
          List<ProductData> productDataList =
              resultList.map((item) => ProductData.fromJson(item)).toList();
          final ProductDataController productDataController =
              Get.put(ProductDataController());
          productDataController.setProductData(productDataList);

          Get.to(() => const PurchaseScreen());
        }
        // 응답 데이터가 오류일 때("9999": 오류)
        else {
          Logger().d('${resultList[0]['message']}');
        }
      }
    }
    // 예외처리
    catch (e) {
      Logger().d('e = $e');
    }
  } else {}
}

