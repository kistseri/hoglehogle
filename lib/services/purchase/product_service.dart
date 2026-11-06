import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/data/models/product_data.dart';
import 'package:hoho_hanja/screens/purchase/purchase_screen.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';
import 'package:logger/logger.dart';

// 상품 정보 불러오기
Future<void> productService() async {
  final connectivityController = Get.put(ConnectivityController());
  if (!connectivityController.isConnected.value) {
    failDialog("연결 실패", "인터넷 연결을 확인해주세요");
    return;
  }

  // 요청·응답 처리를 공통 함수로 (시간 초과·서버 오류·빈 응답도 안전하게, C-17·C-18·C-20)
  final resultList = await postJsonList(dotenv.get('PRODUCT_URL'));
  if (resultList == null) {
    failDialog(networkFailTitle, networkFailMessage);
    return;
  }
  if (resultList.isEmpty) {
    failDialog('상점', '판매 중인 상품이 없습니다.');
    return;
  }

  // 응답 결과가 있는 경우
  if (resultList.first['result'] == "0000") {
    final productDataList = resultList.map((item) => ProductData.fromJson(item)).toList();
    final ProductDataController productDataController = Get.put(ProductDataController());
    productDataController.setProductData(productDataList);
    Get.to(() => const PurchaseScreen());
  }
  // 응답 데이터가 오류일 때("9999": 오류)
  else {
    Logger().d('${resultList.first['message']}');
    failDialog('상점', '상품 정보를 불러오지 못했습니다.\n잠시 후 다시 시도해주세요.');
  }
}
