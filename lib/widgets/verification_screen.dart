import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/screens/auth/auth_widgets/auth_layout.dart';
import 'package:hoho_hanja/utils/design_scale.dart';
import 'package:hoho_hanja/utils/verification.dart';

class Verification extends StatelessWidget {
  final String id;
  final bool isJoin;

  Verification({super.key, required this.id, required this.isJoin});

  final VerificationController controller = Get.put(VerificationController());

  @override
  Widget build(BuildContext context) {
    final sc = DesignScale.fromContext(context);
    return Scaffold(
      backgroundColor: mBackWhite,
      appBar: authAppBar(sc),
      body: SafeArea(
        child: SingleChildScrollView(
          child: AuthContent(
            scale: sc,
            child: Padding(
              padding: EdgeInsets.all(sc.d(16)),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(sc.d(16)),
                    child: Center(
                      child: Text(
                        '휴대폰으로 발송된\n인증번호를 입력해 주세요',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: mFontMain, fontSize: sc.d(24), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: sc.d(32)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return Expanded(
                          flex: 1,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: sc.d(8)),
                            child: TextField(
                              controller: controller.textControllers[index],
                              focusNode: controller.focusNodes[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: sc.d(30)),
                              maxLength: 1,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                counterText: "",
                                contentPadding: EdgeInsets.symmetric(vertical: sc.d(12)),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: mTextField, width: sc.d(2)),
                                  borderRadius: BorderRadius.all(Radius.circular(sc.d(5))),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(sc.d(5))),
                                ),
                                fillColor: mTextField,
                                filled: true,
                              ),
                              cursorColor: mFontMain,
                              onChanged: (value) {
                                controller.onValueChanged(value, index);
                              },
                              onEditingComplete: () {
                                controller.onBackspace(controller.textControllers[index].text, index);
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: sc.d(370)),
                    child: ConfirmButton(
                      text: '인증하기',
                      id: id,
                      isJoin: isJoin,
                    ),
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

class VerificationController extends GetxController {
  final textControllers = List<TextEditingController>.generate(
      5, (index) => TextEditingController()).obs;
  final focusNodes = List<FocusNode>.generate(5, (index) => FocusNode()).obs;

  void onValueChanged(String value, int index) {
    if (value.isNotEmpty && index < 4) {
      FocusScope.of(Get.context!).requestFocus(focusNodes[index + 1]);
    }

    if (index == 4 && value.isNotEmpty) {
      focusNodes[index].unfocus();
    }
  }

  void onBackspace(String value, int index) {
    if (value.isEmpty && index > 0) {
      FocusScope.of(Get.context!).requestFocus(focusNodes[index - 1]);
    }
  }
}

class ConfirmButton extends StatelessWidget {
  final String text;
  final String id;
  final bool isJoin;

  const ConfirmButton(
      {super.key, required this.text, required this.id, required this.isJoin});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VerificationController());
    return AuthButton(
      text: text,
      color: mBtnActive,
      fontFamily: 'mainFont',
      onTap: () {
        verificationService(controller.textControllers.map((e) => e.text).join(), id, isJoin);
      },
    );
  }
}
