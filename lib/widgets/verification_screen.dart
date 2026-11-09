import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/screens/auth/auth_widgets/auth_layout.dart';
import 'package:hoho_hanja/utils/design_scale.dart';
import 'package:hoho_hanja/utils/verification.dart';

class Verification extends StatelessWidget {
  final String id;
  final bool isJoin;

  Verification({super.key, required this.id, required this.isJoin});

  final VerificationController controller = Get.put(VerificationController())..reset();

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
                  // 인증번호 5자리: 숨긴 입력칸 하나 + 칸 5개 표시
                  // (붙여넣기·문자 자동완성·백스페이스가 그대로 동작, C-28)
                  Padding(
                    padding: EdgeInsets.only(top: sc.d(32)),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => controller.focusNode.requestFocus(),
                      child: Stack(
                        children: [
                          // 실제 입력 (보이지 않음)
                          Opacity(
                            opacity: 0,
                            child: SizedBox(
                              height: sc.d(64),
                              child: TextField(
                                controller: controller.codeController,
                                focusNode: controller.focusNode,
                                autofocus: true,
                                keyboardType: TextInputType.number,
                                autofillHints: const [AutofillHints.oneTimeCode],
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(VerificationController.codeLength),
                                ],
                                showCursor: false,
                                enableInteractiveSelection: false,
                                decoration: const InputDecoration(counterText: '', border: InputBorder.none),
                                onChanged: (value) {
                                  if (value.length == VerificationController.codeLength) {
                                    controller.focusNode.unfocus();
                                  }
                                },
                              ),
                            ),
                          ),
                          // 보이는 칸 5개
                          IgnorePointer(
                            child: ValueListenableBuilder<TextEditingValue>(
                              valueListenable: controller.codeController,
                              builder: (context, value, _) {
                                final code = value.text;
                                return Row(
                                  children: List.generate(VerificationController.codeLength, (index) {
                                    final isCurrent = index == code.length ||
                                        (index == VerificationController.codeLength - 1 &&
                                            code.length == VerificationController.codeLength);
                                    return Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: sc.d(8)),
                                        child: Container(
                                          height: sc.d(64),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            color: mTextField,
                                            borderRadius: BorderRadius.circular(sc.d(5)),
                                            border: Border.all(
                                              color: isCurrent ? mFontMain : mTextField,
                                              width: sc.d(2),
                                            ),
                                          ),
                                          child: Text(
                                            index < code.length ? code[index] : '',
                                            style: TextStyle(fontSize: sc.d(30), color: mFontMain),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
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
  static const int codeLength = 5;

  final codeController = TextEditingController();
  final focusNode = FocusNode();

  String get code => codeController.text;

  // 인증 화면을 새로 열 때 이전에 입력한 번호 지우기
  void reset() => codeController.clear();

  @override
  void onClose() {
    codeController.dispose();
    focusNode.dispose();
    super.onClose();
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
      onTap: () => verificationService(controller.code, id, isJoin),
    );
  }
}
