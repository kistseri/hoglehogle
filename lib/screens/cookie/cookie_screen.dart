import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/data/models/cookie_data.dart';
import 'package:hoho_hanja/main.dart';
import 'package:hoho_hanja/screens/cookie/cookie_widgets/cookie_game.dart';
import 'package:hoho_hanja/screens/cookie/cookie_widgets/cookie_question.dart';
import 'package:hoho_hanja/utils/design_scale.dart';
import 'package:hoho_hanja/widgets/appbar/design_app_bar.dart';

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

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sc = DesignScale.of(mq.size, mq.padding);
    final game = _game ??= CookieGame(
      code: widget.code,
      // 앱바 아래부터 쿠키를 떨어뜨림
      topInset: sc.y(DesignAppBar.height),
      cookieSize: 65.r,
    );
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Stack(
          children: [
            Positioned(
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/cookie/cookie_bg.png'),
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
            if (cookieController.quiz.isNotEmpty)
              Obx(() => CookieQuestion(question: cookieController.quiz[game.currentIndex.value].question)),
            Positioned(
              bottom: 50.h,
              right: 290.w,
              child: Image.asset(
                'assets/images/cookie/squirrel_tail1.png',
                scale: 2,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: const BoxDecoration(color: Colors.brown),
                height: 75.h,
              ),
            ),
            Positioned(
              bottom: 70.h,
              right: 240.w,
              child: Obx(
                () => Image.asset(
                  cookieController.isWorried.value
                      ? 'assets/images/cookie/squirrel_worry.png'
                      : 'assets/images/cookie/squirrel_smile.png',
                  scale: 2.5,
                ),
              ),
            ),
            Positioned.fill(
              child: GameWidget(game: game),
            ),
            // 앱바 (다른 게임 화면과 같은 시안 좌표·크기)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: DesignAppBar(scale: sc, inset: (sc.dw - sc.maxContentWidth) / 3),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    music.stopBackgroundMusic();
    super.dispose();
  }
}
