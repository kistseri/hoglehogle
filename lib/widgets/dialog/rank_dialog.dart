import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

void showRankDialog(String title, String message) {
  Get.generalDialog(
    barrierDismissible: true,
    barrierLabel: '',
    transitionDuration: Duration(milliseconds: 200),
    pageBuilder: (context, anim1, anim2) {
      return SafeArea(
        // Align으로 전체 화면 안에서 위치 지정
        child: Align(
          alignment: Alignment(0, -0.3), // Y축 음수 → 위쪽
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: Get.width * 0.9,
              // 모서리 둥글게, 배경 흰색
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              padding: EdgeInsets.only(
                top: 32,
                left: 24,
                right: 24,
                bottom: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 제목
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  // 메시지
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: Get.height * 0.5,
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          message,
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  // 닫기 버튼
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '닫기',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return FadeTransition(opacity: anim1, child: child);
    },
  );
}