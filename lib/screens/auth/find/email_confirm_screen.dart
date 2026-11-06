import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/screens/auth/auth_widgets/auth_layout.dart';
import 'package:hoho_hanja/screens/auth/find/password_find_screen.dart';
import 'package:hoho_hanja/screens/auth/login/local_login_screen.dart';
import 'package:hoho_hanja/screens/auth/login/social_login_screen.dart';
import 'package:hoho_hanja/utils/design_scale.dart';

class EmailConfirmScreen extends StatelessWidget {
  final String id;
  final String nickName;
  const EmailConfirmScreen(
      {super.key, required this.id, required this.nickName});

  @override
  Widget build(BuildContext context) {
    final sc = DesignScale.fromContext(context);
    return Scaffold(
      appBar: authAppBar(sc),
      body: SingleChildScrollView(
        child: AuthContent(
          scale: sc,
          child: Padding(
            padding: EdgeInsets.all(sc.d(16)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: sc.d(100),
                  child: Text(
                    '아이디 찾기',
                    style: TextStyle(color: mFontMain, fontSize: sc.d(24), fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: sc.d(360),
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '$nickName님의 아이디는\n',
                          style: TextStyle(color: mFontMain, fontSize: sc.d(25), fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: '$id\n',
                          style: TextStyle(color: primaryColor, fontSize: sc.d(25), fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: '입니다.',
                          style: TextStyle(color: mFontMain, fontSize: sc.d(25)),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                AuthButton(
                  text: '로그인 하기',
                  color: mBtnActive,
                  // 찾기 화면들을 닫고 이메일 로그인 화면으로 (C-11)
                  onTap: () {
                    Get.offAll(() => const LoginScreen());
                    Get.to(() => const LocalLoginScreen());
                  },
                ),
                Padding(
                  padding: EdgeInsets.only(top: sc.d(16)),
                  child: AuthButton(
                    text: '비밀번호 찾기',
                    color: mBtnBack,
                    onTap: () {
                      Get.to(() => const PasswordFindScreen());
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
