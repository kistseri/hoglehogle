import 'package:flutter/material.dart';
import 'package:hoho_hanja/_core/colors.dart';

// 지금 카드 / 전체 카드 수 (앱 글꼴을 쓰도록 RichText 대신 Text.rich)
class MatchingCounter extends StatelessWidget {
  const MatchingCounter({
    super.key,
    required this.currentIndex,
    required this.numOfItems,
    required this.fontSize,
  });

  final int currentIndex;
  final int numOfItems;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
        children: [
          TextSpan(text: '${currentIndex + 1}', style: const TextStyle(color: Colors.green)),
          TextSpan(text: '/$numOfItems', style: const TextStyle(color: mFontMain)),
        ],
      ),
    );
  }
}
