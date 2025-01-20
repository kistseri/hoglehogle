import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/size.dart';
import 'package:hoho_hanja/screens/auth/login/social_login_screen.dart';
import 'package:hoho_hanja/utils/logout.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.offAll(() => const LoginScreen());
        logout();
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Colors.grey)),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(gapHalf),
            child: Text(
              '로그아웃',
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
