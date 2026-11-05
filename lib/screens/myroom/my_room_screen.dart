import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/data/models/my_room_data.dart';
import 'package:hoho_hanja/screens/myroom/myroom_wigets/my_room_item.dart';
import 'package:hoho_hanja/screens/myroom/myroom_wigets/my_room_tab.dart';
import 'package:hoho_hanja/services/myroom/my_room_service.dart';
import 'package:hoho_hanja/services/purchase/product_service.dart';
import 'package:hoho_hanja/utils/design_scale.dart';
import 'package:hoho_hanja/widgets/appbar/design_app_bar.dart';
import 'package:hoho_hanja/widgets/character_avatar.dart';

/// 마이룸 (옷장)
///
/// 착용 저장은 화면을 어떻게 나가든 (앱바 뒤로가기·기기 뒤로가기·다른 탭) 나갈 때 한 번,
/// 그리고 앱이 백그라운드로 갈 때 함. 바뀐 게 없으면 저장 요청을 보내지 않음.
class MyRoomScreen extends StatefulWidget {
  final VoidCallback onPressed;

  const MyRoomScreen({super.key, required this.onPressed});

  @override
  State<MyRoomScreen> createState() => _MyRoomScreenState();
}

class _MyRoomScreenState extends State<MyRoomScreen> with WidgetsBindingObserver {
  final itemController = MyroomItemController.to;
  final myroomDataController = Get.put(MyroomDataController());

  // ── 배치 (시안 단위) ──
  static const double _panelRatio = 1 / 1.75; // 아래 판 높이 (화면 높이 대비)
  static const double _feetGap = 15; // 캐릭터 발 ~ 아래 판 (마이룸 단위)
  static const double _hatSpace = 20; // 캐릭터 위로 모자가 올라가는 높이 (마이룸 단위)

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // 홈 시작 때 옷장을 못 받았으면 다시 받음
    if (myroomDataController.myroomDataList.isEmpty) myroomService();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) itemController.saveIfChanged();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    itemController.saveIfChanged();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sc = DesignScale.of(mq.size, mq.padding);
    final s = sc.s;

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final h = constraints.maxHeight;
            final panelH = h * _panelRatio;
            final roomBottom = h - panelH; // 방(배경) 아래쪽 = 아래 판 위쪽
            final appBarBottom = mq.padding.top + sc.d(53);

            // 캐릭터 크기: 앱바 배율 그대로, 단 모자까지 앱바와 아래 판 사이에 들어가도록
            final available = roomBottom - appBarBottom;
            final k = math.min(s, available / (CharacterAvatar.characterHeight + _hatSpace + _feetGap));
            final charTop = roomBottom - (_feetGap + CharacterAvatar.characterHeight) * k;

            return Stack(
              children: [
                // 배경 (방 전체를 채우고 아래 판 뒤로 조금 들어감)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: roomBottom + sc.d(24),
                  child: Obx(() {
                    final url = itemController.backgroundImage.value;
                    return url.startsWith('http')
                        ? Image.network(
                            url,
                            fit: BoxFit.cover,
                            alignment: Alignment.bottomCenter,
                            errorBuilder: (_, __, ___) => _defaultBackground(),
                          )
                        : _defaultBackground();
                  }),
                ),
                // 캐릭터·옷·모자 (랭킹·앱바 프로필과 같은 배치)
                Positioned.fill(
                  child: Obx(() => Stack(
                        children: CharacterAvatar.layers(
                          characterIndex: itemController.characterIndex.value,
                          hatUrl: itemController.hatImage.value,
                          clothesUrl: itemController.clothingImage.value,
                          k: k,
                          roomLeft: w / 2 - CharacterAvatar.roomWidth / 2 * k,
                          charTop: charTop,
                        ),
                      )),
                ),
                // 캐릭터 변경 버튼
                Positioned(
                  top: appBarBottom + sc.d(8),
                  right: sc.d(14),
                  width: sc.d(55),
                  height: sc.d(55),
                  child: _switchButton(sc),
                ),
                // 아래 판: 카테고리 탭 + 아이템
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: panelH,
                  child: MyroomTab(itemController: itemController, s: s, bottomPadding: mq.padding.bottom),
                ),
                // 앱바 (홈과 같은 시안 좌표·크기). 저장은 화면을 나갈 때 (dispose)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: DesignAppBar(
                    scale: sc,
                    onPressed: widget.onPressed,
                    onDiamondPressed: () async => await productService(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _defaultBackground() {
    return Image.asset(
      'assets/images/myroom/background/background_1.png',
      fit: BoxFit.cover,
      alignment: Alignment.bottomCenter,
    );
  }

  Widget _switchButton(DesignScale sc) {
    const brown = Color(0xFF8B6767);
    return GestureDetector(
      onTap: itemController.nextCharacter,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E7),
          borderRadius: BorderRadius.circular(sc.d(15)),
          border: Border.all(width: sc.d(2), color: brown),
        ),
        padding: EdgeInsets.symmetric(vertical: sc.d(5), horizontal: sc.d(8)),
        child: Column(
          children: [
            Expanded(child: Image.asset('assets/images/myroom/myroom_switch.png', fit: BoxFit.contain)),
            Padding(
              padding: EdgeInsets.only(top: sc.d(2)),
              child: Text(
                '변경',
                style: TextStyle(fontFamily: 'BMJUA', fontSize: sc.d(11), color: brown, height: 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
