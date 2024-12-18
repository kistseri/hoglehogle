import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/size.dart';
import 'package:hoho_hanja/utils/verification.dart';

class Verification extends StatelessWidget {
  final String id;
  final bool isJoin;

  Verification({super.key, required this.id, required this.isJoin});

  final VerificationController controller = Get.put(VerificationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mBackWhite,
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(gapHalf),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(gapHalf),
                  child: Center(
                    child: Text(
                      '휴대폰으로 발송된\n인증번호를 입력해 주세요',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: mFontMain,
                          fontSize: fontHuge,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height: gapMain),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return Expanded(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: gapQuarter),
                        child: Obx(() => TextField(
                              controller: controller.textControllers[index],
                              // TextEditingController(
                              //     text: controller.code[index]),
                              focusNode: controller.focusNodes[index],
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 30.sp),
                              maxLength: 1,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                counterText: "",
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: mTextField, width: 2),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0.r)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0.r)),
                                ),
                                fillColor: mTextField,
                                filled: true,
                              ),
                              cursorColor: mFontMain,
                              onChanged: (value) {
                                controller.onValueChanged(value, index);
                              },
                              onEditingComplete: () {
                                controller.onBackspace(
                                    controller.textControllers[index].text,
                                    index);
                              },
                            )),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 350.r),
                SizedBox(height: gapMediumSmall),
                ConfirmButton(
                  text: '인증하기',
                  id: id,
                  isJoin: isJoin,
                )
              ],
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
    return GestureDetector(
      onTap: () {
        verificationService(
            controller.textControllers.map((e) => e.text).join(), id, isJoin);
      },
      child: Container(
        width: double.infinity,
        height: 50.h,
        decoration: BoxDecoration(
          color: mBtnActive,
          borderRadius: BorderRadius.circular(50.r),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
                color: Colors.white, fontSize: 18.sp, fontFamily: 'mainFont'),
          ),
        ),
      ),
    );
  }
}
