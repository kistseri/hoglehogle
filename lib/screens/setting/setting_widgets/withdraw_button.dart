import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/size.dart';
import 'package:hoho_hanja/widgets/dialog/withdraw_dialog.dart';

class WithdrawButton extends StatelessWidget {
  const WithdrawButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showWithdrawDialog();
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Colors.grey)),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(gapHalf),
            child: Text(
              '회원 탈퇴',
              style: TextStyle(
                color: mFontSub,
                fontSize: 16.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
