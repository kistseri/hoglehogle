import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> versionDialog(String platform) async {
  // iOS는 SystemNavigator.pop()으로 앱이 종료되지 않아 '취소'를 누르면 업데이트 없이 그대로 쓸 수 있었음.
  // iOS는 취소 버튼 없이 창을 유지해 스토어 이동만 할 수 있게 함 (C-31)
  final isIos = platform == "IOS";

  await Get.defaultDialog(
    title: '버전 불일치',
    middleText: '최신 버전으로 업데이트 하시겠습니까?',
    textConfirm: '확인',
    buttonColor: primaryColor,
    textCancel: isIos ? null : '취소',
    barrierDismissible: false,
    onWillPop: () async => false,
    onConfirm: () async {
      // 앱 스토어 URL 설정
      String url = '';
      if (platform == "AOS") {
        url =
            'https://play.google.com/store/apps/details?id=com.hohoedu.hoglehogle';
      } else if (isIos) {
        url = 'https://apps.apple.com/app/id6738404467';
      }

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('오류', '스토어로 이동할 수 없습니다.');
      }
      if (!isIos) SystemNavigator.pop();
    },
    onCancel: isIos
        ? null
        : () {
            SystemNavigator.pop();
          },
  );
}
