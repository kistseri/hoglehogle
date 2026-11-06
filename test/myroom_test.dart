import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/data/models/goods_data.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/data/models/my_room_data.dart';
import 'package:hoho_hanja/screens/myroom/my_room_screen.dart';
import 'package:hoho_hanja/screens/myroom/myroom_wigets/my_room_item.dart';
import 'package:hoho_hanja/utils/network_check.dart';

// 플러그인을 건드리지 않는 오프라인 상태
class _Offline extends ConnectivityController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

const _img = 'https://hohoeduimg.speedgabia.com/app/character/item';

MyroomData _item(int id, String cat, String file, {bool own = true, int coin = 100}) => MyroomData.fromJson({
      'itemid': id,
      'categoryId': cat,
      'itemimg': '$_img/$cat/$file.png',
      'coin': coin,
      'useyn': own ? 'Y' : 'N',
    });

final _items = [
  _item(5, '10', 'KakaoTalk_20241128_144348851_04'),
  _item(7, '10', 'clothes_1'),
  _item(9, '10', 'clothes_3', own: false, coin: 300),
  _item(10, '10', 'clothes_4', own: false, coin: 500),
  _item(14, '10', 'clothes_8', own: false, coin: 800),
  _item(22, '20', 'hat_6'),
  _item(17, '20', 'hat_1', own: false),
  _item(29, '40', 'bg_3'),
  _item(27, '40', 'bg_1', own: false),
];

void _setUpControllers({bool withItems = true}) {
  Get.reset();
  Get.put<ConnectivityController>(_Offline());
  Get.put(LoginDataController()).setLoginData(LoginData(nickName: '테스트', id: 'test'));
  Get.put(GoodsDataController(), permanent: true).setGoodsData(GoodsData(coin: 1000, dia: 3));
  final data = Get.put(MyroomDataController());
  data.resetFor('test');
  if (withItems) data.setMyroomData(_items);
  MyroomItemController.to.resetFor('test');
}

Future<void> _pump(WidgetTester tester, {Size size = const Size(360, 780), double top = 24, double bottom = 0}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.view.padding = FakeViewPadding(top: top, bottom: bottom);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    GetMaterialApp(
      theme: ThemeData(fontFamily: 'NotoSansKR-Regular'),
      home: RepaintBoundary(child: MyRoomScreen(onPressed: () {})),
    ),
  );
  // 오프라인이라 앱바의 코인 조회가 띄우는 '연결 실패' 팝업이 3초 뒤 저절로 닫히길 기다림
  await tester.pump();
  await tester.pump(const Duration(seconds: 4));
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  setUp(() {
    _setUpControllers();
  });

  test('옷장 데이터: 숫자가 문자열이거나 값이 비어도 받음', () {
    final d = MyroomData.fromJson({'itemid': '12', 'categoryId': 10, 'itemimg': null, 'coin': '300', 'useyn': 'y'});
    expect(d.itemId, 12);
    expect(d.categoryId, '10');
    expect(d.item, '');
    expect(d.coin, 300);
    expect(d.isOwned, true);
  });

  test('저장된 착용 상태: char_index가 숫자·범위 밖이어도, 그림이 비어도 받음', () {
    final c = MyroomItemController.to;
    c.applyItemResponse({
      'char_index': 7,
      'items': [
        {'categoryId': 10, 'itemId': '5', 'itemimg': '$_img/10/x.png'},
        {'categoryId': '20', 'itemId': 22, 'itemimg': null},
        'garbage',
      ],
    });
    expect(c.characterIndex.value, 0);
    expect(c.selectedItems, {'10': 5, '20': 22});
    expect(c.clothingImage.value, '$_img/10/x.png');
    expect(c.hatImage.value, '');
    expect(c.hasChanges, false);
  });

  test('마이룸에서 바꾼 뒤 늦게 온 서버 착용 상태가 덮어쓰지 않음', () {
    final c = MyroomItemController.to;
    c.wear(_items[0]);
    c.applyItemResponse({'char_index': '02', 'items': []});
    expect(c.characterIndex.value, 0);
    expect(c.clothingImage.value, _items[0].item);
  });

  test('다른 계정으로 들어오면 이전 계정의 옷·옷장을 지움', () {
    final c = MyroomItemController.to;
    c.wear(_items[0]);
    c.nextCharacter();
    c.resetFor('other');
    Get.find<MyroomDataController>().resetFor('other');
    expect(c.characterIndex.value, 0);
    expect(c.clothingImage.value, '');
    expect(c.selectedItems, isEmpty);
    expect(c.hasChanges, false);
    expect(Get.find<MyroomDataController>().myroomDataList, isEmpty);
  });

  test('저장 실패(오프라인)하면 다음에 나갈 때 다시 저장하도록 남김', () async {
    final c = MyroomItemController.to;
    expect(c.hasChanges, false);
    c.wear(_items[0]);
    await c.saveIfChanged();
    expect(c.hasChanges, true);
  });

  testWidgets('안 산 아이템을 누르면 구매 팝업만 뜨고 착용 목록에는 안 들어감, 취소해도 화면은 그대로', (tester) async {
    await _pump(tester);
    await tester.pump();
    final c = MyroomItemController.to;
    c.wear(_items[0]);
    await tester.pump();

    await tester.tap(find.byType(GestureDetector).at(_gridIndex(tester, _items[2])));
    await tester.pumpAndSettle();
    expect(find.text('이 아이템을 구매하시겠습니까?', findRichText: true), findsNothing); // 문구에 가격이 붙음
    expect(find.textContaining('이 아이템을 구매하시겠습니까?'), findsOneWidget);
    expect(c.selectedItems['10'], 5); // 그대로

    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    expect(find.textContaining('구매하시겠습니까'), findsNothing);
    expect(find.byType(MyRoomScreen), findsOneWidget); // 취소가 화면까지 닫지 않음
  });

  testWidgets('가진 아이템은 누르면 바로 입고, 배경도 착용 표시됨', (tester) async {
    await _pump(tester);
    await tester.pump();
    final c = MyroomItemController.to;
    c.setSelectedCategory('40');
    await tester.pump();
    await tester.tap(find.byType(GestureDetector).at(_gridIndex(tester, _items[7])));
    await tester.pump();
    expect(c.backgroundImage.value, _items[7].item);
    expect(c.isWorn(_items[7]), true);
    expect(tester.widget<MyroomItem>(find.byType(MyroomItem).first).isWorn, true);
  });

  testWidgets('옷장을 못 받았으면 안내와 다시 시도 버튼', (tester) async {
    _setUpControllers(withItems: false);
    Get.find<MyroomDataController>().setError();
    await _pump(tester);
    await tester.pump();
    expect(find.text('옷장을 불러오지 못했어요'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);
  });

  testWidgets('기기별 화면 저장', (tester) async {
    final dir = Platform.environment['MYROOM_SHOT_DIR'];
    if (dir == null) return; // 화면 저장은 필요할 때만
    HttpOverrides.global = null;
    await tester.runAsync(() async {
      for (final (f, file) in [
        ('NotoSansKR-Regular', 'assets/fonts/NotoSansKR-Regular.ttf'),
        ('BMJUA', 'assets/fonts/BMJUA.ttf'),
      ]) {
        await (FontLoader(f)..addFont(rootBundle.load(file))).load();
      }
      for (final it in _items) {
        final done = Completer<void>();
        NetworkImage(it.item).resolve(ImageConfiguration.empty).addListener(ImageStreamListener(
              (_, __) => done.isCompleted ? null : done.complete(),
              onError: (_, __) => done.isCompleted ? null : done.complete(),
            ));
        await done.future.timeout(const Duration(seconds: 15), onTimeout: () {});
      }
    });
    final devices = {
      'phone_360x780': (const Size(360, 780), 24.0, 0.0),
      'phone_412x915': (const Size(412, 915), 32.0, 24.0),
      'small_320x568': (const Size(320, 568), 20.0, 0.0),
      'tablet_800x1280': (const Size(800, 1280), 24.0, 0.0),
    };
    for (final ch in [0, 1, 2, 3]) {
      for (final e in devices.entries) {
        if (ch != 0 && e.key != 'phone_360x780') continue;
        await tester.pumpWidget(const SizedBox());
        _setUpControllers();
        final c = MyroomItemController.to;
        c.characterIndex.value = ch;
        c.wear(_items[0]);
        c.wear(_items[5]);
        c.wear(_items[7]);
        final (size, top, bottom) = e.value;
        await _pump(tester, size: size, top: top, bottom: bottom);
        for (var i = 0; i < 3; i++) {
          await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 300)));
          await tester.pump();
        }
        final boundary = tester.renderObject<RenderRepaintBoundary>(find.byType(RepaintBoundary).first);
        await tester.runAsync(() async {
          final image = await boundary.toImage();
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          File('$dir/myroom_c${ch}_${e.key}.png').writeAsBytesSync(bytes!.buffer.asUint8List());
        });
      }
    }
  });
}

// 그리드에서 그 아이템 칸의 GestureDetector 순서
int _gridIndex(WidgetTester tester, MyroomData item) {
  final all = tester.widgetList<GestureDetector>(find.byType(GestureDetector)).toList();
  final cells = tester.widgetList<MyroomItem>(find.byType(MyroomItem)).toList();
  final cellIndex = cells.indexWhere((m) => m.item.itemId == item.itemId);
  final target = find.ancestor(of: find.byType(MyroomItem).at(cellIndex), matching: find.byType(GestureDetector)).first;
  return all.indexOf(tester.widget<GestureDetector>(target));
}
