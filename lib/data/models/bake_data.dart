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
      : result = json["result"],
        number = json["ilno"],
        quize = json["quize"],
        answer = json["ans"],
        wrongAnswer1 = json["wans1"],
        wrongAnswer2 = json["wans2"];
}

class BakeDataController extends GetxController {
  List<BakeData> _bakeDataList = <BakeData>[].obs;

  void setBakeDataList(List<BakeData> bakeDataList) {
    _bakeDataList = List.from(bakeDataList)..shuffle();
    update();
  }

  List<BakeData> get bakeDataList => _bakeDataList;

  List<Map<String, dynamic>> get bakeQuetsion => _bakeDataList.map(
        (bakeData) {
          List<String> options = [
            bakeData.answer,
            bakeData.wrongAnswer1,
            bakeData.wrongAnswer2,
          ];
          options.shuffle();
          return {
            "options": options,
            "correct": bakeData.answer,
          };
        },
      ).toList();
}
