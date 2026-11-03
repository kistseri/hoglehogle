import 'package:get/get.dart';

class BakeData {
  final String result;
  final String number;
  final String quize;
  final String answer;
  final String wrongAnswer1;
  final String wrongAnswer2;

  BakeData({
    required this.result,
    required this.number,
    required this.quize,
    required this.answer,
    required this.wrongAnswer1,
    required this.wrongAnswer2,
  });

  BakeData.fromJson(Map<String, dynamic> json)
      : result = json["result"]?.toString() ?? '',
        number = json["ilno"]?.toString() ?? '',
        quize = json["quize"]?.toString() ?? '',
        answer = json["ans"]?.toString() ?? '',
        wrongAnswer1 = json["wans1"]?.toString() ?? '',
        wrongAnswer2 = json["wans2"]?.toString() ?? '';
}

class BakeDataController extends GetxController {
  List<BakeData> _bakeDataList = <BakeData>[].obs;
  List<List<String>> _options = [];

  // 문제 순서와 문제별 보기 순서는 불러올 때 한 번만 섞음
  void setBakeDataList(List<BakeData> bakeDataList) {
    _bakeDataList = List.from(bakeDataList)..shuffle();
    _options = _bakeDataList
        .map((d) => [d.answer, d.wrongAnswer1, d.wrongAnswer2]..shuffle())
        .toList();
    update();
  }

  List<BakeData> get bakeDataList => _bakeDataList;

  // index번 문제의 보기 3개
  List<String> optionsOf(int index) => _options[index];
}
