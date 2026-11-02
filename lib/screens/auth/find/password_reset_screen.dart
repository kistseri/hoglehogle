import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/constants.dart';
import 'package:hoho_hanja/_core/size.dart';
import 'package:hoho_hanja/screens/auth/join/join_widgets/join_textfield.dart';
import 'package:hoho_hanja/services/auth/update/password_reset_service.dart';
import 'package:hoho_hanja/utils/encryption.dart';

class PasswordResetScreen extends StatefulWidget {
  final String id;

  const PasswordResetScreen({super.key, required this.id});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController = TextEditingController();

  void _showInputError(String message) {
    Get.snackbar(
      '입력 확인',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
    );
  }

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
                  '비밀번호를\n재설정 해주세요.',
                  style: TextStyle(color: mFontMain, fontSize: fontHuge, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 360.r,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      JoinTextField(
                        controller: passwordController,
                        hintText: '비밀번호',
                        icon: ('assets/images/icon/login_pw.png'),
                        type: TextFieldType.password,
                      ),
                      JoinTextField(
                        controller: passwordConfirmController,
                        hintText: '비밀번호 확인',
                        icon: ('assets/images/icon/login_pw.png'),
                        type: TextFieldType.password,
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  final password = passwordController.text;
                  final passwordConfirm = passwordConfirmController.text;

                  if (password.isEmpty) {
                    _showInputError('비밀번호를 입력해주세요.');
                    return;
                  }
                  if (password.length < 6) {
                    _showInputError('비밀번호는 6자 이상이어야 합니다.');
                    return;
                  }
                  if (password != passwordConfirm) {
                    _showInputError('비밀번호와 비밀번호 확인이 일치하지 않습니다.');
                    return;
                  }

                  passwordResetService(widget.id, sha256_convertHash(password));
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
                      '변경하기',
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
