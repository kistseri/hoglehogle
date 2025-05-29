import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> versionDialog(String platform) async{
  await Get.defaultDialog(
    title: '버전 불일치',
    middleText: '최신 버전으로 업데이트 하시겠습니까?',
    textConfirm: '확인',
    buttonColor: primaryColor,
    textCancel: '취소',
    barrierDismissible: false,
    onConfirm: () async {
      // 앱 스토어 URL 설정
      String url = '';
      if (platform == "AOS") {
        url =
            'https://play.google.com/store/apps/details?id=com.hohoedu.hoglehogle';
      } else if (platform == "IOS") {
        url = 'https://apps.apple.com/app/id6738404467';
      }

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar('오류', '스토어로 이동할 수 없습니다.');
      }
      SystemNavigator.pop();
    },
    onCancel: () {
      SystemNavigator.pop();
    },
  );
}
