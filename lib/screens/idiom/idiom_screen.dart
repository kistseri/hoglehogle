import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/size.dart';
import 'package:hoho_hanja/data/models/idiom_data.dart';
import 'package:hoho_hanja/main.dart';
import 'package:hoho_hanja/utils/result_service.dart';
import 'package:hoho_hanja/widgets/custom_appbar.dart';
import 'package:hoho_hanja/widgets/dialog/result_dialog.dart';

class IdiomScreen extends StatefulWidget {
  final String code;

  const IdiomScreen(this.code, {super.key});

  @override
  State<IdiomScreen> createState() => _IdiomScreenState();
}

class _IdiomScreenState extends State<IdiomScreen> {
  final idiomController = Get.put(IdiomDataController());
  List<String> options = [];
  int correctCount = 0;
  int index = 0;

  @override
  void initState() {
    music.playBackgroundMusic('idiom');
    super.initState();
  }

  void checkAnswer(String selectedAnswer) async {
    String correctAnswer = idiomController.idiom[index]['options'][0];
    setState(() {
      if (correctAnswer == selectedAnswer) {
        effect.correctSound();
        correctCount++;
      } else {
        effect.wrongSound();
      }
    });
    if (index < idiomController.idiom.length - 1) {
      setState(() {
        index++;
      });
    } else {
      final coin = await resultService(widget.code, correctCount);
      resultDialog(
          Get.context!, correctCount, idiomController.idiom.length, coin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    List<String> options =
        List<String>.from(idiomController.idiom[index]['options']);
    options.shuffle(Random());

    return Scaffold(
      backgroundColor: mBoxLilac,
      appBar: const CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              '한자성어 문제',
              style: TextStyle(
                color: mFontMain,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '빈 칸에 알맞은 한자를 찾아보세요.',
              style: TextStyle(
                color: mFontMain,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: gapHalf),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: mBackWhite,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      RichText(
                        text: TextSpan(children: [
                          TextSpan(
                            text: '${index + 1}',
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: "/${idiomController.idiomDataList.length}",
                            style: TextStyle(
                              color: mFontMain,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ]),
                      ),
                    ],
                  ),
                  Text(
                    idiomController.idiomDataList[index].quize1,
                    style: TextStyle(
                        color: const Color(0xFF391E65),
                        fontSize: 40.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 5),
                  ),
                  SizedBox(height: gapHalf),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildHanjaButton(
                          idiomController.idiomDataList[index].hanja1,
                          idiomController.idiomDataList[index].randomNum == 1),
                      _buildHanjaButton(
                          idiomController.idiomDataList[index].hanja2,
                          idiomController.idiomDataList[index].randomNum == 2),
                      _buildHanjaButton(
                          idiomController.idiomDataList[index].hanja3,
                          idiomController.idiomDataList[index].randomNum == 3),
                      _buildHanjaButton(
                          idiomController.idiomDataList[index].hanja4,
                          idiomController.idiomDataList[index].randomNum == 4),
                    ],
                  ),
                  SizedBox(height: gapHalf),
                  Divider(),
                  Padding(
                    padding: EdgeInsets.all(gapHalf),
                    child: Text(
                      quizWrap(idiomController.idiomDataList[index].quize2),
                      style: TextStyle(fontSize: 20.sp),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: gapMain),
          ],
        ),
      ),
      bottomSheet: Container(
        height: size.height * 0.35,
        width: size.width,
        decoration: const BoxDecoration(
          color: mBackWhite,
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(30),
            topLeft: Radius.circular(30),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildAnswerButton(options[0]),
            _buildAnswerButton(options[1]),
          ],
        ),
      ),
    );
  }

  Widget _buildHanjaButton(String hanja, [bool isPlaceholder = false]) {
    return Container(
      width: 60.w,
      height: 60.h,
      decoration: BoxDecoration(
        color: isPlaceholder ? mBoxYellow : mBoxLilac,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: mBoxLavender, width: 2.w),
      ),
      child: Center(
        child: Text(
          isPlaceholder ? "?" : hanja,
          style: TextStyle(
              color: isPlaceholder ? mFontMain : mFontWhite,
              fontSize: 30.sp,
              fontWeight: FontWeight.bold,
              fontFamily: 'G-Sans'),
        ),
      ),
    );
  }

  Widget _buildAnswerButton(String hanja) {
    return GestureDetector(
      onTap: () {
        checkAnswer(hanja);
      },
      child: Container(
        width: 100.w,
        height: 100.h,
        decoration: BoxDecoration(
          color: mBoxYellow,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            hanja,
            style: TextStyle(
                color: mFontMain,
                fontSize: 50.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'G-Sans'),
          ),
        ),
      ),
    );
  }

  String quizWrap(String quiz2) {
    int count = quiz2.replaceAll(' ', '').length;

    if (count >= 12) {
      int dotIndex = quiz2.lastIndexOf('.');

      if (dotIndex != -1) {
        for (int i = dotIndex + 1; i < quiz2.length; i++) {
          if (quiz2[i] == ' ') {
            quiz2 = quiz2.substring(0, i) + '\n' + quiz2.substring(i + 1);
            return quiz2;
          }
        }
      } else {
        int charCount = 0;

        for (int i = 0; i < quiz2.length; i++) {
          if (quiz2[i] != ' ') {
            charCount++;
          }
          if (charCount == 12) {
            for (int j = i + 1; j < quiz2.length; j++) {
              if (quiz2[j] == ' ') {
                quiz2 = quiz2.substring(0, j) + '\n' + quiz2.substring(j + 1);
                return quiz2;
              }
            }
          }
        }
      }
    }
    return quiz2;
  }

  @override
  void dispose() {
    music.stopBackgroundMusic();
    super.dispose();
  }
}
