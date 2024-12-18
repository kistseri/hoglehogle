import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/constants.dart';
import 'package:hoho_hanja/_core/size.dart';
import 'package:hoho_hanja/screens/auth/join/join_widgets/join_textfield.dart';
import 'package:hoho_hanja/services/auth/find/email_find_service.dart';

class EmailFindScreen extends StatelessWidget {
  const EmailFindScreen({super.key});

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
              child: Align(
                alignment: Alignment.topCenter,
                child: JoinTextField(
                  controller: phoneController,
                  hintText: '휴대폰 번호',
                  icon: ('assets/images/icon/login_phone.png'),
                  type: TextFieldType.phone,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                emailFindService(phoneController.text);
              },
              child: Container(
                width: double.infinity,
                height: 50.h,
                decoration: BoxDecoration(
                  color: mBtnActive,
                  borderRadius: BorderRadius.circular(50.r),
                ),
                child: Center(
                  child: Text(
                    '인증번호 받기',
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
