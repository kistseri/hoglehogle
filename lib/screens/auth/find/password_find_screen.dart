import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/constants.dart';
import 'package:hoho_hanja/_core/size.dart';
import 'package:hoho_hanja/screens/auth/join/join_widgets/join_textfield.dart';
import 'package:hoho_hanja/services/auth/find/password_find_service.dart';

class PasswordFindScreen extends StatefulWidget {
  const PasswordFindScreen({super.key});

  @override
  State<PasswordFindScreen> createState() => _PasswordFindScreenState();
}

class _PasswordFindScreenState extends State<PasswordFindScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: EdgeInsets.all(gapHalf),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                height: 100.r,
                child: Text(
                  '비밀번호 찾기',
                  style: TextStyle(color: mFontMain, fontSize: fontHuge, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 360.r,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      JoinTextField(
                        controller: emailController,
                        hintText: '이메일',
                        icon: ('assets/images/icon/login_id.png'),
                        type: TextFieldType.email,
                      ),
                      JoinTextField(
                        controller: phoneController,
                        hintText: '휴대폰 번호',
                        icon: ('assets/images/icon/login_phone.png'),
                        type: TextFieldType.phone,
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  passwordFindService(emailController.text, phoneController.text);
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
                      '확인',
                      style: TextStyle(color: Colors.white, fontSize: 18.sp, fontFamily: 'mainFont'),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
