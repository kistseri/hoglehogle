import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/size.dart';
import 'package:hoho_hanja/data/DTO/requestDTO/joinDTO.dart';
import 'package:hoho_hanja/screens/auth/join/join_screen.dart';
import 'package:hoho_hanja/screens/auth/join/join_widgets/join_button.dart';
import 'package:hoho_hanja/services/auth/join/get_auth_code.dart';

class JoinCheckBox extends StatefulWidget {
  final String method;

  const JoinCheckBox({super.key, required this.method});

  @override
  State<JoinCheckBox> createState() => _JoinCheckBoxState();
}

class _JoinCheckBoxState extends State<JoinCheckBox> {
  bool isChecked1 = false;
  bool isChecked2 = false;

  @override
  Widget build(BuildContext context) {
    final JoinReqDTOController joinReqDTO = Get.put(JoinReqDTOController());
    final joinController = Get.put(JoinTextController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildCheckBox(
          '이용약관 동의 (필수)',
          isChecked1,
          (value) {
            setState(() {
              isChecked1 = value!;
            });
          },
          context,
          showTermsDialog,
        ),
        buildCheckBox(
          '개인정보 수집 및 이용동의 (필수)',
          isChecked2,
          (value) {
            setState(() {
              isChecked2 = value!;
            });
          },
          context,
          showPrivacyPolicyDialog,
        ),
        SizedBox(height: gapHuge),
        Center(
          child: JoinButton(
            text: '휴대폰 인증하기',
            movePage: () async {
              final error = _validateInputs(joinController);
              if (error != null) {
                Get.snackbar(
                  '입력 확인',
                  error,
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 3),
                );
                return;
              }

              joinReqDTO.setJoinDTO(
                  email: joinController.emailController.text,
                  password: joinController.passwordController.text,
                  nickName: joinController.nickNameController.text,
                  phoneNumber: joinController.phoneNumberController.text,
                  method: widget.method,
                  agree1: isChecked1 ? "Y" : "N",
                  agree2: isChecked2 ? "Y" : "N");
              await getAuthCode();
            },
            isEnabled: isChecked1 && isChecked2,
          ),
        ),
      ],
    );
  }

  // 인증번호 요청 전 입력값 검사. 문제가 있으면 안내 문구를, 정상이면 null을 반환한다.
  String? _validateInputs(JoinTextController c) {
    final email = c.emailController.text.trim();
    final password = c.passwordController.text;
    final pwdConfirm = c.pwdConfirmController.text;
    final nickName = c.nickNameController.text.trim();
    final phone = c.phoneNumberController.text.trim();

    // 이메일 형식
    final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    if (email.isEmpty) {
      return '이메일을 입력해주세요.';
    }
    if (!emailRegex.hasMatch(email)) {
      return '이메일 형식이 올바르지 않습니다.';
    }

    // 비밀번호 (비밀번호 입력이 있는 가입 방식만 검사: 애플(method "4")은 제외)
    if (widget.method != "4") {
      if (password.isEmpty) {
        return '비밀번호를 입력해주세요.';
      }
      if (password.length < 6) {
        return '비밀번호는 6자 이상이어야 합니다.';
      }
      if (password != pwdConfirm) {
        return '비밀번호와 비밀번호 확인이 일치하지 않습니다.';
      }
    }

    // 닉네임
    if (nickName.isEmpty) {
      return '이름 또는 닉네임을 입력해주세요.';
    }

    // 휴대폰 번호 (10~11자리)
    if (phone.length < 10 || phone.length > 11) {
      return '휴대폰 번호를 정확히 입력해주세요.';
    }

    return null;
  }

  Widget buildCheckBox(String text, bool isChecked, Function(bool?) onChanged,
      BuildContext context, void Function(BuildContext) onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                onChanged(!isChecked);
              },
              child: Checkbox(
                value: isChecked,
                onChanged: onChanged,
                activeColor: primaryColor,
                checkColor: Colors.white,
                side: BorderSide(
                  color: isChecked ? primaryColor : Colors.grey,
                  width: 2,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                if (onTap != null) {
                  onTap(context);
                }
              },
              child: Text(
                text,
                style: const TextStyle(
                  color: mFontMain,
                ),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            if (onTap != null) {
              onTap(context);
            }
          },
          child: Icon(
            CupertinoIcons.forward,
            color: mFontMain,
            size: fontLarge,
          ),
        )
      ],
    );
  }

//TODO: 이용약관 및 개인정보수집 내용 입력
  void showTermsDialog(BuildContext context) {
    Future<String> loadTermText() async {
      return await rootBundle.loadString('assets/text/hogulhogul_terms.txt');
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Center(child: Text('이용 약관')),
          content: FutureBuilder(
              future: loadTermText(),
              builder: (context, snapshot) {
                return SingleChildScrollView(
                  child: ListBody(
                    children: [Text(snapshot.data ?? 'No terms found')],
                  ),
                );
              }),
          actions: [
            GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  Get.back();
                },
                child: const Text('닫기')),
            GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  Get.back();
                  setState(() {
                    isChecked1 = true;
                  });
                },
                child: const Text('동의', style: TextStyle(color: primaryColor))),
          ],
        );
      },
    );
  }

  void showPrivacyPolicyDialog(BuildContext context) {
    Future<String> loadPrivacyText() async {
      return await rootBundle.loadString('assets/text/hogulhogul_privacy.txt');
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Center(child: Text('개인정보 처리방침')),
          content: FutureBuilder(
              future: loadPrivacyText(),
              builder: (context, snapshot) {
                return SingleChildScrollView(
                  child: ListBody(
                    children: [Text(snapshot.data ?? 'No terms found')],
                  ),
                );
              }),
          actions: [
            GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  Get.back();
                },
                child: const Text('닫기')),
            GestureDetector(
                onTap: () {
                  FocusScope.of(context).unfocus();
                  Get.back();
                  setState(() {
                    isChecked2 = true;
                  });
                },
                child: const Text('동의', style: TextStyle(color: primaryColor))),
          ],
        );
      },
    );
  }
}
