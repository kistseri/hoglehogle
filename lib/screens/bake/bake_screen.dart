import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/data/models/bake_data.dart';
import 'package:hoho_hanja/main.dart';
import 'package:hoho_hanja/screens/bake/bake_widgets/bake_bear.dart';
import 'package:hoho_hanja/screens/bake/bake_widgets/bake_main.dart';
import 'package:hoho_hanja/screens/bake/bake_widgets/bake_question.dart';
import 'package:hoho_hanja/widgets/appbar/custom_appbar.dart';

class BakeScreen extends StatefulWidget {
  final String code;
  const BakeScreen(this.code, {super.key});

  @override
  State<BakeScreen> createState() => _BakeScreenState();
}

class _BakeScreenState extends State<BakeScreen> {
  final bakeData = Get.put(BakeDataController());
  int index = 0;
  bool isBearWeep = false;

  void updateIndex(int currentIndex) {
    setState(() {
      index = currentIndex;
    });
  }

  void updateBearCryingStatus(bool weep) {
    setState(() {
      isBearWeep = weep;
    });
  }

  @override
  void initState() {
    music.playBackgroundMusic('bakery');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경화면
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bake/bake_bg.png'),
                fit: BoxFit.fill,
              ),
            ),
          ),
          // 앱바
          const CustomAppBar(),
          // 곰
          BakeBear(isWeep: isBearWeep),
          // 문제
          BakeQuestion(question: bakeData.bakeDataList[index].quize),
          // 보기 나오는 공간
          BakeMain(
            code: widget.code,
            bakeData: bakeData,
            index: index,
            updateIndex: updateIndex,
            onWeepBear: updateBearCryingStatus,
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
