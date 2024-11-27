import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hoho_hanja/_core/colors.dart';

class JoinButton extends StatelessWidget {
  final String text;
  final VoidCallback movePage;
  final bool? isEnabled;
  const JoinButton({
    super.key,
    required this.text,
    required this.movePage,
    this.isEnabled,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isEnabled != false) {
          movePage();
        }
      },
      child: Container(
        width: double.infinity,
        height: 50.h,
        decoration: BoxDecoration(
          color: isEnabled == true
              ? mBtnActive
              : mBtnBack, // Color change based on isEnabled
          borderRadius: BorderRadius.circular(50.r),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
            ),
          ),
        ),
      ),
    );
  }
}
