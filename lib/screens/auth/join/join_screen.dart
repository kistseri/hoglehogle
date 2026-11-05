import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/constants.dart';
import 'package:hoho_hanja/screens/auth/auth_widgets/auth_layout.dart';
import 'package:hoho_hanja/screens/auth/join/join_widgets/join_check_box.dart';
import 'package:hoho_hanja/screens/auth/join/join_widgets/join_textfield.dart';
import 'package:hoho_hanja/services/auth/update/nickname_check_service.dart';
import 'package:hoho_hanja/utils/design_scale.dart';

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
    final sc = DesignScale.fromContext(context);
    return Scaffold(
      backgroundColor: mBackWhite,
      appBar: authAppBar(sc),
      body: AuthContent(
        scale: sc,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: sc.d(16)),
              child: Center(
                child: Text(
                  '회원가입',
                  style: TextStyle(color: mFontMain, fontSize: sc.d(24), fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                // 맨 아래 버튼이 홈 표시줄에 붙지 않게
                padding: EdgeInsets.only(bottom: sc.d(16) + MediaQuery.paddingOf(context).bottom),
                children: [
                  JoinTextField(
                    controller: joinController.emailController,
                    hintText: '이메일',
                    icon: 'assets/images/icon/login_id.png',
                    type: TextFieldType.email,
                    // 소셜 가입(카카오/구글/애플)은 제공된 이메일을 수정할 수 없게 한다.
                    readOnly: widget.method != "0",
                  ),
                  // 애플(method "4")은 비밀번호 없이 가입
                  if (widget.method != "4")
                    Padding(
                      padding: EdgeInsets.only(top: sc.d(8)),
                      child: JoinTextField(
                        controller: joinController.passwordController,
                        hintText: '비밀번호',
                        icon: 'assets/images/icon/login_pw.png',
                        type: TextFieldType.password,
                      ),
                    ),
                  if (widget.method != "4")
                    Padding(
                      padding: EdgeInsets.only(top: sc.d(8)),
                      child: JoinTextField(
                        controller: joinController.pwdConfirmController,
                        hintText: '비밀번호 확인',
                        icon: 'assets/images/icon/login_pw.png',
                        type: TextFieldType.password,
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.only(top: sc.d(8)),
                    child: JoinTextField(
                      controller: joinController.nickNameController,
                      hintText: '이름 또는 닉네임',
                      icon: 'assets/images/icon/login_name.png',
                      type: TextFieldType.normal,
                      focusNode: _focusNode,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: sc.d(8)),
                    child: JoinTextField(
                      controller: joinController.phoneNumberController,
                      hintText: '휴대폰 번호',
                      icon: 'assets/images/icon/login_phone.png',
                      type: TextFieldType.phone,
                    ),
                  ),
                  JoinCheckBox(
                    method: widget.method,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}
