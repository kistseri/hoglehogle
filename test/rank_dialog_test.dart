import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/widgets/dialog/rank_dialog.dart';

void main() {
  for (final (name, size, top) in [
    ('작은 폰 320x568', const Size(320, 568), 20.0),
    ('폰 360x780', const Size(360, 780), 24.0),
    ('태블릿 800x1280', const Size(800, 1280), 24.0),
  ]) {
    testWidgets('랭킹 안내 팝업: $name 에서 화면 비율대로, 넘치지 않음', (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      tester.view.padding = FakeViewPadding(top: top);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const GetMaterialApp(home: Scaffold()));
      showRankDialog('랭킹 시스템 기준 안내', '랭킹 시스템은 매월 1일부터 말일까지를\n기준으로 등록되며\n매월 1일 초기화됩니다.\n\n' * 2);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final s = [size.width / 360, (size.height - top) / 698].reduce((a, b) => a < b ? a : b);
      final box = tester.getSize(find.ancestor(of: find.text('닫기'), matching: find.byType(Container)).last);
      expect(box.width, closeTo(324 * s, 1));
      await tester.tap(find.text('닫기'));
      await tester.pumpAndSettle();
      expect(find.text('닫기'), findsNothing);
    });
  }
}
