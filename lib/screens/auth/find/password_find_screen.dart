import 'package:flutter/material.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/constants.dart';
import 'package:hoho_hanja/screens/auth/auth_widgets/auth_layout.dart';
import 'package:hoho_hanja/screens/auth/join/join_widgets/join_textfield.dart';
import 'package:hoho_hanja/services/auth/find/password_find_service.dart';
import 'package:hoho_hanja/utils/design_scale.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';

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
                      '비밀번호 찾기',
                      style: TextStyle(color: mFontMain, fontSize: sc.d(24), fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: sc.d(360),
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
                  AuthButton(
                    text: '확인',
                    color: mBtnActive,
                    onTap: () {
                      // 입력값 확인 후 요청 (C-27)
                      final email = emailController.text.trim();
                      final phone = phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
                      // 이메일 형식이 아닌 아이디(예: test)로 가입한 기존 회원이 있어 형식은 검사하지 않음
                      if (email.isEmpty) {
                        failDialog('비밀번호 찾기 실패', '아이디(이메일)를 입력해주세요.');
                      } else if (phone.length != 10 && phone.length != 11) {
                        failDialog('비밀번호 찾기 실패', '휴대폰 번호를 정확히 입력해주세요.');
                      } else {
                        passwordFindService(email, phone);
                      }
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
