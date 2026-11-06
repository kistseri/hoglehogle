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
      : frontImage = json["f_phaseImg"]?.toString() ?? '',
        backImage = json["b_phaseImg"]?.toString() ?? '',
        sound = json["m_phasemp"]?.toString() ?? '';
}

class MatchingDataController extends GetxController {
  List<MatchingData> _matchingDataList = <MatchingData>[]; // 화면이 값을 지켜보지 않고 열기 전에 넣으므로 일반 List + update() (C-38)

  void setMatchingDataList(List<MatchingData> matchingDataList) {
    _matchingDataList = matchingDataList;
    update();
  }

  List<MatchingData> get matchingData => _matchingDataList;
}
