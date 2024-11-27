import 'package:get/get.dart';

class IdiomData {
  final String result;
  final String number;
  final String quize1;
  final String quize2;
  final String hanja1;
  final String hanja2;
  final String hanja3;
  final String hanja4;
  final int randomNum;
  final String selectedHanja;
  final String wrongAnswer;

  IdiomData({
    required this.result,
    required this.number,
    required this.quize1,
    required this.quize2,
    required this.hanja1,
    required this.hanja2,
    required this.hanja3,
    required this.hanja4,
    required this.randomNum,
    required this.selectedHanja,
    required this.wrongAnswer,
  });

  IdiomData.fromJson(Map<String, dynamic> json)
      : result = json["result"],
        number = json["ilno"],
        quize1 = json["quize1"],
        quize2 = json["quize2"],
        hanja1 = json["hanja1"],
        hanja2 = json["hanja2"],
        hanja3 = json["hanja3"],
        hanja4 = json["hanja4"],
        randomNum = json["random_num"],
        selectedHanja = json["selected_hanja"],
        wrongAnswer = json["wnas"];
}

class IdiomDataController extends GetxController {
  List<IdiomData> _idiomDataList = <IdiomData>[].obs;

  void setIdiomDataList(List<IdiomData> idiomDataList) {
    _idiomDataList = idiomDataList;
    update();
  }

  List<IdiomData> get idiomDataList => _idiomDataList;

  List<Map<String, dynamic>> get idiom => _idiomDataList.map(
        (idiomData) {
          return {
            "ilno": idiomData.number,
            "quize1": idiomData.quize1,
            "quize2": idiomData.quize2,
            "hanja1": idiomData.hanja1,
            "hanja2": idiomData.hanja2,
            "hanja3": idiomData.hanja3,
            "hanja4": idiomData.hanja4,
            "random_num": idiomData.randomNum,
            "options": [idiomData.selectedHanja, idiomData.wrongAnswer],
          };
        },
      ).toList();
}
