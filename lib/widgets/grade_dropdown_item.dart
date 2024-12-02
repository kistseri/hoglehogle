import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hoho_hanja/_core/colors.dart';

class GradeDropdownItem extends StatelessWidget {
  final int value;
  final String gradeLabel;

  const GradeDropdownItem({
    super.key,
    required this.value,
    required this.gradeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenuItem(
      value: value,
      child: Padding(
        padding: EdgeInsets.all(8.r),
        child: Container(
          height: 18.h,
          width: 35.w,
          decoration: BoxDecoration(
            color: mBackWhite,
            borderRadius: BorderRadius.circular(8.r),
          ),
          alignment: Alignment.center,
          child: FittedBox(
            child: Text(
              gradeLabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
