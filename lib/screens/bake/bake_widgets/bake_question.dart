import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hoho_hanja/_core/colors.dart';

class BakeQuestion extends StatelessWidget {
  final String question;
  const BakeQuestion({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100.h,
      right: 10.w,
      child: Container(
        height: 75.h,
        width: 225.w,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bake/bake_question.png'),
            fit: BoxFit.contain,
          ),
        ),
        child: Center(
          child: Text(
            insertLineBreak(question, 8),
            // question,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: mFontBrown,
            ),
            maxLines: 2,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  String insertLineBreak(String text, int breakpoint) {
    if (text.length > 12) {
      int firstSpace = text.indexOf(' ');
      int secondSpace = text.indexOf(' ', firstSpace + 1);

      if (secondSpace != -1) {
        return text.replaceRange(secondSpace, secondSpace + 1, '\n');
      }
    }
    return text;
  }
}
