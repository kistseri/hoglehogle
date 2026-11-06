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
import 'package:hoho_hanja/utils/design_scale.dart';
import 'package:get/get.dart';

Future<dynamic> failDialog(title, description) {
  return showDialog<void>(
    context: Get.context!,
    barrierDismissible: false, // 외부 터치로 다이얼로그가 닫히지 않도록 설정
    builder: (BuildContext context) {
      Future.delayed(const Duration(seconds: 3), () {
        if (!context.mounted) return;
        // 이미 닫혔으면 그대로, 그사이 위에 다른 화면이 열렸으면 그 화면 말고 이 창만 닫음
        final route = ModalRoute.of(context);
        if (route == null || !route.isActive) return;
        if (route.isCurrent) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).removeRoute(route);
        }
      });
      // 다른 화면과 같은 배율 하나로 글자 크기 (ScreenUtil 대신, C-34)
      final sc = DesignScale.fromContext(context);
      return AlertDialog(
        title: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: sc.d(18),
            ),
          ),
        ),
        content: Text(
          description,
          style: TextStyle(fontSize: sc.d(16)),
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          Center(
            child: TextButton(
              // 제목·내용처럼 화면 크기에 맞춤 (태블릿에서 너무 작게 보이지 않도록)
              child: Text(
                "확인",
                style: TextStyle(color: Colors.red, fontSize: sc.d(15)),
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
