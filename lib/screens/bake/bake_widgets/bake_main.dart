import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/constants.dart';
import 'package:hoho_hanja/data/models/bake_data.dart';
import 'package:hoho_hanja/main.dart';
import 'package:hoho_hanja/utils/result_service.dart';
import 'package:hoho_hanja/widgets/dialog/result_dialog.dart';

class BakeMain extends StatefulWidget {
  final String code;
  final BakeDataController bakeData;
  final int index;
  final ValueChanged<int> updateIndex;
  final ValueChanged<bool> onWeepBear;

  const BakeMain({
    super.key,
    required this.code,
    required this.bakeData,
    required this.index,
    required this.updateIndex,
    required this.onWeepBear,
  });

  // 정답을 맞췄을 경우 인덱스가 1 올라감
  void nextQuestion() {
    final currentIndex = index + 1;
    updateIndex(currentIndex);
  }

  @override
  State<BakeMain> createState() => _BakeMainState();
}

class _BakeMainState extends State<BakeMain> {
  final random = Random();
  Timer? _timer;
  int questionIndex = 0;
  int lineIndex = 1;
  int correctCount = 0;
  List<AssetImage> selectedImage = [];
  List<List<String>> answers = [];
  bool isTouchable = true;

  @override
  void initState() {
    super.initState();
    initQuestion();
    startImageTimer();
  }

  // 화면이 처음 빌드될 때 빵3개랑 문제 생성
  void initQuestion() {
    final Set<int> selectedIndices = {};

    List<String> options = List<String>.from(
        widget.bakeData.bakeQuetsion[questionIndex]['options']);

    while (selectedIndices.length < 3) {
      selectedIndices.add(random.nextInt(bakeIcons.length));
    }

    setState(() {
      selectedImage = selectedIndices.map((index) => bakeIcons[index]).toList();
      answers.add(options);
    });
  }

  // 일정 시간이 지나면 라인 추가
  void startImageTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (questionIndex < widget.bakeData.bakeDataList.length - 1) {
        if (lineIndex < 5) {
          setState(() {
            isTouchable = false;
            lineIndex++;
            questionIndex++;
            addQuestions();

            if (lineIndex == 4) {
              widget.onWeepBear(true);
            }

            isTouchable = true;
          });
        } else {
          gameOver();
        }
      } else {
        _timer?.cancel();
      }
    });
  }

  void addQuestions() {
    final Set<int> selectedIndices = {};

    List<String> options = List<String>.from(
        widget.bakeData.bakeQuetsion[questionIndex]['options']);

    while (selectedIndices.length < 3) {
      selectedIndices.add(random.nextInt(bakeIcons.length));
    }

    setState(() {
      selectedImage
          .addAll(selectedIndices.map((index) => bakeIcons[index]).toList());
      answers.add(options);
    });
  }

  void checkAnswer(String selectedAnswer) {
    if (!isTouchable) return;
    if (selectedAnswer ==
        widget.bakeData.bakeQuetsion[widget.index]['correct']) {
      effect.correctSound();
      correctCount++;
      if (widget.index == widget.bakeData.bakeDataList.length - 1) {
        gameOver();
      } else {
        setState(() {
          selectedImage.removeRange(0, 3);
          answers.removeAt(0);
          if (lineIndex > 1) {
            lineIndex--;
            if (lineIndex < 4) {
              widget.onWeepBear(false);
            }
          }
          widget.nextQuestion();
          if (selectedImage.isEmpty) {
            questionIndex++;
            addQuestions();
          }
        });
        startImageTimer();
      }
    } else {
      effect.wrongSound();
      if (lineIndex < 5) {
        setState(() {
          lineIndex++;
          questionIndex++;
          addQuestions();

          if (lineIndex == 4) {
            widget.onWeepBear(true);
          }
        });
        startImageTimer();
      } else {
        gameOver();
      }
    }
  }

  void gameOver() async {
    _timer?.cancel();
    String coin = await resultService(widget.code, correctCount);
    resultDialog(
      Get.context!,
      correctCount,
      widget.bakeData.bakeDataList.length,
      coin, //코인
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        for (int i = 0; i < selectedImage.length; i += 3)
          Positioned(
            bottom: 65.h + ((selectedImage.length ~/ 3 - 1 - i ~/ 3) * 85.h),
            left: 20.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: selectedImage
                  .sublist(
                      i,
                      (i + 3 > selectedImage.length)
                          ? selectedImage.length
                          : i + 3)
                  .asMap()
                  .entries
                  .map(
                (entry) {
                  int idx = entry.key;
                  int lineIndex = i ~/ 3;
                  var image = entry.value;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      checkAnswer(answers[lineIndex][idx]);
                    },
                    child: Padding(
                      padding: EdgeInsets.all(12.sp),
                      child: Container(
                        height: 75.h,
                        width: 80.w,
                        decoration: BoxDecoration(
                          image:
                              DecorationImage(image: image, fit: BoxFit.fill),
                        ),
                        child: Center(
                          child: Text(
                            answers[lineIndex].isNotEmpty
                                ? answers[lineIndex][idx]
                                : "",
                            style: TextStyle(
                                color: mFontBrown,
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'G-Sans'),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ).toList(),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
