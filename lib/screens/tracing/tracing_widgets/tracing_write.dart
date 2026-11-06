import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/data/models/tracing_data.dart';
import 'package:hoho_hanja/main.dart';
import 'package:hoho_hanja/screens/tracing/tracing_widgets/tracing_word.dart';
import 'package:hoho_hanja/utils/design_scale.dart';
import 'package:hoho_hanja/utils/result_service.dart';
import 'package:hoho_hanja/widgets/appbar/design_app_bar.dart';
import 'package:hoho_hanja/widgets/dialog/result_dialog.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';

class TracingWrite extends StatefulWidget {
  final String code;
  final int openPage;

  const TracingWrite({
    super.key,
    required this.code,
    required this.openPage,
  });

  @override
  State<TracingWrite> createState() => _TracingWriteState();
}

class _TracingWriteState extends State<TracingWrite> {
  final tracingController = Get.put(TracingDataController());
  final ValueNotifier<bool> resetNotifier = ValueNotifier(false);

  int currentIndex = 0;
  late final int totalIndex;
  late AudioPlayer _audioPlayer;
  // 끝까지 쓴 글자 번호 (이전·다음으로 옮겨도 점수가 맞도록)
  final Set<int> _completedWords = {};
  // 결과 저장은 한 번만
  bool _resultSent = false;

  String meaning = '';
  String phonetic = '';

  @override
  void initState() {
    super.initState();
    // 열린 글자 수가 실제 글자 수보다 많지 않게
    final count = tracingController.tracingDataList?.length ?? 0;
    totalIndex = math.max(1, math.min(widget.openPage, count));
    music.playBackgroundMusic('tracing');
    _audioPlayer = AudioPlayer();
    _updateNote();
  }

  void _updateNote() {
    final list = tracingController.tracingDataList;
    if (list == null || currentIndex >= list.length) return;

    final note = list[currentIndex].note.trim();
    if (note.length > 1) {
      meaning = note.substring(0, note.length - 1); // 첫 번째 부분 (독)
      phonetic = note.substring(note.length - 1); // 마지막 글자 (음)
    } else {
      meaning = note;
      phonetic = '';
    }
  }

  void _onNextWord() {
    if (currentIndex < totalIndex - 1) {
      setState(() {
        _onResetTracing();
        currentIndex++;
        _updateNote();
      });
    }
  }

  void _onPrevWord() {
    if (currentIndex > 0) {
      setState(() {
        _onResetTracing();
        currentIndex--;
        _updateNote();
      });
    }
  }

  Future<void> _playSound(String url) async {
    try {
      await _audioPlayer.setUrl(url);
      _audioPlayer.play();
    } catch (e) {
      Logger().e("Error playing sound: $e");
    }
  }

  Future<void> _completeWord() async {
    final index = currentIndex;
    _completedWords.add(index);
    await _playSound(tracingController.tracingDataList![index].voice);

    // 음성을 불러오는 사이 화면을 나갔거나 다른 글자로 옮겼으면 그대로 둠
    if (!mounted || index != currentIndex) return;

    if (currentIndex < totalIndex - 1) {
      // music.completeWordMusic('https://hohoeduimg.speedgabia.com/write/voice/s01/word1.mp3');
      setState(() {
        // effect.correctSound();

        _onResetTracing();
        currentIndex++;
        _updateNote();
      });
    } else {
      await _sendResult();
    }
  }

  // 결과 저장 후 결과창 (결과창을 닫고 다시 써도 한 번만 저장)
  Future<void> _sendResult() async {
    if (_resultSent) return;
    _resultSent = true;

    final count = _completedWords.length;
    String result = await resultService(widget.code, count);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    resultDialog(context, count, totalIndex, result, onRetry: () => resultService(widget.code, count));
  }

  void _onResetTracing() {
    resetNotifier.value = !resetNotifier.value;
  }

  // 시안 좌표 (홈과 같은 360 x 698, 상태바 제외)
  static const double areaW = 296.5; // 따라쓰기 영역 (화면 가운데)
  static const double areaTop = 82.3;
  static const double areaH = 438;
  static const double noteY = 565.5; // 뜻·음 세로 가운데
  static const double noteSize = 30;
  static const double buttonY = 653.5; // 이전·다시·다음 버튼 세로 가운데
  static const double buttonSize = 50;

  // 버튼 (x: 왼쪽, 시안 단위)
  Widget _button(DesignScale sc, double x, IconData icon, bool enabled, VoidCallback onTap) {
    return sc.box(
      x,
      buttonY - buttonSize / 2,
      buttonSize,
      buttonSize,
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Icon(icon, size: sc.d(buttonSize), color: enabled ? mFontWhite : mFontSub),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    // 앱바까지 시안 비율대로 직접 그림 (홈·단원 선택 화면과 같은 방식)
    return Scaffold(
      backgroundColor: const Color(0xFFFFD254),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final sc = DesignScale.of(constraints.biggest, mq.padding);
            final areaX = (sc.dw - areaW) / 2;

            return Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  right: 0,
                  // 단원 선택 화면과 같은 위치
                  child: DesignAppBar(scale: sc, inset: (sc.dw - sc.maxContentWidth) / 3),
                ),
                sc.box(
                  areaX,
                  areaTop,
                  areaW,
                  areaH,
                  ClipRect(
                    child: TracingWord(
                      tracingController: tracingController,
                      currentIndex: currentIndex,
                      resetNotifier: resetNotifier,
                      onComplete: _completeWord,
                    ),
                  ),
                ),
                // 뜻 + 음 (길면 줄여서 맞춤)
                sc.box(
                  areaX,
                  noteY - noteSize,
                  areaW,
                  noteSize * 2,
                  IgnorePointer(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            meaning, // 독 (의미) 표시
                            style: TextStyle(
                              color: mFontMain,
                              fontSize: sc.d(noteSize),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: sc.d(8)),
                            child: Container(
                              padding: EdgeInsets.all(sc.d(2)),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE7610B),
                                borderRadius: BorderRadius.circular(sc.d(10)),
                              ),
                              child: Text(
                                phonetic, // 음 (발음) 표시
                                style: TextStyle(
                                  color: mFontWhite,
                                  fontSize: sc.d(noteSize),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _button(sc, areaX, Icons.skip_previous, currentIndex > 0, _onPrevWord),
                _button(sc, (sc.dw - buttonSize) / 2, Icons.refresh, true, _onResetTracing),
                _button(sc, areaX + areaW - buttonSize, Icons.skip_next, totalIndex - 1 > currentIndex, () {
                  _onNextWord();
                  Logger().d('total = ${totalIndex - 1} current = $currentIndex');
                }),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    resetNotifier.dispose();
    music.stopBackgroundMusic();
    super.dispose();
  }
}
