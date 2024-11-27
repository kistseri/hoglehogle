import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hoho_hanja/_core/colors.dart';

class MatchingCounter extends StatelessWidget {
  const MatchingCounter({
    super.key,
    required this.currentIndex,
    required this.numOfItems,
  });

  final int currentIndex;
  final int numOfItems;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Center(
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '${currentIndex + 1}',
                style: TextStyle(
                    color: Colors.green,
                    fontSize: 26.0.sp,
                    fontWeight: FontWeight.bold),
              ),
              TextSpan(
                text: '/$numOfItems',
                style: TextStyle(
                    color: mFontMain,
                    fontSize: 26.0.sp,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
        ),
      ),
    );
  }
}
