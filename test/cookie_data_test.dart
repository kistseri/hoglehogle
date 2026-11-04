import 'package:flutter_test/flutter_test.dart';
import 'package:hoho_hanja/data/models/cookie_data.dart';

CookieData _data(String q, String a, List<String?> wrongs) => CookieData.fromJson({
      'result': '0000',
      'ilno': 1,
      'quize': q,
      'ans': a,
      'wans1': wrongs[0],
      'wans2': wrongs[1],
      'wans3': wrongs[2],
    });

void main() {
  test('빈 값·숫자 값이 와도 fromJson이 실패하지 않음', () {
    final d = CookieData.fromJson({'result': '0000', 'ilno': 3});
    expect(d.number, '3');
    expect(d.answer, '');
    expect(d.wanswer5, '');
  });

  test('문제·정답이 빈 데이터는 빼고, 오답은 빈 값·정답과 같은 값·중복을 뺌', () {
    final c = CookieDataController();
    c.isWorried.value = true;
    c.setCookieDataList([
      _data('日', '날 일', ['달 월', '', '날 일']),
      _data('', '빈 문제', ['a', 'b', 'c']),
      _data('月', '달 월', ['불 화', '불 화', null]),
    ]);
    expect(c.quiz.length, 2);
    final sun = c.quiz.firstWhere((q) => q.question == '日');
    expect(sun.wrongAnswers, ['달 월']);
    final moon = c.quiz.firstWhere((q) => q.question == '月');
    expect(moon.wrongAnswers, ['불 화']);
    expect(c.isWorried.value, false);
  });

  test('문제는 최대 20개', () {
    final c = CookieDataController();
    c.setCookieDataList(List.generate(30, (i) => _data('q$i', 'a$i', ['w1', 'w2', 'w3'])));
    expect(c.quiz.length, CookieDataController.maxQuestions);
  });
}
