// import 'package:awesome_dialog/awesome_dialog.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// Future<dynamic> failDialog(title, description) {
//   return AwesomeDialog(
//     context: Get.context!,
//     animType: AnimType.scale,
//     dialogType: DialogType.noHeader,
//     autoHide: const Duration(seconds: 3),
//     title: title,
//     dismissOnTouchOutside: false,
//     titleTextStyle:
//         const TextStyle(fontSize: 17, fontFamily: 'NotoSansKR-SemiBold'),
//     desc: description,
//     descTextStyle: const TextStyle(fontSize: 16),
//     btnOkText: "확인",
//     btnOkColor: Colors.red[400],
//     btnOkOnPress: () => Get.back(),
//   ).show();
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

Future<dynamic> failDialog(title, description) {
  return showDialog<void>(
    context: Get.context!,
    barrierDismissible: false, // 외부 터치로 다이얼로그가 닫히지 않도록 설정
    builder: (BuildContext context) {
      Future.delayed(const Duration(seconds: 3), () {
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      });
      return AlertDialog(
        title: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
            ),
          ),
        ),
        content: Text(
          description,
          style: TextStyle(fontSize: 16.sp),
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          Center(
            child: TextButton(
              child: const Text(
                "확인",
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
            ),
          ),
        ],
      );
    },
  );
}
