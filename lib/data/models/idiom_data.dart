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

  // 서버가 값을 빼거나 숫자·문자열을 섞어 보내도 오류 없이 받음
  IdiomData.fromJson(Map<String, dynamic> json)
      : result = json["result"]?.toString() ?? '',
        number = json["ilno"]?.toString() ?? '',
        quize1 = json["quize1"]?.toString() ?? '',
        quize2 = json["quize2"]?.toString() ?? '',
        hanja1 = json["hanja1"]?.toString() ?? '',
        hanja2 = json["hanja2"]?.toString() ?? '',
        hanja3 = json["hanja3"]?.toString() ?? '',
        hanja4 = json["hanja4"]?.toString() ?? '',
        randomNum = int.tryParse(json["random_num"]?.toString() ?? '') ?? 0,
        selectedHanja = json["selected_hanja"]?.toString() ?? '',
        wrongAnswer = json["wnas"]?.toString() ?? '';
}

class IdiomDataController extends GetxController {
  List<IdiomData> _idiomDataList = <IdiomData>[].obs;

  // 정답 한자가 빈 데이터는 뺌
  void setIdiomDataList(List<IdiomData> idiomDataList) {
    _idiomDataList = idiomDataList.where((d) => d.selectedHanja.trim().isNotEmpty).toList();
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
