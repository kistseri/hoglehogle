import 'dart:ui';

import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart';

// 따라쓰기 SVG에서 뽑은 도형 (SVG 좌표)
class TracingShapes {
  final Rect viewBox;
  final List<Path> strokes; // 획 (class st0), 쓰는 순서대로
  final List<Offset> starts; // 획 시작 표시 (class st1)의 가운데

  TracingShapes({
    required this.viewBox,
    required this.strokes,
    required this.starts,
  });
}

class SvgPathParser {
  // 서버 SVG의 기본 크기
  static const Rect defaultViewBox = Rect.fromLTWH(0, 0, 200, 248);

  // 서버에서 전달받은 SVG 데이터에서 획과 시작 표시를 가져오는 메서드
  static TracingShapes parseTracing(String svgData) {
    final document = XmlDocument.parse(svgData);

    // 점 하나뿐인 빈 도형(예: d="M75.1,158")은 획·시작 표시가 아니므로 제외
    bool notEmpty(Path path) => !path.getBounds().isEmpty;

    return TracingShapes(
      viewBox: _viewBox(document) ?? defaultViewBox,
      strokes: getShapesByClass(document, 'st0').where(notEmpty).toList(),
      starts: getShapesByClass(document, 'st1')
          .where(notEmpty)
          .map((path) => path.getBounds().center)
          .toList(),
    );
  }

  // 특정 클래스를 가진 도형을 문서 순서대로 Path로 변환
  // (path 말고도 rect·circle 등으로 저장된 획·시작 표시가 있음)
  static List<Path> getShapesByClass(XmlDocument document, String className) {
    return document.descendantElements
        .where((element) => element.getAttribute('class')?.trim() == className)
        .map(_toPath)
        .whereType<Path>()
        .toList();
  }

  static Path? _toPath(XmlElement element) {
    double attr(String name) =>
        double.tryParse(element.getAttribute(name) ?? '') ?? 0;

    switch (element.name.local) {
      case 'path':
        final d = element.getAttribute('d') ?? '';
        return d.trim().isEmpty ? null : parseSvgPathData(d);
      case 'rect':
        final rect =
            Rect.fromLTWH(attr('x'), attr('y'), attr('width'), attr('height'));
        final rx = attr('rx');
        final ry = element.getAttribute('ry') != null ? attr('ry') : rx;
        return Path()
          ..addRRect(RRect.fromRectXY(rect, rx, ry));
      case 'circle':
        return Path()
          ..addOval(Rect.fromCircle(
              center: Offset(attr('cx'), attr('cy')), radius: attr('r')));
      case 'ellipse':
        return Path()
          ..addOval(Rect.fromCenter(
              center: Offset(attr('cx'), attr('cy')),
              width: attr('rx') * 2,
              height: attr('ry') * 2));
      case 'line':
        return Path()
          ..moveTo(attr('x1'), attr('y1'))
          ..lineTo(attr('x2'), attr('y2'));
      case 'polygon':
      case 'polyline':
        final numbers = (element.getAttribute('points') ?? '')
            .trim()
            .split(RegExp(r'[\s,]+'))
            .map(double.tryParse)
            .whereType<double>()
            .toList();
        final points = [
          for (int i = 0; i + 1 < numbers.length; i += 2)
            Offset(numbers[i], numbers[i + 1])
        ];
        if (points.length < 2) return null;
        return Path()..addPolygon(points, element.name.local == 'polygon');
    }
    return null;
  }

  static Rect? _viewBox(XmlDocument document) {
    final values = (document.rootElement.getAttribute('viewBox') ?? '')
        .trim()
        .split(RegExp(r'[\s,]+'))
        .map(double.tryParse)
        .toList();
    if (values.length != 4 || values.contains(null)) return null;
    final rect = Rect.fromLTWH(values[0]!, values[1]!, values[2]!, values[3]!);
    return rect.isEmpty ? null : rect;
  }
}
