import 'package:get/get.dart';

class DefineData {
  final String result;
  final String number;
  final String typechk;
  final String? questionImg;
  final String? questionText;
  final String answer;
  final String wrongAnswer;
  final String note;

  DefineData({
    required this.result,
    required this.number,
    required this.typechk,
    required this.questionImg,
    required this.questionText,
    required this.answer,
    required this.wrongAnswer,
    required this.note,
  });

  DefineData.fromJson(Map<String, dynamic> json)
      : result = json["result"],
        number = json["ilno"],
        typechk = json["typechk"],
        questionImg = json["questionImg"],
        questionText = json["questionText"],
        answer = json["ans"],
        wrongAnswer = json["wans"],
        note = json["note"];
}

class DefineDataController extends GetxController {
  List<DefineData> _defineDataList = <DefineData>[].obs;

  void setDefineDataList(List<DefineData> defineDataList) {
    _defineDataList = defineDataList;
    update();
  }

  List<DefineData>? get defineDataList => _defineDataList;

  List<Map<String, dynamic>> get quiz => _defineDataList.map(
        (defineData) {
          return {
            "type": defineData.typechk,
            "image": defineData.questionImg ?? "",
            "answer": defineData.questionText ?? "",
            "note": defineData.note,
            "options": [defineData.answer, defineData.wrongAnswer],
          };
        },
      ).toList();
}
