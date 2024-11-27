import 'package:get/get.dart';

class MatchingData {
  final String frontImage;
  final String backImage;
  final String sound;

  MatchingData({
    required this.frontImage,
    required this.backImage,
    required this.sound,
  });

  MatchingData.fromJson(Map<String, dynamic> json)
      : frontImage = json["f_phaseImg"],
        backImage = json["b_phaseImg"],
        sound = json["m_phasemp"];
}

class MatchingDataController extends GetxController {
  List<MatchingData> _matchingDataList = <MatchingData>[].obs;

  void setMatchingDataList(List<MatchingData> matchingDataList) {
    _matchingDataList = matchingDataList;
    update();
  }

  List<MatchingData> get matchingData => _matchingDataList;
}
