import 'package:flutter/material.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/utils/design_scale.dart';

// 문제 말풍선 (위치·크기는 쿠키 화면에서 시안 좌표로 정함)
class CookieQuestion extends StatelessWidget {
  final DesignScale scale;
  final String question;
  const CookieQuestion({super.key, required this.scale, required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: scale.d(16)),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/cookie/cookie_question.png'),
          fit: BoxFit.contain,
        ),
      ),
      child: Center(
        // 문제가 길어도 말풍선 밖으로 넘치지 않게
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            question,
            style: TextStyle(
              fontSize: scale.d(20),
              fontWeight: FontWeight.bold,
              color: mFontBrown,
            ),
          ),
        ),
      ),
    );
  }
}
