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

  // 서버가 값을 빼거나 숫자로 보내도 오류 없이 받음
  DefineData.fromJson(Map<String, dynamic> json)
      : result = json["result"]?.toString() ?? '',
        number = json["ilno"]?.toString() ?? '',
        typechk = json["typechk"]?.toString() ?? '',
        questionImg = json["questionImg"]?.toString(),
        questionText = json["questionText"]?.toString(),
        answer = json["ans"]?.toString() ?? '',
        wrongAnswer = json["wans"]?.toString() ?? '',
        note = json["note"]?.toString() ?? '';
}

class DefineDataController extends GetxController {
  List<DefineData> _defineDataList = <DefineData>[]; // 화면이 값을 지켜보지 않고 열기 전에 넣으므로 일반 List + update() (C-38)

  // 정답·오답이 비었거나 둘이 같은 데이터는 뺌 (빈 버튼·정답 두 개 방지)
  void setDefineDataList(List<DefineData> defineDataList) {
    _defineDataList = defineDataList
        .where((d) =>
            d.answer.trim().isNotEmpty && d.wrongAnswer.trim().isNotEmpty && d.answer.trim() != d.wrongAnswer.trim())
        .toList();
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
