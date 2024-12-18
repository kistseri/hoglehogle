import 'package:get/get.dart';

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
      productName: json['product_name'],
      dia: json['dia'],
      coin: json['coin'] ?? 0,
      color: json['color'],
      price: json['price'],
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
