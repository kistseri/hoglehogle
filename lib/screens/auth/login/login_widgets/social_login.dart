import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/constants.dart';
import 'package:hoho_hanja/screens/auth/login/local_login_screen.dart';
import 'package:hoho_hanja/services/auth/login/social/apple_login.dart';
import 'package:hoho_hanja/services/auth/login/social/google_service.dart';
import 'package:hoho_hanja/services/auth/login/social/kakao_service.dart';
import 'package:hoho_hanja/utils/design_scale.dart';
import 'package:hoho_hanja/widgets/social_login_button.dart';

Widget socialLogin(BuildContext context, DesignScale sc) {
  return Padding(
    padding: EdgeInsets.all(sc.d(32)),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: getSocialPlatforms().map((platform) {
        return GestureDetector(
          child: Padding(
            padding: EdgeInsets.all(sc.d(8)),
            child: getPlatform(platform, sc),
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

Widget getPlatform(String platform, DesignScale sc) {
  switch (platform) {
    case "kakao":
      return socialLoginButton(platform, kakao, 'Kakao', sc);
    case "google":
      return socialLoginButton(platform, google, 'Google', sc);
    case "apple":
      return socialLoginButton(platform, apple, 'Apple', sc);
    default:
      return Column(
        children: [
          Container(
            width: double.infinity,
            height: sc.d(50),
            decoration: BoxDecoration(
              color: mBackWhite,
              borderRadius: BorderRadius.circular(sc.d(50)),
              border: Border.all(color: mail, width: sc.d(1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sc.d(16)),
                  child: Icon(CupertinoIcons.mail, color: mail, size: sc.d(25)),
                ),
                Text(
                  '이메일 • 로그인 회원가입',
                  style: TextStyle(color: mail, fontSize: sc.d(14)),
                ),
                // 글자가 가운데 오도록 아이콘과 같은 폭
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sc.d(16)),
                  child: SizedBox(width: sc.d(25)),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: sc.d(16)),
            child: Divider(height: sc.d(16), thickness: sc.d(1)),
          ),
        ],
      );
  }
}
