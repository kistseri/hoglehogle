import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/data/models/cookie_data.dart';
import 'package:hoho_hanja/screens/cookie/cookie_widgets/cookie_element.dart';
import 'package:hoho_hanja/screens/cookie/cookie_widgets/cookie_game.dart';

class _Game extends CookieGame {
  int overCalls = 0;
  _Game() : super(code: 'x', topInset: 80, cookieSize: 65);
  @override
  Future<void> gameOver() async {
    overCalls++;
    isGameOver = true;
  }
}

void main() {
  for (final h in [667.0, 932.0, 1366.0]) {
    testWidgets('화면 높이 $h: 쿠키가 바닥에 닿으면 게임이 한 번 끝남', (tester) async {
      final c = Get.put(CookieDataController());
      c.setCookieDataList(List.generate(5, (i) => CookieData.fromJson(
          {'result': '0000', 'quize': 'q$i', 'ans': 'a$i', 'wans1': 'w1', 'wans2': 'w2', 'wans3': 'w3'})));
      tester.view.physicalSize = Size(390, h);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final game = _Game();
      await tester.runAsync(() async {
        await tester.pumpWidget(ScreenUtilInit(designSize: const Size(360, 720), builder: (_, __) => MaterialApp(home: GameWidget(game: game))));
        await Future.delayed(const Duration(seconds: 1));
      });
      await tester.pump();
      await tester.pump();
      final n = game.children.whereType<CookieElement>().length;
      for (int i = 0; i < 400 && game.overCalls == 0; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(n, 4);
      expect(game.overCalls, 1);
      Get.reset();
    });
  }
}
