import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

void showNoticeDialog(String title, String message,
    {VoidCallback? onDoNotShowAgain}) {
  bool doNotShow = false;

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
            // const SizedBox(height: 16),
            // Row(
            //   mainAxisSize: MainAxisSize.min,
            //   children: [
            //     Checkbox(
            //       value: doNotShow,
            //       onChanged: (value) {
            //         setState(() {
            //           doNotShow = value ?? false;
            //         });
            //       },
            //     ),
            //     const Text("다시 보지 않기"),
            //   ],
            // ),
          ],
        );
      },
    ),
    textConfirm: '확인',
    buttonColor: primaryColor,
    onConfirm: () {
      // if (doNotShow && onDoNotShowAgain != null) {
      //   onDoNotShowAgain();
      // }
      Get.back();
    },
    barrierDismissible: true,
  );
}
