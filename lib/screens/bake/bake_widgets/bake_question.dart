import 'package:flutter/material.dart';
import 'package:hoho_hanja/_core/colors.dart';

// 곰의 말풍선 문제. 크기는 놓는 쪽에서 정함
class BakeQuestion extends StatelessWidget {
  final String question;
  final double fontSize;

  const BakeQuestion({super.key, required this.question, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bake/bake_question.png'),
          // 놓는 쪽에서 높이를 그림 비율에 맞추므로, 넓어지면 가로로만 늘어남
          fit: BoxFit.fill,
        ),
      ),
      child: Center(
        child: Text(
          insertLineBreak(question),
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: mFontBrown,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          softWrap: true,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  // 긴 문제는 두 번째 띄어쓰기에서 줄바꿈
  String insertLineBreak(String text) {
    if (text.length > 12) {
      int firstSpace = text.indexOf(' ');
      int secondSpace = text.indexOf(' ', firstSpace + 4);

      if (secondSpace != -1) {
        return text.replaceRange(secondSpace, secondSpace + 1, '\n');
      }
    }
    return text;
  }
}
