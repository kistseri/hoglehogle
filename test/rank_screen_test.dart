import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/data/models/goods_data.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/data/models/my_room_data.dart';
import 'package:hoho_hanja/data/models/rank_data.dart';
import 'package:hoho_hanja/screens/myroom/myroom_wigets/my_room_item.dart';
import 'package:hoho_hanja/screens/rank/rank_screen.dart';
import 'package:hoho_hanja/utils/network_check.dart';

// 플러그인을 건드리지 않는 오프라인 상태
class _Offline extends ConnectivityController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

RankData _rank(int i, int points, {String? nick, String? char}) => RankData.fromJson({
      'result': '0000',
      'id': 'user$i',
      'total_points': points,
      'nickname': nick ?? '사용자$i',
      'character_img': char ?? '0${i % 4}',
    });

List<RankData> _people(int n) => List.generate(n, (i) => _rank(i, 5000 - i * 100));

Future<void> _pumpRank(WidgetTester tester,
    {Size size = const Size(360, 780), double top = 24, double bottom = 0}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.view.padding = FakeViewPadding(top: top, bottom: bottom);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(fontFamily: 'NotoSansKR-Regular'),
      home: Builder(builder: (context) {
        final mq = MediaQuery.of(context);
        final s = (mq.size.width / 360).clamp(0, (mq.size.height - top - bottom) / 698);
        return Scaffold(
          // 홈의 랭킹 탭과 같은 높이의 앱바 자리
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(53 * s.toDouble()),
            child: Container(color: Colors.green.shade800),
          ),
          body: const RankScreen(),
        );
      }),
    ),
  );
}

void main() {
  setUp(() {
    Get.reset();
    Get.put<ConnectivityController>(_Offline());
  });

  test('랭킹: 점수 순 정렬, 같은 점수는 같은 순위, 이상한 값도 받음', () {
    final c = RankDataController();
    c.setRankData([
      _rank(0, 10),
      RankData.fromJson({'result': '0000', 'total_points': '30', 'nickname': null, 'character_img': 7}),
      _rank(2, 30),
      _rank(3, 5),
    ]);
    expect(c.rankDataList.map((e) => e.totalPoints), [30, 30, 10, 5]);
    expect(c.ranks, [1, 1, 3, 4]);
    expect(c.rankDataList.first.nickName, '');
  });

  for (final n in [0, 1, 2, 3, 4, 20]) {
    testWidgets('랭킹 $n명이어도 오류 없이 그려짐', (tester) async {
      final c = Get.put(RankDataController());
      c.setRankData(_people(n));
      await _pumpRank(tester);
      // 오프라인이라 initState의 새로고침은 실패하지만, 받아둔 랭킹이 있으면 그대로 보여줌
      if (n == 0) {
        expect(find.text('다시 시도'), findsOneWidget);
        c.setRankData([]);
        await tester.pump();
        expect(find.textContaining('이번 달 랭킹이 아직 없어요'), findsOneWidget);
      } else {
        expect(find.text('사용자0'), findsOneWidget);
        expect(find.text('다시 시도'), findsNothing);
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('불러오기 전에 랭킹 탭에 들어간 뒤 응답이 오면 화면에 반영됨', (tester) async {
    final c = Get.put(RankDataController());
    await _pumpRank(tester);
    expect(find.text('다시 시도'), findsOneWidget);
    c.setRankData(_people(5));
    await tester.pump();
    expect(find.text('사용자4'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('[디버그] 1·2·3위 자리에 내(테스트 계정) 캐릭터를 넣었다 뺄 수 있음', (tester) async {
    // 마이룸 컨트롤러가 화면 배율(ScreenUtil)을 씀
    ScreenUtil.configure(
      data: const MediaQueryData(size: Size(360, 780)),
      designSize: const Size(360, 720),
      splitScreenMode: false,
      minTextAdapt: false,
    );
    Get.put(LoginDataController()).setLoginData(LoginData(nickName: '테스트계정', id: 'user1'));
    Get.put(GoodsDataController());
    Get.put(MyroomDataController());
    Get.put(MyroomItemController());
    Get.put(RankDataController()).setRankData(_people(5));
    await _pumpRank(tester);

    expect(find.text('테스트계정'), findsNothing);
    await tester.tap(find.text('1').first);
    await tester.pump();
    expect(find.text('테스트계정'), findsOneWidget);
    expect(find.text('사용자0'), findsNothing); // 1위 자리가 내 캐릭터로 바뀜
    expect(find.text('4,900점'), findsNWidgets(2)); // 1위 자리: 내 점수(user1) 그대로, 2위 자리: 원래 user1

    await tester.tap(find.text('3').first);
    await tester.pump();
    expect(find.text('테스트계정'), findsNWidgets(2));

    await tester.tap(find.text('1').first);
    await tester.pump();
    expect(find.text('사용자0'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('닉네임이 아주 길어도 넘치지 않음', (tester) async {
    final c = Get.put(RankDataController());
    c.setRankData([
      for (var i = 0; i < 6; i++) _rank(i, 100 - i, nick: '쌈뽕한 공쥬들의 모임 파뤼👑👑 아주아주 긴 닉네임 $i'),
    ]);
    await _pumpRank(tester, size: const Size(320, 568), top: 20);
    expect(tester.takeException(), isNull);
  });

  // RANK_SHOT_DIR 환경변수가 있으면 기기별 화면을 PNG로 저장 (눈으로 확인용)
  final shotDir = Platform.environment['RANK_SHOT_DIR'];
  if (shotDir != null) {
    testWidgets('기기별 화면 저장', (tester) async {
      // 실제 그림을 받아오도록 (테스트 기본값은 네트워크 막힘)
      HttpOverrides.global = null;
      await tester.runAsync(() async {
        for (final f in ['NotoSansKR-Regular', 'NotoSansKR-Bold', 'BMJUA']) {
          final file = {
            'NotoSansKR-Regular': 'assets/fonts/NotoSansKR-Regular.ttf',
            'NotoSansKR-Bold': 'assets/fonts/NotoSansKR-Bold.ttf',
            'BMJUA': 'assets/fonts/BMJUA.ttf',
          }[f]!;
          await (FontLoader(f)..addFont(rootBundle.load(file))).load();
        }
      });
      final devices = {
        'phone_360x780': (const Size(360, 780), 24.0, 0.0),
        'phone_412x915': (const Size(412, 915), 32.0, 24.0),
        'small_320x568': (const Size(320, 568), 20.0, 0.0),
        'tablet_800x1280': (const Size(800, 1280), 24.0, 0.0),
      };
      for (final count in [2, 20]) {
        for (final e in devices.entries) {
          await tester.pumpWidget(const SizedBox()); // 이전 화면 상태를 버림
          Get.reset();
          Get.put<ConnectivityController>(_Offline());
          // RANK_JSON 이 있으면 실제 서버 응답으로 (아바타 모자·옷 확인용)
          final realJson = Platform.environment['RANK_JSON'];
          final real = realJson == null
              ? null
              : (jsonDecode(File(realJson).readAsStringSync()) as List)
                  .map((e) => RankData.fromJson(e as Map<String, dynamic>))
                  .toList();
          Get.put(RankDataController()).setRankData(real?.take(count).toList() ??
              [
                ..._people(count - 1),
                _rank(99, 1, nick: '쌈뽕한 공쥬들의 모임 파뤼👑👑'),
              ]);
          // 실제 그림은 화면을 그리기 전에 진짜 시간으로 미리 받아 캐시에 넣음 (fake 시간에서 받으면 끝나지 않음)
          if (real != null) {
            await tester.runAsync(() async {
              for (final r in real.take(count)) {
                for (final url in [r.backgroundImage, r.hatImage, r.clothesImage]) {
                  if (url == null || !url.startsWith('http')) continue;
                  final done = Completer<void>();
                  NetworkImage(url).resolve(ImageConfiguration.empty).addListener(ImageStreamListener(
                        (_, __) => done.isCompleted ? null : done.complete(),
                        onError: (_, __) => done.isCompleted ? null : done.complete(),
                      ));
                  await done.future.timeout(const Duration(seconds: 15), onTimeout: () {});
                }
              }
            });
          }
          final (size, top, bottom) = e.value;
          await _pumpRank(tester, size: size, top: top, bottom: bottom);
          // 그림(에셋·네트워크 캐시) 풀기를 진짜 시간으로 기다림
          for (var i = 0; i < 3; i++) {
            await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 300)));
            await tester.pump();
          }
          final boundary = tester.renderObject<RenderRepaintBoundary>(find.byType(RepaintBoundary).first);
          await tester.runAsync(() async {
            final image = await boundary.toImage();
            final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
            File('$shotDir/rank_${count}_${e.key}.png').writeAsBytesSync(bytes!.buffer.asUint8List());
          });
        }
      }
    });
  }
}
