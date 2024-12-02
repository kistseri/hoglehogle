import 'package:get/get.dart';

class RankData {
  final String result;
  final String id;
  final int totalPoints;
  final String nickName;
  final String? hatImage;
  final String? clothesImage;
  final String? eyeImage;
  final String? backgroundImage;
  final String? characterImage;

  RankData({
    required this.result,
    required this.id,
    required this.totalPoints,
    required this.nickName,
    this.hatImage,
    this.clothesImage,
    this.eyeImage,
    this.backgroundImage,
    this.characterImage,
  });

  RankData.fromJson(Map<String, dynamic> json)
      : result = json["result"],
        id = json["id"],
        totalPoints = json["total_points"] ?? 0,
        nickName = json["nickname"],
        clothesImage = json["category10_item_img"],
        hatImage = json["category20_item_img"],
        eyeImage = json["category30_item_img"],
        backgroundImage = json["category40_item_img"],
        characterImage = json["character_img"];
}

class RankDataController extends GetxController {
  List<RankData> _rankDataList = <RankData>[].obs;

  void setRankData(List<RankData> rankDataList) {
    _rankDataList = rankDataList;
    update();
  }

  List<RankData>? get rankDataList => _rankDataList;
}
