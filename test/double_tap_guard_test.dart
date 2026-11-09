import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/data/models/contents_data.dart';
import 'package:hoho_hanja/screens/auth/auth_widgets/auth_layout.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';

ContentsData _content(String phase, String code, bool lock) =>
    ContentsData(result: '0000', phase: phase, code: code, contentName: '', lock: lock, openPage: 1);

void main() {
  testWidgets('AuthButton: 요청이 끝나기 전에 여러 번 눌러도 한 번만 실행', (tester) async {
    var calls = 0;
    final done = Completer<void>();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AuthButton(
          text: '인증',
          color: Colors.green,
          onTap: () {
            calls++;
            return done.future;
          },
        ),
      ),
    ));

    await tester.tap(find.text('인증'));
    await tester.tap(find.text('인증'));
    await tester.tap(find.text('인증'));
    expect(calls, 1);

    // 끝나면 다시 누를 수 있음
    done.complete();
    await tester.pump();
    await tester.tap(find.text('인증'));
    expect(calls, 2);
  });

  test('콘텐츠 잠금 정보: 늦게 온 다른 급수 응답이 지금 급수 정보를 지우지 않음', () {
    final c = ContentsDataController();
    c.setContentsDataList([_content('70', 'T', true)]);
    c.setContentsDataList([_content('80', 'T', false)]); // 이전 급수 응답이 늦게 도착
    expect(c.contentsDataList.where((e) => e.phase == '70').single.lock, isTrue);

    // 같은 급수를 다시 받으면 그 급수만 새 값으로
    c.setContentsDataList([_content('70', 'T', false)]);
    expect(c.contentsDataList.where((e) => e.phase == '70').single.lock, isFalse);
    expect(c.contentsDataList.length, 2);

    c.clear();
    expect(c.contentsDataList, isEmpty);
  });

  testWidgets('안내창: 여러 번 불러도 화면에는 1개만, 다른 내용이면 새 내용으로 바뀜, 3초 뒤 닫힘', (tester) async {
    await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));

    // 같은 순간에 같은 내용 3번 (예전 스낵바가 줄줄이 올라오던 상황)
    failDialog('입력 확인', '이메일을 입력해주세요.');
    failDialog('입력 확인', '이메일을 입력해주세요.');
    failDialog('입력 확인', '이메일을 입력해주세요.');
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);

    // 다른 내용이면 이전 창을 새 창으로 바꿈
    failDialog('결제 실패', '결제 중 오류가 발생했습니다.');
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('결제 중 오류가 발생했습니다.'), findsOneWidget);
    expect(find.text('이메일을 입력해주세요.'), findsNothing);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);

    // 닫힌 뒤에는 같은 내용도 다시 뜸
    failDialog('입력 확인', '이메일을 입력해주세요.');
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
