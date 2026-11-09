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

// 지금 떠 있는 안내창 (화면에는 항상 1개만)
Route<dynamic>? _currentRoute;
String? _currentKey;
Future<void>? _currentFuture;

/// 안내창 (가운데, 바깥 터치로 안 닫히고 3초 뒤 저절로 닫힘)
/// 여러 번 불려도 쌓이지 않음: 같은 내용이 떠 있으면 그대로 두고, 다른 내용이면 이전 창을 새 창으로 바꿈
/// (예전 스낵바처럼 알림이 줄줄이 올라오지 않도록)
Future<dynamic> failDialog(title, description) {
  final key = '$title\n$description';
  final old = _currentRoute;
  if (old != null && old.isActive) {
    if (key == _currentKey) return _currentFuture!;
    old.navigator?.removeRoute(old);
  }
  // showDialog 대신 창을 직접 만들어 띄움: 같은 순간에 두 번 불려도 바로 위 검사에 걸리도록 띄우기 전에 기억
  final appContext = Get.context!;
  final navigator = Navigator.of(appContext, rootNavigator: true);
  final route = DialogRoute<void>(
    context: appContext,
    themes: InheritedTheme.capture(from: appContext, to: navigator.context),
    barrierDismissible: false, // 외부 터치로 다이얼로그가 닫히지 않도록 설정 (뒤 화면 터치도 막힘)
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
  _currentRoute = route;
  _currentKey = key;
  return _currentFuture = navigator.push(route);
}
