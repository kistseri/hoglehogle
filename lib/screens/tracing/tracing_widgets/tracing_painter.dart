import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hoho_hanja/_core/colors.dart';

class TracingPainter extends CustomPainter {
  final List<List<Offset>> lines;
  final List<Offset> currentLine;
  final List<Path>? clipPath;
  final List<Path> remainingPaths;
  final int currentPathIndex;
  final Set<int> completedPaths;

  TracingPainter(this.lines, this.currentLine,
      {this.clipPath,
      required this.remainingPaths,
      required this.currentPathIndex,
      required this.completedPaths});

  @override
  void paint(Canvas canvas, Size size) {
    // 흰색 한자 배경
    if (clipPath != null && clipPath!.isNotEmpty) {
      final combinedClipPath =
          clipPath!.reduce((a, b) => Path.combine(PathOperation.union, a, b));
      canvas.clipPath(combinedClipPath);

      for (int i = clipPath!.length - 1; i >= 0; i--) {
        final path = clipPath![i];

        final fillPaint = Paint()
          ..color = completedPaths.contains(i) ? primaryColor : Colors.white
          ..style = PaintingStyle.fill;

        canvas.drawPath(path, fillPaint);
      }
    }

    // 사용자의 라인 그리기
    final paint = Paint()
      ..color = primaryColor
      ..strokeWidth = 60.sp
      ..strokeCap = StrokeCap.round;

    for (var line in lines) {
      for (int i = 0; i < line.length - 1; i++) {
        canvas.drawLine(line[i], line[i + 1], paint);
      }
    }

    for (int i = 0; i < currentLine.length - 1; i++) {
      canvas.drawLine(currentLine[i], currentLine[i + 1], paint);
    }

    // 경로 표시
    if (clipPath != null && currentPathIndex < clipPath!.length) {
      final path = clipPath![currentPathIndex];
      final pathMetrics = path.computeMetrics();

      final dotPaint = Paint()
        ..color = Colors.red
        ..style = PaintingStyle.fill;

      for (final metric in pathMetrics) {
        for (double t = 0; t < metric.length; t += 10.0) {
          final position = metric.getTangentForOffset(t)?.position;
          if (position != null) {
            canvas.drawCircle(position, 3.0, dotPaint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
