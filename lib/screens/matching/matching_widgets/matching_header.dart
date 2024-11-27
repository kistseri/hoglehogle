import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hoho_hanja/_core/colors.dart';

class MatchingHeader extends StatelessWidget {
  const MatchingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            '8급 한자 맞추기',
            style: TextStyle(
                color: mFontMain,
                fontSize: 24.0.sp,
                fontWeight: FontWeight.bold),
          ),
          Text(
            '카드를 뒤집어 한자를 맞혀보세요',
            style: TextStyle(
              color: mFontSub,
              fontSize: 15.0.sp,
            ),
          ),
        ],
      ),
    );
  }
}
