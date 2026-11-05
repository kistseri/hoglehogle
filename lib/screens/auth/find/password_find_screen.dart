import 'package:flutter/material.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/constants.dart';
import 'package:hoho_hanja/screens/auth/auth_widgets/auth_layout.dart';
import 'package:hoho_hanja/screens/auth/join/join_widgets/join_textfield.dart';
import 'package:hoho_hanja/services/auth/find/password_find_service.dart';
import 'package:hoho_hanja/utils/design_scale.dart';

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
                    fontFamily: 'mainFont',
                    onTap: () {
                      passwordFindService(emailController.text, phoneController.text);
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
