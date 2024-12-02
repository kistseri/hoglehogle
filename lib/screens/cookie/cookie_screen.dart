import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/data/models/cookie_data.dart';
import 'package:hoho_hanja/main.dart';
import 'package:hoho_hanja/screens/cookie/cookie_widgets/cookie_game.dart';
import 'package:hoho_hanja/screens/cookie/cookie_widgets/cookie_question.dart';
import 'package:hoho_hanja/widgets/appbar/custom_appbar.dart';

class CookieScreen extends StatefulWidget {
  final String code;

  const CookieScreen(this.code, {super.key});

  @override
  State<CookieScreen> createState() => _CookieScreenState();
}

class _CookieScreenState extends State<CookieScreen> {
  final cookieController = Get.put(CookieDataController());

  @override
  void initState() {
    super.initState();
    music.playBackgroundMusic('cookie');
  }

  @override
  Widget build(BuildContext context) {
    final CookieGame game = CookieGame(code: widget.code);
    return Scaffold(
      body: Stack(
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
          Obx(() => CookieQuestion(
              question: cookieController.quiz[game.currentIndex.value]
                  ['options'][0])),
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
              decoration: BoxDecoration(color: Colors.brown),
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
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomAppBar(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    music.stopBackgroundMusic();
    super.dispose();
  }
}
