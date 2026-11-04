import 'package:get/get.dart';

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

  // 서버가 값을 빼거나 숫자로 보내도 오류 없이 빈 문자열로 받음
  CookieData.fromJson(Map<String, dynamic> json)
      : result = json["result"]?.toString() ?? '',
        number = json["ilno"]?.toString() ?? '',
        quize = json["quize"]?.toString() ?? '',
        answer = json["ans"]?.toString() ?? '',
        wanswer1 = json["wans1"]?.toString() ?? '',
        wanswer2 = json["wans2"]?.toString() ?? '',
        wanswer3 = json["wans3"]?.toString() ?? '',
        wanswer4 = json["wans4"]?.toString() ?? '',
        wanswer5 = json["wans5"]?.toString() ?? '';
}

// 쿠키 한 판 (문제 1개)
class CookieQuiz {
  final String question;
  final String answer;
  final List<String> wrongAnswers; // 최대 3개, 빈 값·정답과 같은 값은 뺌

  const CookieQuiz(this.question, this.answer, this.wrongAnswers);
}

class CookieDataController extends GetxController {
  static const int maxQuestions = 20;

  List<CookieData> _cookieDataList = <CookieData>[];
  List<CookieQuiz> _quiz = [];
  RxBool isWorried = false.obs;

  // 문제 순서는 불러올 때 한 번만 섞고, 문제·정답이 빈 데이터는 뺌
  void setCookieDataList(List<CookieData> cookieDataList) {
    _cookieDataList = List.from(cookieDataList)..shuffle();
    _quiz = _cookieDataList
        .where((d) => d.quize.trim().isNotEmpty && d.answer.trim().isNotEmpty)
        .take(maxQuestions)
        .map((d) {
      final wrongs = [d.wanswer1, d.wanswer2, d.wanswer3]
          .where((w) => w.trim().isNotEmpty && w != d.answer)
          .toSet()
          .toList();
      return CookieQuiz(d.quize, d.answer, wrongs);
    }).toList();
    isWorried.value = false;
    update();
  }

  List<CookieData> get cookieDataList => _cookieDataList;

  List<CookieQuiz> get quiz => _quiz;

  void setWorry(bool value) {
    if (isWorried.value != value) isWorried.value = value;
  }
}
