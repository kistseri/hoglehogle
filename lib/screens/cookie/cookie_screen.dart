import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/data/models/cookie_data.dart';
import 'package:hoho_hanja/main.dart';
import 'package:hoho_hanja/screens/cookie/cookie_widgets/cookie_game.dart';
import 'package:hoho_hanja/screens/cookie/cookie_widgets/cookie_question.dart';
import 'package:hoho_hanja/utils/design_scale.dart';
import 'package:hoho_hanja/widgets/appbar/design_app_bar.dart';
import 'package:hoho_hanja/widgets/game_hud.dart';

class CookieScreen extends StatefulWidget {
  final String code;

  const CookieScreen(this.code, {super.key});

  @override
  State<CookieScreen> createState() => _CookieScreenState();
}

class _CookieScreenState extends State<CookieScreen> {
  final cookieController = Get.put(CookieDataController());
  // 게임은 한 번만 만듦 (화면 크기 변경 등으로 다시 그려져도 처음부터 다시 시작하지 않게)
  CookieGame? _game;

  @override
  void initState() {
    super.initState();
    music.playBackgroundMusic('cookie');
  }

  // 시안(360 x 720 휴대폰) 기준 배치. 모두 화면 아래에서부터의 시안 좌표로, 배율 하나로만 키우거나 줄인다.
  // 태블릿처럼 넓은 화면은 시안 폭(360)을 가운데에 두고, 배경만 양옆까지 채운다.
  static const double _groundHeight = 75; // 아래 갈색 땅
  static const double _cookieSize = 65;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sc = DesignScale.of(mq.size, mq.padding);
    double d(num v) => sc.d(v);
    // 시안 영역 왼쪽 끝 (넓은 화면에서 가운데 정렬)
    final left = (mq.size.width - d(DesignScale.designWidth)) / 2;
    final bottom = mq.padding.bottom; // 홈 표시줄 위부터
    final inset = (sc.dw - sc.maxContentWidth) / 3; // 앱바 양옆 여백

    final game = _game ??= CookieGame(
      code: widget.code,
      // 앱바·진행 표시 아래부터 쿠키를 떨어뜨림
      topInset: sc.y(GameHud.bottom + 4),
      // 땅 윗면 (쿠키는 땅 뒤로 쑥 들어가며 사라짐)
      groundTop: mq.size.height - bottom - d(_groundHeight),
      cookieSize: d(_cookieSize),
    );

    // 시안 좌표 (x: 왼쪽부터, b: 아래부터, 폭·높이)로 배치
    Widget place(num x, num b, num w, num h, Widget child) {
      return Positioned(left: left + d(x), bottom: bottom + d(b), width: d(w), height: d(h), child: child);
    }

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Stack(
          children: [
            // 배경: 비율 유지하며 화면을 채움 (넘치는 아래 모래 쪽을 자름)
            const Positioned.fill(
              child: Image(
                image: AssetImage('assets/images/cookie/cookie_bg.png'),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
            // 게임 (쿠키는 화면 폭 전체에서 떨어짐)
            Positioned.fill(child: GameWidget(game: game)),
            // 꼬리·땅·다람쥐는 쿠키보다 앞에 그림: 쿠키가 땅 뒤로 쑥 들어가며 사라지게 (터치는 뒤의 쿠키로 통과)
            // 다람쥐 꼬리 (원래 163 x 166 그림을 절반 크기로)
            place(-11.5, 50, 81.5, 83,
                IgnorePointer(child: Image.asset('assets/images/cookie/squirrel_tail1.png', fit: BoxFit.contain))),
            // 땅 (홈 표시줄 칸까지 채움)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: bottom + d(_groundHeight),
              child: const IgnorePointer(child: ColoredBox(color: Colors.brown)),
            ),
            // 다람쥐 (원래 228 x 227 그림을 2.5분의 1 크기로)
            place(
              28.8,
              70,
              91.2,
              90.8,
              IgnorePointer(
                child: Obx(
                  // 맞힌 직후엔 좋아하는 얼굴, 틀리거나 정답이 바닥 가까이 오면 걱정하는 얼굴
                  () => Image.asset(
                    cookieController.isHappy.value
                        ? 'assets/images/cookie/squirrel_fighting.png'
                        : cookieController.isWorried.value
                            ? 'assets/images/cookie/squirrel_worry.png'
                            : 'assets/images/cookie/squirrel_smile.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            // 문제 말풍선: 쿠키보다 위에 그려서 가려지지 않게 (터치는 뒤의 쿠키로 통과)
            if (cookieController.quiz.isNotEmpty)
              place(
                125,
                86,
                225,
                75,
                IgnorePointer(
                  child: Obx(
                    () => CookieQuestion(scale: sc, question: cookieController.quiz[game.currentIndex.value].question),
                  ),
                ),
              ),
            // 앱바 (다른 게임 화면과 같은 시안 좌표·크기)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: DesignAppBar(scale: sc, inset: inset),
            ),
            // 가운데 큰 글자: 시작 카운트다운(3 → 2 → 1 → 시작!), 끝날 때 '다 모았어요!'/'아쉬워요!'
            Positioned.fill(
              child: IgnorePointer(
                child: Obx(() {
                  final text = game.bannerText.value;
                  if (text.isEmpty) return const SizedBox.shrink();
                  return Center(
                    child: TweenAnimationBuilder<double>(
                      // 글자가 바뀔 때마다 크게 나타났다가 제자리로
                      key: ValueKey(text),
                      tween: Tween(begin: 1.6, end: 1.0),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) => Transform.scale(scale: value, child: child),
                      // 기본 폰트(NotoSansKR-Regular)에 w900 + 대각선 그림자로 테두리를 흉내 내면 글자가 깨져 보여서
                      // 굵은 단일 폰트(BMJUA)에 실제 외곽선(stroke)을 깔고 그 위에 채운 글자를 겹침
                      child: Builder(builder: (context) {
                        final fontSize = d(text.length <= 1 ? 80 : (text.length <= 3 ? 56 : 44));
                        return Stack(
                          children: [
                            Text(
                              text,
                              style: TextStyle(
                                fontSize: fontSize,
                                fontFamily: 'BMJUA',
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 6 * sc.s
                                  ..strokeJoin = StrokeJoin.round
                                  ..color = mFontBrown,
                              ),
                            ),
                            Text(
                              text,
                              style: TextStyle(fontSize: fontSize, fontFamily: 'BMJUA', color: mFontYellow),
                            ),
                          ],
                        );
                      }),
                    ),
                  );
                }),
              ),
            ),
            // 남은 목숨 · 맞힌 문제 수 (앱바 바로 아래 가운데)
            GameHud.place(
              sc,
              Obx(
                () => GameHud(
                  scale: sc,
                  solved: game.solved.value,
                  total: cookieController.quiz.length,
                  lives: game.lives.value,
                  maxLives: CookieGame.maxLives,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    music.stopBackgroundMusic('cookie'); // 홈으로 돌아가며 홈이 다시 튼 음악은 그대로
    super.dispose();
  }
}
