import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/size.dart';
import 'package:hoho_hanja/data/models/define_data.dart';
import 'package:hoho_hanja/main.dart';
import 'package:hoho_hanja/utils/result_service.dart';
import 'package:hoho_hanja/widgets/appbar/custom_appbar.dart';
import 'package:hoho_hanja/widgets/dialog/result_dialog.dart';

class DefineScreen extends StatefulWidget {
  final String code;

  const DefineScreen(this.code, {super.key});

  @override
  State<DefineScreen> createState() => _DefineScreenState();
}

class _DefineScreenState extends State<DefineScreen> {
  final defineController = Get.put(DefineDataController());
  int currentQuestionIndex = 0;
  int correctCount = 0;
  int inCorrectCount = 0;
  List<Map<String, String>> incorrectAnswers = [];
  List<String> options = [];

  bool isCorrect = false;
  bool isWrong = false;
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    music.playBackgroundMusic('quiz');
    loadQuestion();
  }

  void loadQuestion() {
    options = List<String>.from(
        defineController.quiz[currentQuestionIndex]['options']);
    options.shuffle(Random());
  }

  void checkAnswer(String selectedAnswer) async {
    String correctAnswer =
        defineController.quiz[currentQuestionIndex]['options'][0];

    if (selectedAnswer == correctAnswer) {
      effect.correctSound();
      correctCount++;
      setState(() {
        isCorrect = true;
        isWrong = false;
      });

      await Future.delayed(Duration(milliseconds: 1000));

      if (currentQuestionIndex < defineController.quiz.length - 1) {
        setState(() {
          currentQuestionIndex++;
          selectedIndex = null;
          isCorrect = false;
          isWrong = false;
          loadQuestion();
        });
      } else {
        final coin =
            await resultService(widget.code, correctCount - inCorrectCount);
        resultDialog(
          Get.context!,
          correctCount - inCorrectCount,
          defineController.quiz.length,
          coin,
        );
      }
    } else {
      effect.wrongSound();
      setState(() {
        isWrong = true;
        isCorrect = false;
        if (!incorrectAnswers.contains(currentQuestionIndex)) {
          inCorrectCount++;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> currentQuestion =
        defineController.quiz[currentQuestionIndex];
    String type = currentQuestion['type'];
    String correctImage = currentQuestion['image'];
    String correctText = currentQuestion['answer'];
    String note = currentQuestion['note'];

    return Scaffold(
      appBar: const CustomAppBar(),
      body: Padding(
        padding:
            EdgeInsets.only(bottom: gapHalf, left: gapMain, right: gapMain),
        child: Column(
          children: [
            // 문제
            Expanded(
              flex: 2,
              child: Center(
                child: Column(
                  children: [
                    Text(
                      '단어의 뜻 찾기',
                      style: TextStyle(
                          color: mFontMain,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      note,
                      style: TextStyle(
                        color: mFontSub,
                        fontSize: 15.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 문제 수
            Expanded(
              flex: 1,
              child: Center(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${currentQuestionIndex + 1}',
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 26.sp,
                            fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: '/${defineController.quiz.length}',
                        style: TextStyle(
                            color: mFontMain,
                            fontSize: 26.sp,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 8,
              child: Center(
                child: (type == "3" || type == "4")
                    ? textBox(correctText)
                    : imageBox(correctImage),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: gapHalf),
                child: Row(
                  children: List.generate(
                    2,
                    (index) {
                      return Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                            checkAnswer(options[index]);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(left: gapQuarter),
                            child: Container(
                              decoration: BoxDecoration(
                                color: mBoxLightBlue,
                                borderRadius: BorderRadius.circular(15.sp),
                              ),
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return Stack(
                                    children: [
                                      Center(
                                        child: Text(
                                          options[index],
                                          style: TextStyle(
                                            color: mFontMain,
                                            fontSize: 50.sp,
                                            fontWeight: FontWeight.bold,
                                            fontFamily:
                                                type == "3" || type == "4"
                                                    ? 'NotoSansKR-SemiBold'
                                                    : 'G-Sans',
                                          ),
                                        ),
                                      ),
                                      if (selectedIndex == index)
                                        isCorrect
                                            ? Center(
                                                child: Icon(
                                                  Icons.circle_outlined,
                                                  size: constraints.maxHeight,
                                                  color: Colors.green,
                                                ),
                                              )
                                            : isWrong
                                                ? Center(
                                                    child: Icon(
                                                      Icons.close,
                                                      size:
                                                          constraints.maxHeight,
                                                      color: Colors.red,
                                                    ),
                                                  )
                                                : SizedBox(),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Container(),
            )
          ],
        ),
      ),
    );
  }

  Widget imageBox(String correctImage) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
            image: NetworkImage(
              correctImage,
            ),
            fit: BoxFit.fill),
      ),
    );
  }

  Widget textBox(String correctText) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
          color: mBoxGray, borderRadius: BorderRadius.circular(20)),
      child: Center(
        child: Text(
          correctText,
          style: TextStyle(
              color: mFontMain, fontSize: 75.sp, fontWeight: FontWeight.w900,fontFamily: 'G-sans'),
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
