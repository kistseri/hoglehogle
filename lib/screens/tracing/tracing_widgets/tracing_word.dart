import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hoho_hanja/data/models/tracing_data.dart';
import 'package:hoho_hanja/screens/tracing/tracing_widgets/tracing_painter.dart';
import 'package:hoho_hanja/utils/get_svg_path.dart';
import 'package:logger/logger.dart';
import 'package:path_drawing/path_drawing.dart';

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
  final customGloblaKey = GlobalKey();
  List<List<Offset>> _lines = [];
  List<Offset> _currentLine = [];
  double _top = 100;
  double _left = 100;
  List<Path>? firstPaths;
  List<Path> remainingPaths = [];
  int currentPathIndex = 0;
  Set<int> completedPaths = {};

  @override
  void initState() {
    super.initState();
    widget.resetNotifier.addListener(_onReset);
  }

  @override
  void didUpdateWidget(covariant TracingWord oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      setState(() {
        firstPaths = null;
      });
    }
  }

  void _onReset() {
    resetTracing();
  }

  void _updatePointerPositionWithinBounds(Offset localPosition) {
    RenderBox renderBox =
        customGloblaKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;

    setState(() {
      _left = localPosition.dx.clamp(0.0, size.width - 50.w);
      _top = localPosition.dy.clamp(0.0, size.height - 50.h);
    });
  }

  Future<void> _loadSvgPathFromServer(Size size, int currentIndex) async {
    try {
      final response = await Dio()
          .get(widget.tracingController.tracingDataList![currentIndex].svg);

      if (response.statusCode == 200) {
        final svgData = response.data;
        final pathDataList =
            SvgPathParser.getPathsByClassFromData(svgData, 'st0');
        if (pathDataList.isNotEmpty) {
          setState(() {
            const svgSize = Size(200, 248);
            final scaleX = size.width / svgSize.width;
            final scaleY = size.height / svgSize.height;

            firstPaths = pathDataList.map((pathData) {
              final path = parseSvgPathData(pathData);
              return path.transform(
                  Matrix4.diagonal3Values(scaleX, scaleY, 1).storage);
            }).toList();
          });
        } else {
          Logger().d("class='st0' 속성을 가진 path 데이터를 찾을 수 없습니다.");
        }

        final remainingPathData = SvgPathParser.getAllElementsFromData(svgData);
        setState(() {
          remainingPaths = remainingPathData
              .where((element) => element['class'] == 'st1')
              .map((element) {
                String? dAttribute;
                if (element['type'] == 'path') {
                  dAttribute = element['d'];
                } else if (element['type'] == 'line') {
                  dAttribute =
                      'M${element['x1']},${element['y1']} L${element['x2']},${element['y2']}';
                }
                return dAttribute != null
                    ? parseSvgPathData(dAttribute).transform(
                        Matrix4.diagonal3Values(
                                size.width / 200, size.height / 248, 1)
                            .storage)
                    : null;
              })
              .where((path) => path != null)
              .cast<Path>()
              .toList();

          if (remainingPaths.isNotEmpty) {
            _updatePointerPosition();
          }
        });
      } else {
        Logger().e("SVG 데이터를 서버로부터 가져오는 데 실패했습니다.");
      }
    } catch (e) {
      Logger().e("SVG 데이터를 불러오는 중 오류 발생: $e");
    }
  }

  void _updatePointerPosition() {
    if (currentPathIndex < remainingPaths.length) {
      final pathMetric =
          remainingPaths[currentPathIndex].computeMetrics().first;
      final startPoint = pathMetric.getTangentForOffset(0)?.position;
      if (startPoint != null) {
        setState(() {
          _top = startPoint.dy - 25;
          _left = startPoint.dx - 25;
        });
      }
    }
  }

  void resetTracing() {
    setState(() {
      _lines.clear();
      _currentLine.clear();
      currentPathIndex = 0;
      completedPaths.clear();
      _updatePointerPosition();
    });
  }

  void _handlePan(DragUpdateDetails? updateDetails,
      {DragStartDetails? startDetails, DragEndDetails? endDetails}) {
    RenderBox renderBox =
        customGloblaKey.currentContext!.findRenderObject() as RenderBox;
    final localPosition = updateDetails?.localPosition ??
        startDetails?.localPosition ??
        endDetails?.localPosition;

    if (localPosition != null) {
      _updatePointerPositionWithinBounds(localPosition);
    }
    setState(() {
      if (startDetails != null) {
        _currentLine = [startDetails.localPosition];
        _top = startDetails.localPosition.dy - 25;
        _left = startDetails.localPosition.dx - 25;
      } else if (updateDetails != null) {
        _currentLine.add(updateDetails.localPosition);
        _top = updateDetails.localPosition.dy - 25;
        _left = updateDetails.localPosition.dx - 25;
      } else if (endDetails != null) {
        _lines.add(List.from(_currentLine));

        if (_isCurrentPathCompleted(_currentLine)) {
          completedPaths.add(currentPathIndex);
          currentPathIndex++;
          _lines.removeLast();

          if (currentPathIndex >= remainingPaths.length) {
            widget.onComplete();
          } else {
            _updatePointerPosition();
          }
        } else {
          _lines.removeLast();
        }
        _currentLine.clear();
      }
    });
  }

  bool _isCurrentPathCompleted(List<Offset> drawnLine) {
    if (firstPaths == null || currentPathIndex >= firstPaths!.length) {
      return false;
    }

    final path = firstPaths![currentPathIndex];
    final pathMetrics = path.computeMetrics().toList();

    for (final metric in pathMetrics) {
      for (final offset in drawnLine) {
        for (double t = 0; t < metric.length; t += 1) {
          final tangent = metric.getTangentForOffset(t);
          if (tangent != null && (tangent.position - offset).distance < 5.0) {
            return true;
          }
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (firstPaths == null) {
          _loadSvgPathFromServer(
              Size(constraints.maxWidth, constraints.maxHeight),
              widget.currentIndex);
        }
        return GestureDetector(
          onPanStart: (details) => _handlePan(null, startDetails: details),
          onPanUpdate: (details) => _handlePan(details),
          onPanEnd: (details) => _handlePan(null, endDetails: details),
          child: Stack(
            children: [
              CustomPaint(
                key: customGloblaKey,
                size: Size.infinite,
                painter: TracingPainter(_lines, _currentLine,
                    clipPath: firstPaths,
                    remainingPaths: remainingPaths,
                    currentPathIndex: currentPathIndex,
                    completedPaths: completedPaths),
              ),
              Positioned(
                top: _top,
                left: _left,
                child: SizedBox(
                  height: 50.h,
                  width: 50.w,
                  child: Image.asset(
                    'assets/images/icon/pointer.png',
                  ),
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
