import 'package:get/get.dart';
import 'package:logger/logger.dart';

class CookieData {
  final String result;
  final String number;
  final String quize;
  final String answer;
  final String wanswer1;
  final String wanswer2;
  final String wanswer3;
  final String wanswer4;
  final String wanswer5;

  CookieData({
    required this.result,
    required this.number,
    required this.quize,
    required this.answer,
    required this.wanswer1,
    required this.wanswer2,
    required this.wanswer3,
    required this.wanswer4,
    required this.wanswer5,
  });

  CookieData.fromJson(Map<String, dynamic> json)
      : result = json["result"],
        number = json["ilno"],
        quize = json["quize"],
        answer = json["ans"],
        wanswer1 = json["wans1"],
        wanswer2 = json["wans2"],
        wanswer3 = json["wans3"],
        wanswer4 = json["wans4"],
        wanswer5 = json["wans5"];
}

class CookieDataController extends GetxController {
  List<CookieData> _cookieDataList = <CookieData>[].obs;
  RxBool isWorried = false.obs;

  void setCookieDataList(List<CookieData> cookieDataList) {
    _cookieDataList = List.from(cookieDataList)..shuffle();
    update();
  }

  List<CookieData> get cookieDataList => _cookieDataList;

  List<Map<String, dynamic>> get quiz => _cookieDataList.take(20).map(
        (cookieData) {
          return {
            "wrongAnswer": [
              cookieData.wanswer1,
              cookieData.wanswer2,
              cookieData.wanswer3,
            ],
            "options": [cookieData.quize, cookieData.answer],
          };
        },
      ).toList();

  void quizList() {
    Logger().d('quiz = $quiz');
  }

  void setWorry(bool value) {
    isWorried(value);
  }
}
