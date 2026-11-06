import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:flutter/material.dart';

// onDoNotShowAgain: '다시 보지 않기'용 (지금은 체크박스를 쓰지 않아 호출되지 않음)
void showNoticeDialog(String title, String message,
    {VoidCallback? onDoNotShowAgain}) {

  Get.defaultDialog(
    title: title,
    content: StatefulBuilder(
      builder: (context, setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
            ),
          ],
        );
      },
    ),
    textConfirm: '확인',
    buttonColor: primaryColor,
    onConfirm: () {
      Get.back();
    },
    barrierDismissible: true,
  );
}
