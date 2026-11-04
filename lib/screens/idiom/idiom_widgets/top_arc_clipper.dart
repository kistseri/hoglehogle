import 'package:flutter/material.dart';

class TopArcClipper extends CustomClipper<Path> {
  final double arcHeight;

  TopArcClipper({this.arcHeight = 30});

  @override
  Path getClip(Size size) {
    final w = size.width;
    final r = (w * w / 4 + arcHeight * arcHeight) / (2 * arcHeight);

    return Path()
      ..moveTo(0, arcHeight)
      ..arcToPoint(
        Offset(w, arcHeight),
        radius: Radius.circular(r),
        clockwise: true,
      )
      ..lineTo(w, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant TopArcClipper old) => old.arcHeight != arcHeight;
}