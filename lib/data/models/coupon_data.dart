import 'package:get/get.dart';
import 'package:hoho_hanja/data/models/json_parse.dart';

class CouponData {
  // final String result;
  final String id;
  final int totalPoints;
  final String nickName;

  CouponData({
    // required this.result,
    required this.id,
    required this.totalPoints,
    required this.nickName,
  });

  CouponData.fromJson(Map<String, dynamic> json)
      // : result = json["result"],
      : id = jsonStr(json["id"]),
        totalPoints = jsonInt(json["total_points"]),
        nickName = jsonStr(json["nickname"]);
}

class CouponDataController extends GetxController {
  List<CouponData> _rankDataList = <CouponData>[]; // 화면이 값을 지켜보지 않고 열기 전에 넣으므로 일반 List + update() (C-38)

  void setRankData(List<CouponData> rankDataList) {
    _rankDataList = rankDataList;
    update();
  }

  List<CouponData>? get rankDataList => _rankDataList;

  List<Map<String, dynamic>> get quiz => _rankDataList.map(
        (rankData) {
          return {
            // "result": rankData.result,
            "id": rankData.id,
            "total_points": rankData.totalPoints,
            "nickname": rankData.nickName,
          };
        },
      ).toList();
}
