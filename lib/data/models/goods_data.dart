import 'package:get/get.dart';
import 'package:intl/intl.dart';

class GoodsData {
  final int coin;
  final int dia;

  GoodsData({required this.coin, required this.dia});

  factory GoodsData.fromJson(Map<String, dynamic> json) {
    return GoodsData(
      coin: json['coin'],
      dia: json['dia'],
    );
  }
}

// 데이터 컨트롤러
class GoodsDataController extends GetxController {
  GoodsData? _goodsData;
  final RxString formattedCoin = ''.obs;
  final RxString formattedDia = ''.obs;

  void setGoodsData(GoodsData goodsData) {
    _goodsData = goodsData;

    final formatter = NumberFormat('#,###');
    formattedCoin.value = formatter.format(_goodsData!.coin);
    formattedDia.value = formatter.format(_goodsData!.dia);

    update();
  }

  GoodsData? get goodsData => _goodsData;
}
