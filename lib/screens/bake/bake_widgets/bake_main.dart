import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/constants.dart';
import 'package:hoho_hanja/data/models/bake_data.dart';
import 'package:hoho_hanja/main.dart';
import 'package:hoho_hanja/utils/design_scale.dart';
import 'package:hoho_hanja/utils/result_service.dart';
import 'package:hoho_hanja/widgets/dialog/result_dialog.dart';

// 판 위의 빵 한 줄 (문제 하나의 보기 3개, 복습 줄이면 이미 맞힌 문제)
class _BreadRow {
  final int question;
  final List<String> options;
  final List<AssetImage> images;

  _BreadRow(this.question, this.options, this.images);
}

/// 빵 판 (줄이 아래부터 쌓이고, 맨 윗줄이 지금 문제)
class BakeMain extends StatefulWidget {
  final String code;
  final BakeDataController bakeData;
  final DesignScale scale;
  final double kx; // 배경을 화면 폭에 맞춰 가로로 늘린 배율 (칸 x·폭에 곱함)
  final ValueChanged<int> onQuestionChanged;
  final ValueChanged<bool> onWeepBear;
  final ValueChanged<int> onSolvedChanged; // 맞힌 문제 수가 바뀔 때 (화면 표시)

  const BakeMain({
    super.key,
    required this.code,
    required this.bakeData,
    required this.scale,
    required this.kx,
    required this.onQuestionChanged,
    required this.onWeepBear,
    required this.onSolvedChanged,
  });

  @override
  State<BakeMain> createState() => _BakeMainState();
}

class _BakeMainState extends State<BakeMain> with WidgetsBindingObserver {
  // 배경 그림 속 판의 칸 (시안 좌표, bake_bg.png 1080 x 2166 = 시안 360 x 722를 3배)
  static const List<double> colX = [27.0, 129.0, 233.0];
  static const List<double> rowY = [204.67, 289.67, 374.67, 459.33, 544.33];
  static const double cellW = 95.67;
  static const double cellH = 79;
  static const int maxRows = 5;
  static const Duration addInterval = Duration(seconds: 10);

  final random = Random();
  final List<_BreadRow> _rows = [];
  Timer? _timer;
  int _next = 0; // 다음에 꺼낼 새 문제 번호
  final Set<int> _solved = {}; // 한 번이라도 맞힌 문제 (점수 = 개수)
  int get correctCount => _solved.length;
  bool _finished = false; // 게임 끝 (결과는 한 번만 저장)

  int get _total => widget.bakeData.bakeDataList.length;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _addRow();
    _startTimer();
  }

  // 앱이 백그라운드에 있는 동안은 줄이 쌓이지 않게 멈춤
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_finished) return;
    if (state == AppLifecycleState.resumed) {
      _startTimer();
    } else {
      _timer?.cancel();
    }
  }

  // 다음 문제 줄을 맨 아래에 추가
  // 새 문제가 다 떨어지면 이미 맞힌 문제를 복습 줄로 올려서, 끝까지 줄이 쌓이고 게임오버도 될 수 있게
  void _addRow() {
    int question;
    if (_next < _total) {
      question = _next++;
    } else {
      final onBoard = _rows.map((r) => r.question).toSet();
      var candidates = _solved.where((q) => !onBoard.contains(q)).toList();
      if (candidates.isEmpty) candidates = List.generate(_total, (i) => i).where((q) => !onBoard.contains(q)).toList();
      if (candidates.isEmpty) candidates = List.generate(_total, (i) => i);
      question = candidates[random.nextInt(candidates.length)];
    }

    final picks = <int>{};
    while (picks.length < 3) {
      picks.add(random.nextInt(bakeIcons.length));
    }
    _rows.add(_BreadRow(question, widget.bakeData.optionsOf(question), picks.map((i) => bakeIcons[i]).toList()));
  }

  // 줄이 바뀐 뒤 말풍선 문제·곰 표정 맞춤
  void _onRowsChanged() {
    widget.onWeepBear(_rows.length >= 4);
    if (_rows.isNotEmpty) widget.onQuestionChanged(_rows.first.question);
  }

  // 일정 시간마다 줄 추가, 판이 꽉 찬 상태면 게임 끝
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(addInterval, (_) {
      if (_finished) return;
      if (_rows.length >= maxRows) {
        _gameOver();
        return;
      }
      setState(_addRow);
      _onRowsChanged();
    });
  }

  void _onTap(int rowIndex, int optionIndex) {
    if (_finished || rowIndex >= _rows.length) return;
    final row = _rows[rowIndex];
    // 정답은 맨 윗줄(지금 문제)에서만
    final correct =
        rowIndex == 0 && row.options[optionIndex] == widget.bakeData.bakeDataList[row.question].answer;

    if (correct) {
      effect.correctSound();
      if (_solved.add(row.question)) widget.onSolvedChanged(_solved.length);
      // 모든 문제를 한 번씩 맞히면 끝 (판에 복습 줄이 남아 있어도)
      if (_solved.length >= _total) {
        _gameOver();
        return;
      }
      setState(() {
        _rows.removeAt(0);
        if (_rows.isEmpty) _addRow();
      });
    } else {
      effect.wrongSound();
      if (_rows.length >= maxRows) {
        _gameOver();
        return;
      }
      setState(_addRow);
    }
    _onRowsChanged();
    _startTimer();
  }

  Future<void> _gameOver() async {
    if (_finished) return;
    _finished = true;
    _timer?.cancel();

    String coin = await resultService(widget.code, correctCount);
    if (!mounted) return;
    resultDialog(context, correctCount, _total, coin, onRetry: () => resultService(widget.code, correctCount));
  }

  @override
  Widget build(BuildContext context) {
    final sc = widget.scale;
    final firstCell = maxRows - _rows.length; // 줄은 판 아래부터 채움

    return Stack(
      children: [
        for (int r = 0; r < _rows.length; r++)
          for (int c = 0; c < 3; c++)
            // 칸 x·폭만 배경과 같이 가로로 늘리고, 빵 그림은 원래 비율로 칸 안에
            sc.box(
              colX[c] * widget.kx,
              rowY[firstCell + r],
              cellW * widget.kx,
              cellH,
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _onTap(r, c),
                child: Padding(
                  padding: EdgeInsets.all(sc.d(6)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image(image: _rows[r].images[c], fit: BoxFit.contain),
                      Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _rows[r].options[c],
                            style: TextStyle(
                              color: mFontBrown,
                              fontSize: sc.d(24),
                              fontWeight: FontWeight.bold,
                              fontFamily: 'G-Sans',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      ],
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }
}
