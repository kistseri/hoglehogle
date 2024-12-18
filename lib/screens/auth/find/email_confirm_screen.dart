import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/size.dart';
import 'package:hoho_hanja/screens/auth/find/password_find_screen.dart';

class EmailConfirmScreen extends StatelessWidget {
  final String id;
  final String nickName;
  const EmailConfirmScreen(
      {super.key, required this.id, required this.nickName});

  @override
  Widget build(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(gapHalf),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 100.r,
              child: Text(
                '아이디 찾기',
                style: TextStyle(
                    color: mFontMain,
                    fontSize: fontHuge,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 360.r,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '$nickName님의 아이디는\n',
                      style: TextStyle(
                        color: mFontMain,
                        fontSize: 25.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '$id\n',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 25.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '입니다.',
                      style: TextStyle(
                        color: mFontMain,
                        fontSize: 25.sp,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                height: 50.h,
                decoration: BoxDecoration(
                  color: mBtnActive,
                  borderRadius: BorderRadius.circular(50.r),
                ),
                child: Center(
                  child: Text(
                    '로그인 하기',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontFamily: 'mainFont'),
                  ),
                ),
              ),
            ),
            SizedBox(height: gapHalf),
            GestureDetector(
              onTap: () {
                Get.to(() => const PasswordFindScreen());
              },
              child: Container(
                width: double.infinity,
                height: 50.h,
                decoration: BoxDecoration(
                  color: mBtnBack,
                  borderRadius: BorderRadius.circular(50.r),
                ),
                child: Center(
                  child: Text(
                    '비밀번호 찾기',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontFamily: 'mainFont'),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
