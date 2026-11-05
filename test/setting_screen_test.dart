import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/data/models/setting_data.dart';
import 'package:hoho_hanja/screens/setting/setting_screen.dart';
import 'package:hoho_hanja/utils/network_check.dart';

// 플러그인을 건드리지 않는 오프라인 상태
class _Offline extends ConnectivityController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

Future<void> _pump(WidgetTester tester, {Size size = const Size(360, 780), double top = 24, double bottom = 0}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.view.padding = FakeViewPadding(top: top, bottom: bottom);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ScreenUtilInit(
      designSize: const Size(360, 720),
      builder: (_, __) => GetMaterialApp(
        theme: ThemeData(fontFamily: 'NotoSansKR-Regular'),
        home: RepaintBoundary(
          child: Builder(builder: (context) {
            final mq = MediaQuery.of(context);
            final s = [mq.size.width / 360, (mq.size.height - top - bottom) / 698].reduce((a, b) => a < b ? a : b);
            return Scaffold(
              // 홈의 설정 탭과 같은 높이의 앱바 자리
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(53 * s),
                child: Container(color: Colors.green.shade100),
              ),
              body: const SettingScreen(),
            );
          }),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  setUp(() {
    Get.reset();
    Get.put<ConnectivityController>(_Offline());
    Get.put(LoginDataController()).setLoginData(LoginData(
      nickName: '테스트',
      id: 'apple_001234.5f8e2a9c3d4b4e1f9a7c6b5d4e3f2a1b.0123',
    ));
    Get.put(SettingDataController()).settinData('N');
  });

  for (final (name, size, top, bottom) in [
    ('small_320x568', const Size(320, 568), 20.0, 0.0),
    ('phone_360x780', const Size(360, 780), 24.0, 0.0),
    ('phone_412x915', const Size(412, 915), 32.0, 24.0),
    ('tablet_800x1280', const Size(800, 1280), 24.0, 0.0),
  ]) {
    testWidgets('설정 화면 $name: 넘치지 않고 버튼 폭이 시안 비율대로', (tester) async {
      await _pump(tester, size: size, top: top, bottom: bottom);
      expect(tester.takeException(), isNull);
      final s = [size.width / 360, (size.height - top - bottom) / 698].reduce((a, b) => a < b ? a : b);
      final w = tester.getSize(find.ancestor(of: find.text('로그아웃'), matching: find.byType(Container)).first).width;
      expect(w, closeTo(320 * s, 1)); // 시안 360 - 양옆 20
      // 닉네임 편집 칸도 넘치지 않음
      await tester.tap(find.byIcon(CupertinoIcons.pencil));
      await tester.pump();
      expect(tester.takeException(), isNull);

      final dir = Platform.environment['SETTING_SHOT_DIR'];
      if (dir != null) {
        await tester.tap(find.byIcon(Icons.check_rounded)); // 그대로라 닫힘
        await tester.pump();
        await tester.runAsync(() async {
          for (final (f, file) in [
            ('NotoSansKR-Regular', 'assets/fonts/NotoSansKR-Regular.ttf'),
            ('BMJUA', 'assets/fonts/BMJUA.ttf'),
          ]) {
            await (FontLoader(f)..addFont(rootBundle.load(file))).load();
          }
        });
        await tester.pump();
        final boundary = tester.renderObject<RenderRepaintBoundary>(find.byType(RepaintBoundary).first);
        await tester.runAsync(() async {
          final image = await boundary.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          File('$dir/setting_$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
        });
      }
    });
  }

  testWidgets('닉네임: 빈칸은 안 보내고, 그대로면 그냥 닫힘', (tester) async {
    await _pump(tester);
    await tester.tap(find.byIcon(CupertinoIcons.pencil));
    await tester.pump();
    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.byIcon(Icons.check_rounded));
    await tester.pump();
    expect(find.text('닉네임을 입력해주세요.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4)); // 안내가 저절로 닫힘
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget); // 아직 편집 중

    await tester.enterText(find.byType(TextField), '테스트 ');
    await tester.tap(find.byIcon(Icons.check_rounded));
    await tester.pump();
    expect(find.byType(TextField), findsNothing);
    expect(find.text('테스트'), findsOneWidget);
  });

  testWidgets('닉네임: 인터넷이 없으면 안내 후 편집 칸을 그대로 둠 (앱이 멈추지 않음)', (tester) async {
    await _pump(tester);
    await tester.tap(find.byIcon(CupertinoIcons.pencil));
    await tester.pump();
    await tester.enterText(find.byType(TextField), '새이름');
    await tester.tap(find.byIcon(Icons.check_rounded));
    await tester.pump();
    expect(find.text('인터넷 연결을 확인해주세요'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    expect(Get.find<LoginDataController>().loginData.value!.nickName, '테스트');
  });

  testWidgets('쿠폰: 소문자로 쳐도 대문자로 들어감, 취소하면 팝업만 닫힘', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('쿠폰 입력하기'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'ab12-cd');
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, 'AB12CD');
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect(find.text('쿠폰 입력'), findsNothing);
    expect(find.byType(SettingScreen), findsOneWidget);
  });

  testWidgets('회원 탈퇴: 취소하면 팝업만 닫히고 설정 화면은 그대로', (tester) async {
    await _pump(tester);
    await tester.tap(find.text('회원 탈퇴'));
    await tester.pumpAndSettle();
    expect(find.text('정말로 탈퇴하시겠습니까?', findRichText: true), findsNothing);
    expect(find.textContaining('정말로 탈퇴하시겠습니까?'), findsOneWidget);
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect(find.textContaining('정말로 탈퇴'), findsNothing);
    expect(find.byType(SettingScreen), findsOneWidget);
  });

  testWidgets('회원 탈퇴: 탈퇴를 누르면 첫 창은 닫히고 계산 문제만 보임 (작은 폰에서도 넘치지 않음)', (tester) async {
    await _pump(tester, size: const Size(320, 568), top: 20);
    await tester.tap(find.text('회원 탈퇴'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('탈퇴'));
    await tester.pumpAndSettle();
    expect(find.textContaining('정말로 탈퇴'), findsNothing);
    expect(find.text('탈퇴 확인'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('확인'));
    await tester.pump();
    expect(find.text('정답이 아닙니다.'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.clear));
    await tester.pumpAndSettle();
    expect(find.text('탈퇴 확인'), findsNothing);
    expect(find.byType(SettingScreen), findsOneWidget);
  });
}

