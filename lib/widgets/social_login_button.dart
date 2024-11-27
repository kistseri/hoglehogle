import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hoho_hanja/_core/colors.dart';

Widget socialLoginButton(platform, color, title) {
  return Container(
    width: double.infinity,
    height: 50.0.h,
    decoration: BoxDecoration(
        color: color, borderRadius: BorderRadius.circular(50.0.sp)),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
              height: 25.0.h,
              width: 25.0.w,
              child: SvgPicture.asset("assets/images/social/$platform.svg")),
          Text(
            '$title로 로그인',
            style:
                TextStyle(color: platform == "kakao" ? mFontMain : mFontWhite),
          ),
          SizedBox(
            height: 25.0.h,
            width: 25.0.w,
          )
        ],
      ),
    ),
  );
}
