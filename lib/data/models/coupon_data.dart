import 'package:get/get.dart';

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
      : id = json["id"],
        totalPoints = json["total_points"],
        nickName = json["nickname"];
}

class RankDataController extends GetxController {
  List<CouponData> _rankDataList = <CouponData>[].obs;

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
