import 'package:flutter/material.dart';
import 'package:hoho_hanja/_core/colors.dart';

// 획·선은 모두 SVG 좌표로 받아서 transform으로 화면에 맞춰 그림
class TracingPainter extends CustomPainter {
  final List<Path> strokes;
  final Set<int> completedPaths;
  final int currentPathIndex;
  final List<List<Offset>> lines;
  final List<Offset> currentLine;
  final Matrix4 transform;
  final double penWidth;

  // 가이드 점 간격·크기 (SVG 좌표)
  static const double dotGap = 6.0;
  static const double dotRadius = 1.8;

  TracingPainter({
    required this.strokes,
    required this.completedPaths,
    required this.currentPathIndex,
    required this.lines,
    required this.currentLine,
    required this.transform,
    required this.penWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (strokes.isEmpty) return;

    canvas.save();
    canvas.transform(transform.storage);

    // 1. 안 쓴 획(흰색)을 먼저, 다 쓴 획(주색)을 나중에 그려 겹치는 곳은 다 쓴 획이 위로
    final emptyPaint = Paint()..color = Colors.white;
    final donePaint = Paint()..color = primaryColor;
    for (int i = 0; i < strokes.length; i++) {
      if (!completedPaths.contains(i)) canvas.drawPath(strokes[i], emptyPaint);
    }
    for (int i = 0; i < strokes.length; i++) {
      if (completedPaths.contains(i)) canvas.drawPath(strokes[i], donePaint);
    }

    // 다 쓴 글자는 마지막 획도 완료라 선·점선을 그리지 않음
    final hasCurrent = currentPathIndex < strokes.length &&
        !completedPaths.contains(currentPathIndex);

    // 2. 지금 쓰는 획 안에만 사용자 선
    if (hasCurrent) {
      canvas.save();
      canvas.clipPath(strokes[currentPathIndex]);

      final userPaint = Paint()
        ..color = primaryColor
        ..strokeWidth = penWidth
        ..strokeCap = StrokeCap.round;

      for (final line in [...lines, currentLine]) {
        for (int i = 0; i < line.length - 1; i++) {
          canvas.drawLine(line[i], line[i + 1], userPaint);
        }
      }

      canvas.restore();
    }

    // 3. 지금 획의 테두리 점선
    if (hasCurrent) {
      final dotPaint = Paint()..color = Colors.red;
      for (final metric in strokes[currentPathIndex].computeMetrics()) {
        for (double t = 0; t < metric.length; t += dotGap) {
          final pos = metric.getTangentForOffset(t)?.position;
          if (pos != null) {
            canvas.drawCircle(pos, dotRadius, dotPaint);
          }
        }
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
