import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/constants.dart';
import 'package:hoho_hanja/_core/icon.dart';
import 'package:hoho_hanja/data/models/contents_data.dart';
import 'package:hoho_hanja/data/models/goods_data.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/screens/myroom/myroom_wigets/my_room_circle.dart';
import 'package:hoho_hanja/services/auth/my_goods_service.dart';
import 'package:hoho_hanja/services/bake/bake_service.dart';
import 'package:hoho_hanja/services/cookie/cookie_service.dart';
import 'package:hoho_hanja/services/define/define_service.dart';
import 'package:hoho_hanja/services/idiom/idiom_service.dart';
import 'package:hoho_hanja/services/matching/matching_service.dart';
import 'package:hoho_hanja/services/purchase/product_service.dart';
import 'package:hoho_hanja/services/tracing/tracing_body_service.dart';
import 'package:hoho_hanja/utils/connect_info.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';
import 'package:hoho_hanja/widgets/dialog/unlock_dilog.dart';

/// 홈 화면 전체 (앱바 + 본문 + 하단 탭)
///
/// 시안(360 x 698, 상태바 제외)의 좌표를 그대로 쓰고, 화면에 들어가는 배율 하나로만 키우거나 줄인다.
/// 그래서 휴대폰과 태블릿처럼 화면 비율이 달라도 배치가 똑같이 보인다.
/// 태블릿에서 남는 양옆은 배경(초록·노랑·흰색)만 화면 끝까지 늘려서 채운다.
class HomeBody extends StatefulWidget {
  final String grade;
  final ValueChanged<String> onGradeChanged;
  final ValueChanged<int> onTabChanged;
  final VoidCallback onAvatarPressed;

  const HomeBody({
    super.key,
    required this.grade,
    required this.onGradeChanged,
    required this.onTabChanged,
    required this.onAvatarPressed,
  });

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  // 시안 크기 (상태바 제외)
  static const double designWidth = 360;
  static const double designHeight = 698;

  // 화면 양옆 여백 = 위·아래 카드 사이 간격 (휴대폰 기준, 아래 카드가 그림 원래 폭 103이 되는 값)
  static const double baseMargin = 12.75;

  // 화면이 시안보다 옆으로 넓으면(태블릿) 카드는 시안 폭의 이 배수까지만 커지고, 그보다 넓으면 남는 폭은 여백·간격으로 나눔
  static const double maxWidthStretch = 1.35;

  final loginController = Get.put(LoginDataController(), permanent: true);
  final goodsController = Get.put(GoodsDataController());
  final contentsData = Get.put(ContentsDataController());

  double _s = 1; // 시안 → 화면 배율
  double _dw = designWidth; // 화면 폭 (시안 단위)
  double _top = 0; // 시안 영역의 화면상 위쪽
  double _m = baseMargin; // 화면 양옆 여백 = 카드 사이 간격 (시안 단위)
  double _expandW = 103; // 아래 카드 폭 (시안 단위)

  // 시안에서 오른쪽 끝 기준으로 놓인 x를 화면 폭·여백에 맞게 옮김
  double _r(num v) => v + (_dw - designWidth) - (_m - baseMargin);

  double _d(num v) => v * _s;
  double _x(num v) => v * _s;
  double _y(num v) => _top + v * _s;

  String get grade => widget.grade;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      myGoodsService();
    });
  }

  bool isContentLocked(String grade) {
    return contentsData.contentsDataList.any((content) => content.phase == grade && content.lock);
  }

  // 시안 좌표 (x, y, 폭, 높이)에 배치
  Widget _box(num x, num y, num w, num h, Widget child) {
    return Positioned(left: _x(x), top: _y(y), width: _d(w), height: _d(h), child: child);
  }

  // 글자 배치: 세로는 cy에 가운데, 가로는 cx에 가운데 정렬 또는 left부터 왼쪽 정렬
  // 글자는 터치를 막지 않도록 IgnorePointer
  Widget _place({num? left, num? cx, required num cy, required num size, num w = 240, required Widget child}) {
    final h = size * 4;
    return _box(
      cx != null ? cx - w / 2 : left!,
      cy - h / 2,
      w,
      h,
      IgnorePointer(
        child: Align(
          alignment: cx != null ? Alignment.center : Alignment.centerLeft,
          child: child,
        ),
      ),
    );
  }

  TextStyle _style(num size, {bool bold = false, Color color = mFontMain, double? height}) {
    return TextStyle(
      color: color,
      fontSize: _d(size),
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      height: height,
    );
  }

  // 코인·다이아 숫자 (흰 글자 + 회색 테두리)
  TextStyle _outlineStyle(num size) {
    final o = _d(1);
    return TextStyle(
      fontFamily: 'BMJUA',
      fontSize: _d(size),
      color: Colors.white,
      shadows: [
        for (final offset in [Offset(0, -o), Offset(o, 0), Offset(0, o), Offset(-o, 0)])
          Shadow(offset: offset, color: Colors.grey, blurRadius: o),
      ],
    );
  }

  bool _tracingBusy = false; // 따라쓰기 연타 방지

  Future<void> _onTracing() async {
    if (_tracingBusy) return;
    // 잠금 정보를 아직 못 받았으면(불러오기 실패·급수 바꾸는 중) 들어가지 않음
    final tracing = contentsData.contentsDataList
        .firstWhereOrNull((content) => content.code == contentsCodes['tracing'] && content.phase == grade);
    if (tracing == null) {
      failDialog('불러오기 실패', '잠시 후 다시 시도해주세요.');
      return;
    }

    _tracingBusy = true;
    try {
      await connectInfo(contentsCodes['tracing']);
      // isContentLocked는 이름과 달리 '열림' 여부
      await tracingBodyService(grade, tracing.openPage, isContentLocked(grade));
    } finally {
      _tracingBusy = false;
    }
  }

  bool _matchingBusy = false; // 맞추기 연타 방지

  Future<void> _onMatching() async {
    if (_matchingBusy) return;
    // 잠금 정보를 아직 못 받았으면(불러오기 실패·급수 바꾸는 중) 들어가지 않음
    final matching = contentsData.contentsDataList
        .firstWhereOrNull((content) => content.code == contentsCodes['matching'] && content.phase == grade);
    if (matching == null) {
      failDialog('불러오기 실패', '잠시 후 다시 시도해주세요.');
      return;
    }

    _matchingBusy = true;
    try {
      await connectInfo(contentsCodes['matching']);
      // isContentLocked는 이름과 달리 '열림' 여부. 열려 있으면 카드 전부(null)
      await matchingService(grade, isContentLocked(grade) ? null : matching.openPage);
    } finally {
      _matchingBusy = false;
    }
  }

  Future<void> _onDefine() async {
    if (isContentLocked(grade)) {
      await connectInfo(contentsCodes['define']);
      await defineService(grade, contentsCodes['define']);
    } else {
      showUnlockDialog(grade);
    }
  }

  bool _bakeBusy = false; // 베이커리 연타 방지

  Future<void> _onBake() async {
    if (_bakeBusy) return;
    if (isContentLocked(grade)) {
      _bakeBusy = true;
      try {
        await connectInfo(contentsCodes['bake']);
        await bakeService(grade, contentsCodes['bake']);
      } finally {
        _bakeBusy = false;
      }
    } else {
      showUnlockDialog(grade);
    }
  }

  Future<void> _onCookie() async {
    if (isContentLocked(grade)) {
      await connectInfo(contentsCodes['cookie']);
      await cookieService(grade, contentsCodes['cookie']);
    } else {
      showUnlockDialog(grade);
    }
  }

  Future<void> _onIdiom() async {
    if (isContentLocked(grade)) {
      await connectInfo(contentsCodes['idiom']);
      await idiomService(grade, contentsCodes['idiom']);
    } else {
      showUnlockDialog(grade);
    }
  }

  // 한자의 의미를 익혀요 - 가로형 카드 (카드가 넓어져도 그림은 시안 크기 그대로 위쪽 가운데)
  List<Widget> _learnCard(num x, num w, String image, Color color, String subTitle, String title, VoidCallback onTap) {
    const y = 205, h = 110;
    return [
      _box(
        x,
        y,
        w,
        h,
        GestureDetector(
          onTap: onTap,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_d(34)),
            child: ColoredBox(
              color: color,
              child: Align(
                alignment: Alignment.topCenter,
                child: Image.asset(image, width: _d(159), fit: BoxFit.fitWidth),
              ),
            ),
          ),
        ),
      ),
      _place(cx: x + w / 2, cy: 272.5, size: 11, child: Text(subTitle, style: _style(11))),
      _place(cx: x + w / 2, cy: 288.5, size: 14.5, child: Text(title, style: _style(14.5, bold: true))),
    ];
  }

  // 한자의 의미를 확장시켜요 - 세로형 카드 (그림 안에 위쪽 제목 포함)
  // 카드가 그림보다 넓어지면 그림 속 알약과 같은 색·같은 모서리의 배경을 뒤에 깔아 알약을 옆으로 늘린 것처럼 보이게 함
  List<Widget> _expandCard(num x, num w, String image, Color color, String title, VoidCallback onTap) {
    const imageW = 103;
    return [
      if (w > imageW + 0.5)
        _box(
          x,
          394.3,
          w,
          156.7,
          DecoratedBox(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.vertical(top: Radius.circular(_d(33)), bottom: Radius.circular(_d(36.5))),
            ),
          ),
        ),
      _box(x + (w - imageW) / 2, 381, imageW, 170, Image.asset(image, fit: BoxFit.fill)),
      _box(x, 381, w, 170, GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap)),
      _place(
        cx: x + w / 2,
        cy: 516,
        size: 13.5,
        child: Text(title, textAlign: TextAlign.center, style: _style(13.5, bold: true, height: 16 / 13.5)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenW = constraints.maxWidth;
          final screenH = constraints.maxHeight;
          final availableH = screenH - mq.padding.top - mq.padding.bottom;

          _s = math.min(screenW / designWidth, availableH / designHeight);
          _dw = screenW / _s;
          _top = mq.padding.top;
          // 아래 카드 3개 + 여백·간격 4개가 화면 폭을 채움 (여백 = 간격)
          _expandW = (math.min(_dw, designWidth * maxWidthStretch) - baseMargin * 4) / 3;
          _m = (_dw - _expandW * 3) / 4;
          // 하단 탭은 항상 화면 아래(홈 바 위)에 붙임
          final navTop = screenH - mq.padding.bottom - _d(54);

          final navIcons = [
            rank(_d(29), _d(29)),
            myRoom(_d(29), _d(29)),
            ativeHome(_d(29), _d(29)),
            setting(_d(29), _d(29)),
          ];
          const navCenters = [51.0, 136.5, 222.5, 310.0];

          // 위 카드 2개도 같은 여백·간격
          final learnW = (_dw - _m * 3) / 2;

          return Stack(
            children: [
              // ───── 배경 (양옆 화면 끝까지) ─────
              // 초록: 상태바 ~ 앱바 아래, 오른쪽 아래 둥근 곡선
              Positioned(
                left: 0,
                top: 0,
                width: screenW,
                height: _y(119),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: mBoxGreen,
                    borderRadius: BorderRadius.only(bottomRight: Radius.circular(_d(91))),
                  ),
                ),
              ),
              // 인사말 노란 박스 (화면 왼쪽 끝에 붙음)
              Positioned(
                left: 0,
                top: _y(54),
                width: _x(_dw * 0.8),
                height: _d(100),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: mBoxYellow,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(_d(25)),
                      topRight: Radius.circular(_d(25)),
                      bottomRight: Radius.circular(_d(25)),
                    ),
                  ),
                ),
              ),
              // 노란색 꼬리 (흰 영역 왼쪽 위 둥근 모서리 뒤)
              Positioned(
                left: 0,
                top: _y(154),
                width: _d(30),
                height: _d(30),
                child: const ColoredBox(color: mBoxYellow),
              ),
              // 흰 영역
              Positioned(
                left: 0,
                right: 0,
                top: _y(154),
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(_d(28))),
                  ),
                ),
              ),
              // 하단 탭 배경
              Positioned(
                left: 0,
                right: 0,
                top: navTop,
                bottom: 0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(_d(25)),
                      topRight: Radius.circular(_d(25)),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: _d(8),
                        spreadRadius: _d(-3),
                        offset: Offset(0, _d(-4)),
                      ),
                    ],
                  ),
                ),
              ),

              // ───── 앱바 ─────
              // 급수 별칭(2~4글자) + 급수 선택: 별칭이 한 글자 늘 때마다 드롭다운이 그만큼 오른쪽으로 밀림
              Positioned(
                left: _x(_m + 1.25),
                top: _y(8),
                height: _d(37),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ConstrainedBox(
                      // 4글자까지 (더 길면 …)
                      constraints: BoxConstraints(maxWidth: _d(15 * 4 + 1)),
                      child: Text(
                        alias[grade] ?? '',
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: _style(15, color: Colors.black),
                      ),
                    ),
                    // 급수 선택
                    PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      offset: Offset(0, _d(37)),
                      onSelected: widget.onGradeChanged,
                      itemBuilder: (context) => grades.entries
                          .map(
                            (e) => PopupMenuItem<String>(
                              value: e.key,
                              child: Text(
                                '${e.value}  ${alias[e.key]}',
                                style: TextStyle(
                                  color: mFontMain,
                                  fontWeight: e.key == grade ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      child: Container(
                        // 누르는 영역은 앱바 높이만큼
                        height: _d(37),
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(left: _d(3)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: _d(35),
                              height: _d(19),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: mBackWhite,
                                borderRadius: BorderRadius.circular(_d(9.5)),
                              ),
                              child: Text(grades[grade] ?? '', style: _style(11, bold: true, color: primaryColor)),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: _d(4)),
                              child: Icon(CupertinoIcons.chevron_down, color: mFontWhite, size: _d(12)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 코인
              _box(_r(207.7), 18.9, 16, 16, Image.asset('assets/images/icon/coin.png')),
              _place(
                left: _r(225),
                cy: 27,
                size: 15,
                child: Obx(() => Text(goodsController.formattedCoin.value, style: _outlineStyle(15))),
              ),
              // 다이아 (누르면 구매)
              _box(_r(273.5), 18.3, 17, 17, Image.asset('assets/images/icon/diamond.png')),
              _place(
                left: _r(293),
                cy: 27,
                size: 15,
                child: Obx(() => Text(goodsController.formattedDia.value, style: _outlineStyle(15))),
              ),
              _box(
                _r(268),
                8,
                50,
                37,
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    await productService();
                  },
                ),
              ),
              // 프로필
              _box(
                _r(324.5),
                14.5,
                24,
                24,
                GestureDetector(
                  onTap: widget.onAvatarPressed,
                  child: MyRoomCircleAvatar(size: _d(24)),
                ),
              ),

              // ───── 인사말 ─────
              // 닉네임이 길면 박스 안에 들어가도록 글자를 줄임
              _box(
                _m + 15.25,
                64,
                _dw * 0.8 - _m - 25.25,
                80,
                IgnorePointer(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: loginController.loginData.value?.nickName ?? '',
                            style: const TextStyle(fontFamily: 'NotoSansKR-Bold'),
                          ),
                          const TextSpan(text: '님 안녕하세요!\n오늘은 어떤 한자를 배울까요?'),
                        ],
                      ),
                      style: _style(20, height: 1.2),
                    ),
                  ),
                ),
              ),

              // ───── 한자의 의미를 익혀요 ─────
              _place(left: _m + 3.75, cy: 184.5, size: 12.5, child: Text('한자의 의미를 익혀요', style: _style(12.5, bold: true))),
              //한자 따라쓰기
              ..._learnCard(_m, learnW, 'assets/images/main_tracing.png', const Color(0xFFFFD051), '의미 시각화', '획순 따라쓰기', _onTracing),
              //한자 맞추기
              ..._learnCard(
                _m * 2 + learnW,
                learnW,
                'assets/images/main_matching.png',
                const Color(0xFFCFE759),
                '한자 외우기',
                '${grades[grade] ?? ''}한자 맞추기',
                _onMatching,
              ),

              // ───── 한자의 의미를 확장시켜요 ─────
              _place(left: _m + 3.75, cy: 358.5, size: 12.5, child: Text('한자의 의미를 확장시켜요', style: _style(12.5, bold: true))),
              //단어의 뜻 찾기
              ..._expandCard(_m, _expandW, 'assets/images/main_define.png', const Color(0xFF97DAFF), '단어의\n뜻 찾기', _onDefine),
              //단어의 의미 찾기
              ..._expandCard(_m * 2 + _expandW, _expandW, 'assets/images/main_bake.png', const Color(0xFFB5CCFA), '단어의\n의미 찾기', _onBake),
              //한자의 뜻 맞추기
              ..._expandCard(_m * 3 + _expandW * 2, _expandW, 'assets/images/main_cookie.png', const Color(0xFF8DE2DE), '한자의\n뜻 맞추기', _onCookie),

              // ───── 한자성어 문제 ─────
              if (grade != '80' && grade != '70') ...[
                _box(_m + 16, 567, _dw - _m * 2 - 32, 46, const ColoredBox(color: Color(0xFFE3D3F8))),
                _box(_m, 558, 17, 65, Image.asset('assets/images/icon/main_idioms.png', fit: BoxFit.fill)),
                _box(_dw - _m - 17, 558, 17, 65, Image.asset('assets/images/icon/main_idioms.png', fit: BoxFit.fill)),
                _place(cx: _dw / 2, cy: 590, size: 14.5, child: Text('한자성어 문제', style: _style(14.5, bold: true))),
                _box(_m, 558, _dw - _m * 2, 65, GestureDetector(behavior: HitTestBehavior.opaque, onTap: _onIdiom)),
              ],

              // ───── 하단 탭 아이콘 ─────
              for (int i = 0; i < navIcons.length; i++)
                Positioned(
                  left: _x(navCenters[i] * _dw / designWidth - 40),
                  top: navTop,
                  width: _d(80),
                  height: _d(54),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => widget.onTabChanged(i),
                    child: Center(child: navIcons[i]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
