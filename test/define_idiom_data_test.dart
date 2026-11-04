import 'package:flutter_test/flutter_test.dart';
import 'package:hoho_hanja/data/models/define_data.dart';
import 'package:hoho_hanja/data/models/idiom_data.dart';

void main() {
  test('단어의 뜻 찾기: 숫자·빈 값이 와도 fromJson이 실패하지 않고, 정답이 빈 문제는 뺌', () {
    final c = DefineDataController();
    c.setDefineDataList([
      DefineData.fromJson({'result': '0000', 'ilno': 1, 'typechk': 3, 'ans': '날 일', 'wans': '달 월'}),
      DefineData.fromJson({'result': '0000', 'ilno': 2, 'ans': null}),
    ]);
    expect(c.quiz.length, 1);
    expect(c.quiz.first['type'], '3');
    expect(c.quiz.first['note'], '');
  });

  test('한자성어: random_num이 문자열이어도 숫자로 받고, 정답 한자가 빈 문제는 뺌', () {
    final c = IdiomDataController();
    c.setIdiomDataList([
      IdiomData.fromJson({'result': '0000', 'ilno': 1, 'random_num': '2', 'selected_hanja': '石', 'wnas': '木'}),
      IdiomData.fromJson({'result': '0000', 'ilno': 2, 'random_num': 3}),
    ]);
    expect(c.idiomDataList.length, 1);
    expect(c.idiomDataList.first.randomNum, 2);
    expect(c.idiom.first['options'], ['石', '木']);
  });
}
