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
                  setState(() {
                    isChecked1 = true;
                  });
                },
                child: Text('닫기')),
          ],
        );
      },
    ).then((_) {
      setState(() {
        isChecked1 = true;
      });
    });
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
                  setState(() {
                    isChecked2 = true;
                  });
                },
                child: Text('닫기')),
          ],
        );
      },
    ).then((_) {
      setState(() {
        isChecked2 = true;
      });
    });
  }
}
