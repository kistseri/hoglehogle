import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/constants.dart';
import 'package:hoho_hanja/screens/home/home_screen.dart';
import 'package:hoho_hanja/services/auth/my_goods_service.dart';
import 'package:lottie/lottie.dart';

Widget buildIcon(
    IconData icon, Color color, double size, double top, double left,
    {double? right}) {
  return Positioned(
    top: top,
    left: left,
    right: right,
    child: Icon(
      icon,
      color: color,
      size: size.sp,
    ),
  );
}

void resultDialog(
    BuildContext context, int correctAnswers, int totalQuestions, String coin) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    transitionDuration: Duration(milliseconds: 300),
    // 애니메이션 시간 조정
    pageBuilder: (BuildContext buildContext, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            for (var icon in iconData)
              buildIcon(
                icon['icon'],
                icon['color'],
                icon['size'],
                icon['top'],
                icon['left'],
              ),
            Positioned(
              child: Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0.sp)),
                backgroundColor: mBoxBeige,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        right: -40.w,
                        top: 100.h,
                        child: Lottie.asset(
                          'assets/lottie/star_animation.json',
                          height: 150.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                      // 별 이미지 위치
                      Positioned(
                        right: 95.0.w,
                        top: -50.0.h,
                        child: SizedBox(
                            width: 100,
                            height: 100,
                            child: Image.asset('assets/images/icon/star.png')),
                      ),
                      // 중앙의 텍스트 및 이미지
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(16.0.sp),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '$correctAnswers',
                                      style: TextStyle(
                                        color: Color(0xFFFF7E00),
                                        fontSize: 30.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '/$totalQuestions',
                                      style: TextStyle(
                                        color: Color(0xFFB4A784),
                                        fontSize: 30.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              padding: EdgeInsets.all(20),
                              child: Container(
                                width: 150.0,
                                height: 150.0,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        child: Image.asset(
                                          'assets/images/icon/coin.png',
                                        ),
                                      ),
                                      Text(
                                        coin,
                                        style: TextStyle(
                                            fontSize: 24.sp,
                                            color: Colors.brown,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(16.0.sp),
                              child: GestureDetector(
                                onTap: () async {
                                  await myGoodsService();
                                  Get.offAll(() => const HomeScreen());
                                },
                                child: Container(
                                  height: 40.0.h,
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFEBE30),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Center(
                                    child: Text(
                                      '메인으로',
                                      style: TextStyle(
                                          color: mFontWhite,
                                          fontSize: 16.0.sp,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
