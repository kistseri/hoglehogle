import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/constants.dart';
import 'package:hoho_hanja/screens/auth/auth_widgets/auth_layout.dart';
import 'package:hoho_hanja/screens/auth/join/join_widgets/join_textfield.dart';
import 'package:hoho_hanja/services/auth/find/email_find_service.dart';
import 'package:hoho_hanja/utils/design_scale.dart';

class EmailFindScreen extends StatefulWidget {
  const EmailFindScreen({super.key});

  @override
  State<EmailFindScreen> createState() => _EmailFindScreenState();
}

class _EmailFindScreenState extends State<EmailFindScreen> {
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
                      '아이디 찾기',
                      style: TextStyle(color: mFontMain, fontSize: sc.d(24), fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    height: sc.d(360),
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
                  AuthButton(
                    text: '인증번호 받기',
                    color: mBtnActive,
                    onTap: () {
                      if (phoneController.text.isEmpty) {
                        Get.defaultDialog(
                          title: '아이디 찾기 실패',
                          middleText: '전화번호를 입력해주세요.',
                          textConfirm: '확인',
                          buttonColor: primaryColor,
                          onConfirm: () {
                            Get.back();
                          },
                        );
                      } else {
                        emailFindService(phoneController.text);
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
