import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/data/models/login_data.dart';

class HomeHeader extends StatelessWidget {
  final loginController = Get.put(LoginDataController(), permanent: true);

  HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10.h,
      left: 0,
      child: Container(
        height: 120.h,
        width: MediaQuery.of(context).size.width * 0.8,
        decoration: BoxDecoration(
          color: mBoxYellow,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40.r),
            topRight: Radius.circular(40.r),
            bottomRight: Radius.circular(40.r),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      // username
                      text: loginController.loginData.value!.nickName,
                      style: TextStyle(
                        color: mFontMain,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '님 안녕하세요!',
                      style: TextStyle(color: mFontMain, fontSize: 17.sp),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  text: '오늘은 어떤 한자를 배울까요?',
                  style: TextStyle(
                    color: mFontMain,
                    fontSize: 17.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
