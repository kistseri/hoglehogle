import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/data/models/tracing_data.dart';
import 'package:hoho_hanja/screens/tracing/tracing_widgets/tracing_painter.dart';
import 'package:hoho_hanja/utils/get_svg_path.dart';
import 'package:logger/logger.dart';

class TracingWord extends StatefulWidget {
  final TracingDataController tracingController;
  final ValueNotifier<bool> resetNotifier;
  final int currentIndex;
  final VoidCallback onComplete;

  const TracingWord({
    super.key,
    required this.tracingController,
    required this.resetNotifier,
    required this.currentIndex,
    required this.onComplete,
  });

  @override
  State<TracingWord> createState() => _TracingWordState();
}

class _TracingWordState extends State<TracingWord> {
  // 펜 두께·포인터 크기 (SVG 좌표, 글자 크기에 비례)
  static const double _penWidth = 40;
  static const double _pointerSize = 34;

  // 획을 이만큼 칠하면 완료
  static const double _completeRatio = 0.8;

  // 채점용 이미지 가로 픽셀 (기기와 관계없이 같은 기준으로 채점)
  static const int _scoreWidth = 256;

  TracingShapes? _shapes;
  bool _failed = false;

  // 선·포인터는 SVG 좌표로 저장
  final List<List<Offset>> _lines = [];
  List<Offset> _currentLine = [];
  Offset? _pointer;
  final Set<int> _completed = {};
  int _strokeIndex = 0;

  // 늦게 도착한 SVG 응답·채점 결과를 버리기 위한 번호
  int _loadToken = 0;
  int _scoreToken = 0;

  // SVG → 화면 변환 (build에서 영역 크기로 계산)
  double _scale = 1;
  Offset _origin = Offset.zero;

  @override
  void initState() {
    super.initState();
    widget.resetNotifier.addListener(_onReset);
    _startLoad();
  }

  @override
  void didUpdateWidget(covariant TracingWord oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.resetNotifier != widget.resetNotifier) {
      oldWidget.resetNotifier.removeListener(_onReset);
      widget.resetNotifier.addListener(_onReset);
    }
    if (oldWidget.currentIndex != widget.currentIndex) {
      _startLoad();
    }
  }

  void _onReset() {
    setState(_clearWord);
  }

  // 글자를 처음 상태로 (선·완료 획을 지우고 첫 획부터)
  void _clearWord() {
    _scoreToken++;
    _lines.clear();
    _currentLine = [];
    _completed.clear();
    _strokeIndex = 0;
    _pointer = _startOf(0);
  }

  Offset? _startOf(int index) {
    final starts = _shapes?.starts ?? const <Offset>[];
    return index < starts.length ? starts[index] : null;
  }

  bool get _isDone =>
      _shapes != null && _completed.length >= _shapes!.strokes.length;

  // 글자가 바뀌거나 다시 시도할 때만 SVG를 불러옴
  void _startLoad() {
    _loadToken++;
    _shapes = null;
    _clearWord();

    final list = widget.tracingController.tracingDataList ?? const [];
    final index = widget.currentIndex;
    _failed = index < 0 || index >= list.length;
    if (!_failed) _loadSvg(_loadToken, list[index].svg);
  }

  Future<void> _loadSvg(int token, String url) async {
    try {
      final response = await dio.get<String>(
        url,
        options: Options(responseType: ResponseType.plain),
      );
      final shapes = SvgPathParser.parseTracing(response.data ?? '');
      if (shapes.strokes.isEmpty) {
        throw const FormatException('획 데이터 없음');
      }

      // 그사이 다른 글자로 넘어갔으면 버림
      if (!mounted || token != _loadToken) return;
      setState(() {
        _shapes = shapes;
        _clearWord();
      });
    } catch (e) {
      Logger().e("SVG load error: $e");
      if (!mounted || token != _loadToken) return;
      setState(() => _failed = true);
    }
  }

  // SVG를 영역 가운데에 원래 비율대로 맞춤
  void _fit(Size size, Rect viewBox) {
    _scale = math.min(
        size.width / viewBox.width, size.height / viewBox.height);
    _origin = Offset(
      (size.width - viewBox.width * _scale) / 2 - viewBox.left * _scale,
      (size.height - viewBox.height * _scale) / 2 - viewBox.top * _scale,
    );
  }

  Offset _toSvg(Offset local) => (local - _origin) / _scale;

  Offset _toScreen(Offset svg) => svg * _scale + _origin;

  void _onPanStart(DragStartDetails details) {
    if (_shapes == null || _isDone) return;
    final pos = _toSvg(details.localPosition);
    setState(() {
      _currentLine = [pos];
      _pointer = pos;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_shapes == null || _isDone) return;
    final pos = _toSvg(details.localPosition);
    setState(() {
      _currentLine.add(pos);
      _pointer = pos;
    });
  }

  void _onPanEnd() {
    if (_currentLine.isEmpty) return;
    setState(() {
      _lines.add(_currentLine);
      _currentLine = [];
    });
    _checkStroke();
  }

  // 지금 획을 80% 넘게 칠했으면 다음 획으로
  Future<void> _checkStroke() async {
    final shapes = _shapes;
    final index = _strokeIndex;
    final token = _scoreToken;
    if (shapes == null ||
        index >= shapes.strokes.length ||
        _completed.contains(index)) {
      return;
    }

    final ratio =
        await _fillRatio(shapes.viewBox, shapes.strokes[index], List.of(_lines));

    // 계산하는 사이 다시 쓰기·글자 이동·다음 획으로 넘어갔으면 버림
    if (!mounted ||
        token != _scoreToken ||
        index != _strokeIndex ||
        _completed.contains(index) ||
        ratio < _completeRatio) {
      return;
    }

    final isLast = index == shapes.strokes.length - 1;
    setState(() {
      _completed.add(index);
      _lines.clear();
      _currentLine = [];
      if (!isLast) {
        _strokeIndex++;
        _pointer = _startOf(_strokeIndex) ?? _pointer;
      }
    });
    if (isLast) widget.onComplete();
  }

  // 획(빨강)과 그 안에 그은 선(노랑)을 작은 이미지로 그려 칠한 비율 계산
  Future<double> _fillRatio(
      Rect viewBox, Path stroke, List<List<Offset>> lines) async {
    final k = _scoreWidth / viewBox.width;
    final height = (viewBox.height * k).ceil();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.scale(k);
    canvas.translate(-viewBox.left, -viewBox.top);
    canvas.drawPath(stroke, Paint()..color = const Color(0xFFFF0000));
    canvas.clipPath(stroke);

    final pen = Paint()
      ..color = const Color(0xFFFFFF00)
      ..strokeWidth = _penWidth
      ..strokeCap = StrokeCap.round;
    for (final line in lines) {
      for (int i = 0; i < line.length - 1; i++) {
        canvas.drawLine(line[i], line[i + 1], pen);
      }
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(_scoreWidth, height);
    picture.dispose();
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    image.dispose();
    if (byteData == null) return 0;

    final bytes = byteData.buffer.asUint8List();
    int total = 0, filled = 0;
    for (int i = 0; i < bytes.length; i += 4) {
      if (bytes[i] < 128) continue; // 획 밖
      total++;
      if (bytes[i + 1] >= 128) filled++;
    }

    // 칠할 곳이 없는 획은 완료로 처리
    return total == 0 ? 1 : filled / total;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shapes = _shapes;
        _fit(constraints.biggest, shapes?.viewBox ?? SvgPathParser.defaultViewBox);
        // 포인터·안내 크기도 글자 배율에 맞춤
        final pointerSize = _pointerSize * _scale;

        if (_failed) {
          return Center(
            child: GestureDetector(
              onTap: () => setState(_startLoad),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, size: pointerSize, color: mFontWhite),
                  Padding(
                    padding: EdgeInsets.only(top: 5 * _scale),
                    child: Text(
                      '글자를 불러오지 못했어요.\n눌러서 다시 시도해주세요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: mFontMain, fontSize: 11 * _scale),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (shapes == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final pointer = _pointer == null ? null : _toScreen(_pointer!);

        return GestureDetector(
          // 손가락을 댄 곳부터 선이 그려지도록
          dragStartBehavior: DragStartBehavior.down,
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          onPanEnd: (_) => _onPanEnd(),
          onPanCancel: _onPanEnd,
          child: Stack(
            children: [
              CustomPaint(
                size: Size.infinite,
                painter: TracingPainter(
                  strokes: shapes.strokes,
                  completedPaths: _completed,
                  currentPathIndex: _strokeIndex,
                  lines: _lines,
                  currentLine: _currentLine,
                  transform: Matrix4.diagonal3Values(_scale, _scale, 1)
                    ..setTranslationRaw(_origin.dx, _origin.dy, 0),
                  penWidth: _penWidth,
                ),
              ),
              if (pointer != null && !_isDone)
                Positioned(
                  left: pointer.dx - pointerSize / 2,
                  top: pointer.dy - pointerSize / 2,
                  child: SizedBox.square(
                    dimension: pointerSize,
                    child: Image.asset('assets/images/icon/pointer.png'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    widget.resetNotifier.removeListener(_onReset);
    super.dispose();
  }
}
