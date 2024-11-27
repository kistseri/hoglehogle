import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/constants.dart';
import 'package:hoho_hanja/screens/auth/login/local_login_screen.dart';
import 'package:hoho_hanja/services/auth/login/social/apple_login.dart';
import 'package:hoho_hanja/services/auth/login/social/google_service.dart';
import 'package:hoho_hanja/services/auth/login/social/kakao_service.dart';
import 'package:hoho_hanja/widgets/social_login_button.dart';

Widget socialLogin(context) {
  return Padding(
    padding: const EdgeInsets.all(32.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: getSocialPlatforms().map((platform) {
        return GestureDetector(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: getPlatform(platform),
          ),
          onTap: () {
            switch (platform) {
              case "local":
                Get.to(() => const LocalLoginScreen());
                break;
              case "kakao":
                kakaoLogin();
                break;
              case "google":
                googleLogin();
                break;
              case "apple":
                appleLogin();
                break;
            }
          },
        );
      }).toList(),
    ),
  );
}

Widget getPlatform(String platform) {
  switch (platform) {
    case "kakao":
      return socialLoginButton(platform, kakao, 'Kakao');
    case "google":
      return socialLoginButton(platform, google, 'Google');
    case "apple":
      return socialLoginButton(platform, apple, 'Apple');
    default:
      return Column(
        children: [
          Container(
            width: double.infinity,
            height: 50.h,
            decoration: BoxDecoration(
              color: mBackWhite,
              borderRadius: BorderRadius.circular(50.r),
              border: Border.all(color: mail),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0.w),
                  child: SizedBox(
                    height: 25.0.h,
                    width: 25.0.w,
                    child: Icon(
                      CupertinoIcons.mail,
                      color: mail,
                    ),
                  ),
                ),
                Text(
                  '이메일 • 로그인 회원가입',
                  style: TextStyle(color: mail),
                ),
                SizedBox(
                  height: 25.0.h,
                  width: 25.0.w,
                )
              ],
            ),
          ),
          SizedBox(
            height: 16.h,
          ),
          Divider(),
        ],
      );
  }
}
