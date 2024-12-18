import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/constants.dart';
import 'package:hoho_hanja/_core/size.dart';
import 'package:hoho_hanja/screens/auth/join/join_widgets/join_check_box.dart';
import 'package:hoho_hanja/screens/auth/join/join_widgets/join_textfield.dart';
import 'package:hoho_hanja/services/auth/update/nickname_check_service.dart';

class JoinTextController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController pwdConfirmController = TextEditingController();
  TextEditingController nickNameController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
}

class JoinScreen extends StatefulWidget {
  final String method;

  const JoinScreen({super.key, required this.method});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  final JoinTextController joinController = Get.put(JoinTextController());
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() async {
      if (!_focusNode.hasFocus) {
        final nickName = joinController.nickNameController.text;
        if (nickName.isNotEmpty) {
          final status = await nicknameCheckService('join', nickName);
          if (status == 'duplication') {
            joinController.nickNameController.text = '';
            Get.snackbar(
              '알림',
              '중복된 닉네임입니다.',
              snackPosition: SnackPosition.BOTTOM,
              duration: const Duration(seconds: 3),
            );
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mBackWhite,
      appBar: AppBar(
          // automaticallyImplyLeading: false,
          ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: gapHalf),
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
          Expanded(
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
                widget.method != "4"
                    ? JoinTextField(
                        controller: joinController.passwordController,
                        hintText: '비밀번호',
                        icon: 'assets/images/icon/login_pw.png',
                        type: TextFieldType.password,
                      )
                    : SizedBox.shrink(),
                SizedBox(height: gapQuarter),
                widget.method != "4"
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
                  focusNode: _focusNode,
                ),
                SizedBox(height: gapQuarter),
                JoinTextField(
                  controller: joinController.phoneNumberController,
                  hintText: '휴대폰 번호',
                  icon: 'assets/images/icon/login_phone.png',
                  type: TextFieldType.phone,
                ),
                JoinCheckBox(
                  method: widget.method,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
