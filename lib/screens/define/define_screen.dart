import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/data/models/define_data.dart';
import 'package:hoho_hanja/main.dart';
import 'package:hoho_hanja/utils/design_scale.dart';
import 'package:hoho_hanja/utils/result_service.dart';
import 'package:hoho_hanja/widgets/appbar/design_app_bar.dart';
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
  final Set<int> wrongQuestions = {}; // 한 번이라도 틀린 문제 (문제당 한 번만 감점)
  List<String> options = [];

  bool isCorrect = false;
  bool isWrong = false;
  int? selectedIndex;
  bool _isLocked = false; // 정답 후 다음 문제로 넘어가는 동안 입력 잠금
  bool _finished = false; // 게임 끝 (결과는 한 번만 저장)

  // 점수: 처음에 맞힌 문제 수 (0 미만으로 내려가지 않음)
  int get score => max(0, correctCount - wrongQuestions.length);

  @override
  void initState() {
    super.initState();
    music.playBackgroundMusic('quiz');
    loadQuestion();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 첫 문제와 다음 문제 그림을 미리 받아둠
    _precacheImage(currentQuestionIndex);
    _precacheImage(currentQuestionIndex + 1);
  }

  void loadQuestion() {
    options = List<String>.from(defineController.quiz[currentQuestionIndex]['options']);
    options.shuffle(Random());
  }

  // 그림 문제면 그림을 미리 받아서, 넘어갈 때 로딩 표시 없이 바로 보이게 (실패해도 무시 — 화면에서 다시 시도)
  void _precacheImage(int index) {
    if (index >= defineController.quiz.length) return;
    final question = defineController.quiz[index];
    final String url = question['image'];
    if (question['type'] == "3" || question['type'] == "4" || url.isEmpty) return;
    precacheImage(NetworkImage(url), context, onError: (_, __) {});
  }

  void onSelect(int index) {
    if (_isLocked || _finished) return;
    setState(() {
      selectedIndex = index;
    });
    checkAnswer(options[index]);
  }

  void checkAnswer(String selectedAnswer) async {
    String correctAnswer = defineController.quiz[currentQuestionIndex]['options'][0];

    if (selectedAnswer == correctAnswer) {
      _isLocked = true;
      effect.correctSound();
      correctCount++;
      setState(() {
        isCorrect = true;
        isWrong = false;
      });

      await Future.delayed(const Duration(milliseconds: 1000));
      // 기다리는 동안 화면을 나갔으면 중단
      if (!mounted) return;

      if (currentQuestionIndex < defineController.quiz.length - 1) {
        setState(() {
          currentQuestionIndex++;
          selectedIndex = null;
          isCorrect = false;
          isWrong = false;
          loadQuestion();
        });
        _precacheImage(currentQuestionIndex + 1);
        _isLocked = false;
      } else {
        _finished = true;
        final coin = await resultService(widget.code, score);
        if (!mounted) return;
        resultDialog(
          context,
          score,
          defineController.quiz.length,
          coin,
          onRetry: () => resultService(widget.code, score),
        );
      }
    } else {
      effect.wrongSound();
      setState(() {
        isWrong = true;
        isCorrect = false;
        wrongQuestions.add(currentQuestionIndex);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> currentQuestion = defineController.quiz[currentQuestionIndex];
    String type = currentQuestion['type'];
    String correctImage = currentQuestion['image'];
    String correctText = currentQuestion['answer'];
    String note = currentQuestion['note'];

    final mq = MediaQuery.of(context);

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final sc = DesignScale.of(constraints.biggest, mq.padding);

            return Stack(
              children: [
                // 앱바 (다른 게임 화면과 같은 시안 좌표·크기)
                Positioned(
                  left: 0,
                  top: 0,
                  right: 0,
                  child: DesignAppBar(scale: sc, inset: (sc.dw - sc.maxContentWidth) / 3),
                ),
                Positioned(
                  left: 0,
                  top: sc.y(DesignAppBar.height),
                  right: 0,
                  bottom: mq.padding.bottom,
                  child: _quizBody(sc, type, correctImage, correctText, note),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // 본문 (시안 360 x 698 기준, 앱바 아래): 폭 296 칸에 위에서부터
  // 제목 74 · 문제 수 37 · 문제(그림/글자) 296 · 보기 버튼 148(위아래 여백 16) · 아래 여백
  // 모두 배율 하나로만 키우거나 줄여서, 휴대폰·태블릿 어디서나 같은 비율로 보이게 한다.
  static const double _contentWidth = 296;

  Widget _quizBody(DesignScale sc, String type, String correctImage, String correctText, String note) {
    double d(num v) => sc.d(v);

    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: d(_contentWidth),
        child: Column(
          children: [
            // 문제
            SizedBox(
              height: d(74),
              // 안내 문구가 길어도 칸 밖으로 넘치지 않게 줄여서 표시
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  children: [
                    Text(
                      '단어의 뜻 찾기',
                      style: TextStyle(color: mFontMain, fontSize: d(24), fontWeight: FontWeight.bold),
                    ),
                    Text(
                      note,
                      style: TextStyle(color: mFontSub, fontSize: d(15)),
                    ),
                  ],
                ),
              ),
            ),
            // 문제 수
            SizedBox(
              height: d(37),
              child: Center(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${currentQuestionIndex + 1}',
                        style: TextStyle(color: Colors.green, fontSize: d(26), fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: '/${defineController.quiz.length}',
                        style: TextStyle(color: mFontMain, fontSize: d(26), fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
            ),
            // 문제 (그림 또는 글자)
            SizedBox(
              height: d(296),
              child: (type == "3" || type == "4") ? textBox(sc, correctText) : imageBox(sc, correctImage),
            ),
            // 보기 버튼 2개
            Padding(
              padding: EdgeInsets.symmetric(vertical: d(16)),
              child: SizedBox(
                height: d(116),
                child: Row(
                  children: List.generate(
                    2,
                    (index) => Expanded(
                      child: Padding(
                        // 버튼 사이 간격을 반씩 나눠서, 두 버튼 폭이 같고 위 문제 칸과 양끝이 맞게
                        padding: index == 0 ? EdgeInsets.only(right: d(4)) : EdgeInsets.only(left: d(4)),
                        child: _optionButton(sc, index),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionButton(DesignScale sc, int index) {
    return GestureDetector(
      onTap: () => onSelect(index),
      child: Container(
        decoration: BoxDecoration(
          color: mBoxLightBlue,
          borderRadius: BorderRadius.circular(sc.d(15)),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 두 보기 중 긴 글자가 버튼 폭에 맞는 크기로 둘 다 같은 크기 (최대 시안 50)
            final baseFontSize = sc.d(50);
            final availableWidth = constraints.maxWidth - sc.d(8);
            double maxTextWidth = 0;

            for (var o in options) {
              final tp = TextPainter(
                text: TextSpan(
                  text: o,
                  style: TextStyle(
                    fontSize: baseFontSize,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'NotoSansKR-SemiBold',
                  ),
                ),
                textDirection: TextDirection.ltr,
              )..layout();
              maxTextWidth = max(maxTextWidth, tp.width);
              tp.dispose();
            }

            final fittedFontSize = maxTextWidth > 0 ? baseFontSize * availableWidth / maxTextWidth : baseFontSize;

            return Stack(
              children: [
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(sc.d(4)),
                    child: FittedBox(
                      child: Text(
                        options[index],
                        softWrap: true,
                        style: TextStyle(
                          color: mFontMain,
                          fontSize: min(fittedFontSize, baseFontSize),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'NotoSansKR-SemiBold',
                        ),
                      ),
                    ),
                  ),
                ),
                if (selectedIndex == index && (isCorrect || isWrong))
                  Center(
                    child: Icon(
                      isCorrect ? Icons.circle_outlined : Icons.close,
                      size: constraints.maxHeight,
                      color: isCorrect ? Colors.green : Colors.red,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget imageBox(DesignScale sc, String correctImage) {
    // 비율을 유지하고, 불러오는 중·실패 시에도 빈 화면이나 오류가 나지 않게
    return ClipRRect(
      borderRadius: BorderRadius.circular(sc.d(20)),
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: correctImage.isEmpty
            ? _imageError(sc)
            : Image.network(
                correctImage,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) =>
                    progress == null ? child : const Center(child: CircularProgressIndicator()),
                errorBuilder: (context, error, stackTrace) => _imageError(sc),
              ),
      ),
    );
  }

  Widget _imageError(DesignScale sc) {
    return Container(
      color: mBoxGray,
      alignment: Alignment.center,
      child: Icon(Icons.image_not_supported_outlined, size: sc.d(60), color: mFontSub),
    );
  }

  Widget textBox(DesignScale sc, String correctText) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(sc.d(16)),
      decoration: BoxDecoration(color: mBoxGray, borderRadius: BorderRadius.circular(sc.d(20))),
      child: Center(
        // 글자가 길어도 상자 밖으로 넘치지 않게
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            correctText,
            style: TextStyle(color: mFontMain, fontSize: sc.d(75), fontWeight: FontWeight.w900, fontFamily: 'G-Sans'),
          ),
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
