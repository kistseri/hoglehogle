import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/constants.dart';
import 'package:hoho_hanja/_core/size.dart';
import 'package:hoho_hanja/screens/auth/join/join_widgets/join_check_box.dart';
import 'package:hoho_hanja/screens/auth/join/join_widgets/join_textfield.dart';

class JoinTextController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController pwdConfirmController = TextEditingController();
  TextEditingController nickNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
}

class JoinScreen extends StatelessWidget {
  final String method;
  final JoinTextController joinController = Get.put(JoinTextController());

  JoinScreen({super.key, required this.method});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mBackWhite,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: EdgeInsets.all(gapHalf),
          child: Center(
            child: Text(
              '회원가입',
              style: TextStyle(
                  color: mFontMain,
                  fontSize: fontHuge,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(gapHalf),
        child: ListView(
          // physics: NeverScrollableScrollPhysics(),
          children: [
            JoinTextField(
              controller: joinController.emailController,
              hintText: '이메일',
              icon: 'assets/images/icon/login_id.png',
              type: TextFieldType.email,
            ),
            SizedBox(height: gapQuarter),
            method != "4"
                ? JoinTextField(
                    controller: joinController.passwordController,
                    hintText: '비밀번호',
                    icon: 'assets/images/icon/login_pw.png',
                    type: TextFieldType.password,
                  )
                : SizedBox.shrink(),
            SizedBox(height: gapQuarter),
            method != "4"
                ? JoinTextField(
                    controller: joinController.pwdConfirmController,
                    hintText: '비밀번호 확인',
                    icon: 'assets/images/icon/login_pw.png',
                    type: TextFieldType.password,
                  )
                : SizedBox.shrink(),
            SizedBox(height: gapQuarter),
            JoinTextField(
              controller: joinController.nickNameController,
              hintText: '이름 또는 닉네임',
              icon: 'assets/images/icon/login_name.png',
              type: TextFieldType.normal,
            ),
            SizedBox(height: gapQuarter),
            JoinTextField(
              controller: joinController.phoneNumberController,
              hintText: '휴대폰 번호',
              icon: 'assets/images/icon/login_phone.png',
              type: TextFieldType.phone,
            ),
            JoinCheckBox(
              method: method,
            )
          ],
        ),
      ),
    );
  }
}
