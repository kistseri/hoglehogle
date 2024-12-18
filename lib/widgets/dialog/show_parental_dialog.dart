import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:logger/logger.dart';

void showParentalDialog(String problem, dynamic solution, Function onSuccess) {
  final TextEditingController answerController = TextEditingController();
  Logger().d('problem = $problem');
  Logger().d('solution = $solution');
  Get.defaultDialog(
      title: "자녀 결제 보호",
      content: Column(
        children: [
          Text(
            problem,
            style: TextStyle(
              color: mFontMain,
              fontSize: 14.sp,
            ),
          ),
          TextField(
            controller: answerController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: '정답을 입력해주세요.',
              hintStyle: const TextStyle(color: mFontSub),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: mTextField, width: 2.w),
                borderRadius: BorderRadius.all(Radius.circular(50.r)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: mBoxYellow, width: 2.sp),
                borderRadius: BorderRadius.all(Radius.circular(50.r)),
              ),
              fillColor: mTextField,
            ),
            cursorColor: mFontMain,
          ),
        ],
      ),
      barrierDismissible: false,
      textCancel: '취소',
      textConfirm: '확인',
      onCancel: () {
        Get.back();
      },
      buttonColor: primaryColor,
      onConfirm: () {
        if (answerController.text.trim() == solution.toString()) {
          onSuccess();
          Get.back();
        } else {
          Get.snackbar(
            '오답',
            '다시 확인해주세요',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      });
}
