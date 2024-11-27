import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hoho_hanja/_core/colors.dart';

class CookieQuestion extends StatelessWidget {
  final String question;
  const CookieQuestion({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: MediaQuery.of(context).size.height * 0.12,
      right: 10.w,
      child: Container(
        height: 75.h,
        width: 225.w,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/cookie/cookie_question.png'),
            fit: BoxFit.contain,
          ),
        ),
        child: Center(
          child: FittedBox(
            child: Text(
              question,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: mFontBrown,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
