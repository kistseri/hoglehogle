import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/data/models/idiom_data.dart';
import 'package:hoho_hanja/main.dart';
import 'package:hoho_hanja/screens/idiom/idiom_widgets/top_arc_clipper.dart';
import 'package:hoho_hanja/utils/design_scale.dart';
import 'package:hoho_hanja/utils/result_service.dart';
import 'package:hoho_hanja/widgets/appbar/design_app_bar.dart';
import 'package:hoho_hanja/widgets/dialog/result_dialog.dart';

// 한자 성어
class IdiomScreen extends StatefulWidget {
  final String code;

  const IdiomScreen(this.code, {super.key});

  @override
  State<IdiomScreen> createState() => _IdiomScreenState();
}

class _IdiomScreenState extends State<IdiomScreen> {
  final idiomController = Get.put(IdiomDataController());
  int currentQuestionIndex = 0;
  int correctCount = 0;
  final Set<int> wrongQuestions = {}; // 한 번이라도 틀린 문제 (같은 문제를 여러 번 틀려도 한 번만 감점)
  List<String> options = [];

  bool isCorrect = false;
  bool isWrong = false;
  int? selectedIndex;
  bool isAnswered = false;

  @override
  void initState() {
    super.initState();
    music.playBackgroundMusic('idiom');
    loadQuestion();
  }

  void loadQuestion() {
    options = List<String>.from(idiomController.idiom[currentQuestionIndex]['options']);
    options.shuffle(Random());
  }

  void checkAnswer(String selectedAnswer) async {
    if (isAnswered) return;
    setState(() => isAnswered = true);

    String correctAnswer = idiomController.idiom[currentQuestionIndex]['options'][0];

    if (selectedAnswer == correctAnswer) {
      effect.correctSound();
      correctCount++;
      setState(() {
        isCorrect = true;
        isWrong = false;
      });
      await Future.delayed(const Duration(milliseconds: 500));
      // 기다리는 동안 화면을 나갔으면 중단
      if (!mounted) return;

      if (currentQuestionIndex < idiomController.idiom.length - 1) {
        setState(() {
          currentQuestionIndex++;
          isCorrect = false;
          isWrong = false;
          isAnswered = false;
          loadQuestion();
        });
      } else {
        final score = (correctCount - wrongQuestions.length).clamp(0, idiomController.idiom.length);
        final coin = await resultService(widget.code, score);
        if (!mounted) return;
        resultDialog(context, score, idiomController.idiom.length, coin,
            onRetry: () => resultService(widget.code, score));
      }
    } else {
      effect.wrongSound();
      setState(() {
        isWrong = true;
        isCorrect = false;
        wrongQuestions.add(currentQuestionIndex);
        isAnswered = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final size = mq.size;
    final sc = DesignScale.of(size, mq.padding);
    // ScreenUtil(.sp/.r) 대신 다른 화면과 같은 배율 하나로 (C-34)
    double d(num v) => sc.d(v);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: mBoxLilac,
        // 앱바 (다른 게임 화면과 같은 시안 좌표·크기). 앱바 칸 높이 = 상태바 + 시안 높이
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(sc.d(DesignAppBar.height)),
          child: DesignAppBar(scale: sc, inset: (sc.dw - sc.maxContentWidth) / 3),
        ),
        body:
            // 본문이 아래 답안 시트에 가려지지 않게: 시트 높이만큼 아래 여백을 두고 스크롤
            // body: SingleChildScrollView(
            //   padding: EdgeInsets.fromLTRB(16, 16, 16, size.height * 0.35 + 16),
            Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: d(16.0)),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                        text: '한자성어 문제',
                        style: TextStyle(
                          color: mFontMain,
                          fontSize: d(24),
                          fontWeight: FontWeight.bold,
                        )),
                    TextSpan(
                      text: '\n빈 칸에 알맞은 한자를 찾아보세요.',
                      style: TextStyle(
                        color: mFontMain,
                        fontSize: d(16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(d(16.0)),
              child: Container(
                padding: EdgeInsets.all(d(16)),
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
                              text: '${currentQuestionIndex + 1}',
                              style: TextStyle(
                                color: primaryColor,
                                fontSize: d(20),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: "/${idiomController.idiomDataList.length}",
                              style: TextStyle(
                                color: mFontMain,
                                fontSize: d(20),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ]),
                        ),
                      ],
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        idiomController.idiomDataList[currentQuestionIndex].quize1,
                        style: TextStyle(
                            color: const Color(0xFF391E65),
                            fontSize: d(40),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 5),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: d(16), bottom: d(16)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildHanjaButton(sc, idiomController.idiomDataList[currentQuestionIndex].hanja1,
                              idiomController.idiomDataList[currentQuestionIndex].randomNum == 1),
                          _buildHanjaButton(sc, idiomController.idiomDataList[currentQuestionIndex].hanja2,
                              idiomController.idiomDataList[currentQuestionIndex].randomNum == 2),
                          _buildHanjaButton(sc, idiomController.idiomDataList[currentQuestionIndex].hanja3,
                              idiomController.idiomDataList[currentQuestionIndex].randomNum == 3),
                          _buildHanjaButton(sc, idiomController.idiomDataList[currentQuestionIndex].hanja4,
                              idiomController.idiomDataList[currentQuestionIndex].randomNum == 4),
                        ],
                      ),
                    ),
                    const Divider(),
                    Text(
                      quizWrap(idiomController.idiomDataList[currentQuestionIndex].quize2),
                      // '일이삼사오육칠팔구십일이삼사오육칠',
                      style: TextStyle(fontSize: d(20)),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ClipPath(
                clipper: TopArcClipper(arcHeight: 25),
                child: Container(
                  decoration: BoxDecoration(
                    color: mBackWhite,
                  ),
                  // 흰 바탕은 화면 끝까지, 보기 버튼은 안드로이드 내비게이션 바·홈 표시줄 위 영역의 가운데에
                  padding: EdgeInsets.only(bottom: mq.padding.bottom),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      2,
                      (index) {
                        return GestureDetector(
                          onTap: () {
                            // 정답 후 다음 문제로 넘어가는 동안 다른 보기를 누르면 O 표시가 옮겨가지 않게
                            if (isAnswered) return;
                            setState(() {
                              selectedIndex = index;
                            });
                            checkAnswer(options[index]);
                          },
                          child: Container(
                            width: d(100),
                            height: d(100),
                            decoration: BoxDecoration(
                              color: mBoxYellow,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Stack(
                                  children: [
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            options[index],
                                            style: TextStyle(
                                                color: mFontMain,
                                                fontSize: d(50),
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'G-Sans'),
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (selectedIndex == index)
                                      isCorrect
                                          ? Center(
                                              child: Icon(
                                                Icons.circle_outlined,
                                                size: constraints.maxWidth,
                                                color: Colors.green,
                                              ),
                                            )
                                          : isWrong
                                              ? Center(
                                                  child: Icon(
                                                    Icons.close,
                                                    size: constraints.maxWidth,
                                                    color: Colors.red,
                                                  ),
                                                )
                                              : const SizedBox(),
                                  ],
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHanjaButton(DesignScale sc, String hanja, [bool isPlaceholder = false]) {
    double d(num v) => sc.d(v);
    // 정사각형 (기기에 따라 늘어나 보이지 않게)
    return Container(
      width: d(60),
      height: d(60),
      decoration: BoxDecoration(
        color: isPlaceholder ? mBoxYellow : mBoxLilac,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: mBoxLavender, width: d(2)),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            isPlaceholder ? "?" : hanja,
            style: TextStyle(
                color: isPlaceholder ? mFontMain : mFontWhite,
                fontSize: d(30),
                fontWeight: FontWeight.bold,
                fontFamily: 'G-Sans'),
          ),
        ),
      ),
    );
  }

  String quizWrap(String quiz) {
    if (quiz.length <= 16) return quiz;

    List<String> sentences = quiz.split('. ');
    StringBuffer formattedText = StringBuffer();

    for (int i = 0; i < sentences.length; i++) {
      String sentence = sentences[i].trim();
      if (sentence.isEmpty) continue;

      if (sentence.length > 16) {
        sentence = splitLongSentence(sentence);
      }
      formattedText.write(sentence);
      if (i < sentences.length - 1) {
        formattedText.write('\n');
      }
    }
    return formattedText.toString();
  }

  String splitLongSentence(String text) {
    List<String> words = text.split(' ');
    StringBuffer newText = StringBuffer();
    int lineLength = 0;
    for (int i = 0; i < words.length; i++) {
      String word = words[i];
      if (lineLength + word.length > 16) {
        if (newText.isNotEmpty && isPostposition(word)) {
          newText.write(' ');
        } else {
          newText.write('\n');
          lineLength = 0;
        }
      } else if (i != 0) {
        newText.write(' ');
        lineLength++;
      }
      newText.write(word);
      lineLength += word.length;
    }

    return newText.toString();
  }

  bool isPostposition(String word) {
    List<String> postpositions = ['은', '는', '이', '가', '을', '를', '의', '에', '도', '와'];
    return postpositions.contains(word);
  }

  @override
  void dispose() {
    music.stopBackgroundMusic();
    super.dispose();
  }
}
