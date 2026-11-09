import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/data/models/bake_data.dart';
import 'package:hoho_hanja/main.dart';
import 'package:hoho_hanja/screens/bake/bake_widgets/bake_bear.dart';
import 'package:hoho_hanja/screens/bake/bake_widgets/bake_main.dart';
import 'package:hoho_hanja/screens/bake/bake_widgets/bake_question.dart';
import 'package:hoho_hanja/utils/design_scale.dart';
import 'package:hoho_hanja/widgets/appbar/design_app_bar.dart';
import 'package:hoho_hanja/widgets/game_hud.dart';

/// 단어의 의미 찾기 (베이커리)
class BakeScreen extends StatefulWidget {
  final String code;
  const BakeScreen(this.code, {super.key});

  @override
  State<BakeScreen> createState() => _BakeScreenState();
}

class _BakeScreenState extends State<BakeScreen> {
  // 배경 그림의 색 (양옆·위아래로 넓은 화면을 채울 때 사용)
  static const Color creamColor = Color(0xFFFEF9E7);
  static const Color counterLineColor = Color(0xFFDAA571);
  static const Color counterColor = Color(0xFFDCB68D);
  // 계산대 윗선 (시안 좌표)
  static const double counterTop = 158.33;
  static const double counterLineH = 3.67;

  final bakeData = Get.put(BakeDataController());
  int index = 0;
  bool isBearWeep = false;
  int solvedCount = 0; // 맞힌 문제 수 (앱바 가운데 표시)

  @override
  void initState() {
    music.playBackgroundMusic('bakery');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: counterColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final sc = DesignScale.of(constraints.biggest, mq.padding);
            // 배경은 세로는 시안 비율 그대로, 가로만 화면 폭에 맞춰 늘림 (태블릿에서 판이 화면을 꽉 채우도록)
            final kx = sc.dw / DesignScale.designWidth;
            final inset = (sc.dw - sc.maxContentWidth) / 3; // 앱바 양옆 여백

            return Stack(
              children: [
                // 배경색 (배경 그림 바깥)
                Positioned(left: 0, top: 0, right: 0, height: sc.y(counterTop), child: const ColoredBox(color: creamColor)),
                Positioned(
                  left: 0,
                  right: 0,
                  top: sc.y(counterTop),
                  height: sc.d(counterLineH),
                  child: const ColoredBox(color: counterLineColor),
                ),
                // 배경 그림
                sc.box(0, -24, sc.dw, 722, Image.asset('assets/images/bake/bake_bg.png', fit: BoxFit.fill)),
                // 앱바
                Positioned(
                  left: 0,
                  top: 0,
                  right: 0,
                  child: DesignAppBar(scale: sc, inset: inset),
                ),
                // 맞힌 문제 수 (앱바 바로 아래 가운데)
                GameHud.place(sc, GameHud(scale: sc, solved: solvedCount, total: bakeData.bakeDataList.length)),
                // 곰
                sc.box(40 * kx, 68, 100, 108, BakeBear(isWeep: isBearWeep)),
                // 문제
                sc.box(
                  60 * kx + 65,
                  // 위 진행 표시와 겹치지 않게 계산대 선(158.3) 바로 위까지 내림 (원래 71.95)
                  84,
                  350 * kx - (60 * kx + 65),
                  73.6,
                  BakeQuestion(question: bakeData.bakeDataList[index].quize, fontSize: sc.d(20)),
                ),
                // 빵 판
                Positioned.fill(
                  child: BakeMain(
                    code: widget.code,
                    bakeData: bakeData,
                    scale: sc,
                    kx: kx,
                    onQuestionChanged: (i) => setState(() => index = i),
                    onWeepBear: (weep) {
                      if (weep != isBearWeep) setState(() => isBearWeep = weep);
                    },
                    onSolvedChanged: (n) => setState(() => solvedCount = n),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    music.stopBackgroundMusic('bakery'); // 홈으로 돌아가며 홈이 다시 튼 음악은 그대로
    super.dispose();
  }
}
