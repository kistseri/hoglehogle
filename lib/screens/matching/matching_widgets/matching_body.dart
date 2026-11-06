import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/constants.dart';
import 'package:hoho_hanja/data/models/matching_menu_data.dart';
import 'package:hoho_hanja/services/matching/matching_service.dart';
import 'package:hoho_hanja/utils/design_scale.dart';
import 'package:hoho_hanja/widgets/appbar/design_app_bar.dart';

/// 한자 맞추기 단원 선택 화면 (앱바 + 제목 + 단원 칸)
///
/// 단원 목록은 따라쓰기와 같은 메뉴(TRACING_BODY_URL)를 쓴다.
/// 홈과 같이 시안(360 x 698, 상태바 제외) 좌표를 배율 하나로만 키우거나 줄인다.
/// 8급처럼 주제가 있는 단원은 번호·주제·한자 한 줄, 준6급부터처럼 주제가 없는 단원은 번호·한자 두 줄.
/// 칸이 8개를 넘으면(7급부터 10개) 아래로 스크롤.
class MatchingBody extends StatelessWidget {
  // 화면 양옆 여백 = 칸 사이 간격 (시안 단위)
  static const double margin = 14;
  static const double cardH = 114;
  // 첫 줄 칸 위쪽, 스크롤 영역 위쪽 (칸이 이 선에서 잘림)
  static const double gridTop = 126;
  static const double listTop = 110;
  // 한자 알약
  static const double pillInset = 17;
  static const double pillLineH = 18;
  static const double hanjaSize = 10;
  static const double hanjaSpacing = 3.5;

  final String phase;
  final int openPage;
  final bool isUnlocked; // 이 급수 콘텐츠가 열려 있는지
  final matchingBodyData = Get.put(MatchingMenuDataController());

  MatchingBody({
    super.key,
    required this.phase,
    required this.openPage,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final menus = matchingBodyData.matchingMenuDataList ?? [];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final sc = DesignScale.of(constraints.biggest, mq.padding);
          // 칸 2개 + 여백·간격 3개가 화면 폭을 채움 (여백 = 간격)
          final cardW = (sc.maxContentWidth - margin * 3) / 2;
          final m = (sc.dw - cardW * 2) / 3;

          return Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                right: 0,
                child: DesignAppBar(scale: sc, inset: m - margin),
              ),
              sc.place(
                cx: sc.dw / 2,
                cy: 90,
                size: 22,
                child: Text(
                  '한자 맞추기',
                  style: TextStyle(color: mFontMain, fontSize: sc.d(22), fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                left: 0,
                top: sc.y(listTop),
                right: 0,
                bottom: 0,
                child: GridView.builder(
                  padding: EdgeInsets.fromLTRB(
                    sc.d(m),
                    sc.d(gridTop - listTop),
                    sc.d(m),
                    mq.padding.bottom + sc.d(margin),
                  ),
                  itemCount: menus.length,
                  // 8개 이하도 화면에 다 안 들어가면 스크롤되도록 (넘칠 때만 움직임)
                  physics: menus.length <= 8 ? const ClampingScrollPhysics() : const AlwaysScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisExtent: sc.d(cardH),
                    mainAxisSpacing: sc.d(margin),
                    crossAxisSpacing: sc.d(m),
                  ),
                  itemBuilder: (context, index) {
                    final gubun = menus[index].gubun;
                    return GestureDetector(
                      onTap: () async {
                        // 열린 급수면 카드 전부, 아니면 openPage장까지만
                        await matchingService(phase, isUnlocked ? null : openPage, gubun);
                      },
                      child: _card(sc, cardW, index),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // 칸 안에서 시안 좌표 (x, y, 폭, 높이)에 배치
  Widget _at(DesignScale sc, num x, num y, num w, num h, Widget child) {
    return Positioned(left: sc.d(x), top: sc.d(y), width: sc.d(w), height: sc.d(h), child: child);
  }

  // 단원 칸 (cardW: 칸 폭, 시안 단위)
  Widget _card(DesignScale sc, double cardW, int index) {
    final item = matchingBodyData.matchingMenuDataList![index];
    // 색상은 12개라 메뉴가 더 많으면 반복
    final color = index % gridColors.length;
    final hasSubject = item.subject.isNotEmpty;

    // 한자는 주제가 있고 8자 이하면 한 줄, 아니면 반씩 두 줄
    final hanja = item.hanja.split(' ').where((h) => h.isNotEmpty).toList();
    final half = (hanja.length / 2).ceil();
    final lines = hasSubject && hanja.length <= 8
        ? [hanja.join()]
        : [hanja.sublist(0, half).join(), hanja.sublist(half).join()].where((l) => l.isNotEmpty).toList();
    final pillH = pillLineH * lines.length;

    final number = Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(color: gridInsideColors[color], shape: BoxShape.circle),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(item.gubun, style: TextStyle(color: mFontWhite, fontSize: sc.d(12))),
      ),
    );

    final pill = Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: sc.d(6)),
      decoration: BoxDecoration(
        color: gridInsideColors[color],
        borderRadius: BorderRadius.circular(sc.d(9)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        // 글자 간격이 마지막 글자 뒤에도 붙으므로 왼쪽에 같은 만큼 띄워 가운데 맞춤
        child: Padding(
          padding: EdgeInsets.only(left: sc.d(hanjaSpacing)),
          child: Text(
            lines.join('\n'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: mFontWhite,
              fontSize: sc.d(hanjaSize),
              letterSpacing: sc.d(hanjaSpacing),
              height: 1.4,
            ),
          ),
        ),
      ),
    );

    // 주제가 없으면 번호·한자를 칸 가운데에 모음
    final groupTop = (cardH - (25 + 12 + pillH)) / 2;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: gridColors[color],
        borderRadius: BorderRadius.circular(sc.d(20)),
      ),
      child: Stack(
        children: hasSubject
            ? [
                _at(sc, 8, 11, 25, 25, number),
                _at(
                  sc,
                  8,
                  35,
                  cardW - 16,
                  26,
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      item.subject,
                      style: TextStyle(color: gridElement[color], fontSize: sc.d(19), fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                _at(sc, pillInset, 96.5 - pillH, cardW - pillInset * 2, pillH, pill),
              ]
            : [
                _at(sc, cardW / 2 - 12.5, groupTop, 25, 25, number),
                _at(sc, pillInset, groupTop + 37, cardW - pillInset * 2, pillH, pill),
              ],
      ),
    );
  }
}
