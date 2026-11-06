import 'package:get/get.dart';

class MatchingMenuData {
  final String phase;
  final String gubun;
  final String subject;
  final String hanja;

  MatchingMenuData({
    required this.phase,
    required this.gubun,
    required this.subject,
    required this.hanja,
  });

  MatchingMenuData.fromJson(Map<String, dynamic> json)
      : phase = json["phase"]?.toString() ?? '',
        gubun = json["gubun"]?.toString() ?? '',
        subject = json["subject"]?.toString() ?? '',
        hanja = (json["hanja_list"]?.toString() ?? '').replaceAll(',', ' ');
}

class MatchingMenuDataController extends GetxController {
  List<MatchingMenuData> _matchingMenuDataList = <MatchingMenuData>[]; // 화면이 값을 지켜보지 않고 열기 전에 넣으므로 일반 List + update() (C-38)

  void setMatchingMenuData(List<MatchingMenuData> matchingMenuDataList) {
    _matchingMenuDataList = matchingMenuDataList;

    update();
  }

  List<MatchingMenuData>? get matchingMenuDataList => _matchingMenuDataList;
}
