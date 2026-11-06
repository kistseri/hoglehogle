import 'package:get/get.dart';
import 'package:hoho_hanja/data/models/json_parse.dart';

class ProductData {
  final String productName;
  final int dia;
  final int coin;
  final String color;
  final int price;

  ProductData({
    required this.productName,
    required this.dia,
    required this.color,
    required this.price,
    required this.coin,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(
      // 서버 값 타입이 바뀌어도 TypeError 없이 받음 (C-37)
      productName: jsonStr(json['product_name']),
      dia: jsonInt(json['dia']),
      coin: jsonInt(json['coin']),
      color: jsonStr(json['color']),
      price: jsonInt(json['price']),
    );
  }
}

// 데이터 컨트롤러
class ProductDataController extends GetxController {
  List<ProductData>? _productDataList;

  void setProductData(List<ProductData> productDataList) {
    _productDataList = productDataList;
    update();
  }

  List<ProductData>? get productData => _productDataList;
}
