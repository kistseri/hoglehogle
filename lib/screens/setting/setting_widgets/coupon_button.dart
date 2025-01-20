import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/size.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/data/models/setting_data.dart';
import 'package:hoho_hanja/widgets/dialog/coupon_dialog.dart';
import 'package:logger/logger.dart';
import 'package:url_launcher/url_launcher.dart';

class CouponButton extends StatefulWidget {
  const CouponButton({super.key});

  @override
  State<CouponButton> createState() => _CouponButtonState();
}

class _CouponButtonState extends State<CouponButton> {
  final SettingDataController settingController = Get.find<SettingDataController>();
  final LoginDataController loginDataController =
      Get.find<LoginDataController>();

  @override
  Widget build(BuildContext context) {
    final bool isAos = Theme.of(context).platform == TargetPlatform.android;
    final id = loginDataController.loginData.value!.id;
    final couponText = settingController.isVisible.value;
    final isCouponInsert = couponText == 'Y' ? false : true;

    return isAos
        ? GestureDetector(
            onTap: () {
              setState(() {
                showCouponDialog(context);
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF9AC4C9),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(gapHalf),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.confirmation_number_outlined,
                          color: mFontWhite),
                      Text(
                        '쿠폰번호 입력',
                        style: TextStyle(
                          color: mFontWhite,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : GestureDetector(
            onTap: () async {
              // 기본 URL 설정
              Uri url;
              if (isCouponInsert) {
                url = Uri.parse(
                    "http://ststallpass.cafe24.com/coupon?username=$id");
              } else {
                // 기본 URL
                url = Uri.parse("https://hohoedu.co.kr");
              }
              // URL 브라우저에서 열기
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                throw "Could not launch $url";
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF9AC4C9),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(gapHalf),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isCouponInsert)
                        Icon(Icons.confirmation_number_outlined,
                            color: mFontWhite),
                      Text(
                        isCouponInsert ? '쿠폰 입력하기' : '홈페이지 바로가기',
                        style: TextStyle(
                          color: mFontWhite,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
