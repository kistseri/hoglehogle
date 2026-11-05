import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/data/models/setting_data.dart';
import 'package:hoho_hanja/screens/setting/setting_widgets/setting_button.dart';
import 'package:hoho_hanja/utils/design_scale.dart';
import 'package:hoho_hanja/widgets/dialog/coupon_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

class CouponButton extends StatelessWidget {
  final DesignScale scale;

  const CouponButton({super.key, required this.scale});

  @override
  Widget build(BuildContext context) {
    final isAos = Theme.of(context).platform == TargetPlatform.android;
    final settingController = Get.isRegistered<SettingDataController>()
        ? Get.find<SettingDataController>()
        : Get.put(SettingDataController());
    return Obx(() {
      // 안드로이드는 늘 쿠폰 입력, iOS는 심사가 끝난 뒤('N')에만 쿠폰 입력 (그 전엔 홈페이지)
      final yn = settingController.isVisible.value; // Obx가 이 값을 지켜보도록 먼저 읽음
      final isCouponInsert = isAos || yn == 'N';
      return SettingButton(
        scale: scale,
        color: const Color(0xFF9AC4C9),
        icon: isCouponInsert ? Icons.confirmation_number_outlined : null,
        text: isCouponInsert ? '쿠폰 입력하기' : '홈페이지 바로가기',
        onTap: () async {
          if (isCouponInsert) {
            showCouponDialog(context);
            return;
          }
          final url = Uri.parse("https://hohoedu.co.kr");
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          }
        },
      );
    });
  }
}
