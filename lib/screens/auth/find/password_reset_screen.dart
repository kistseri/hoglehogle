import 'package:flutter/material.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/constants.dart';
import 'package:hoho_hanja/screens/auth/auth_widgets/auth_layout.dart';
import 'package:hoho_hanja/screens/auth/join/join_widgets/join_textfield.dart';
import 'package:hoho_hanja/services/auth/update/password_reset_service.dart';
import 'package:hoho_hanja/utils/design_scale.dart';
import 'package:hoho_hanja/utils/encryption.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';

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
    failDialog('입력 확인', message);
  }

  @override
  Widget build(BuildContext context) {
    final sc = DesignScale.fromContext(context);
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
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
                      '비밀번호를\n재설정 해주세요.',
                      style: TextStyle(color: mFontMain, fontSize: sc.d(24), fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: sc.d(360),
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
                  AuthButton(
                    text: '변경하기',
                    color: mBtnActive,
                    onTap: () async {
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

                      await passwordResetService(widget.id, sha256_convertHash(password));
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
