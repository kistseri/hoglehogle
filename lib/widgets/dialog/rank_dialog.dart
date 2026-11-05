import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/utils/design_scale.dart';

/// 랭킹 기준 안내 팝업
///
/// 크기·글자·여백을 모두 시안(360 폭) 단위로 정하고 랭킹 화면과 같은 배율로 키우거나 줄임.
/// 그래서 작은 폰·큰 폰·태블릿에서 화면 대비 비율이 같게 보임.
void showRankDialog(String title, String message) {
  Get.generalDialog(
    barrierDismissible: true,
    barrierLabel: '',
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, anim1, anim2) {
      final mq = MediaQuery.of(context);
      final sc = DesignScale.of(mq.size, mq.padding);
      double d(num v) => sc.d(v);
      // 화면 높이에서 상태바·하단바를 뺀 높이 (안내문이 길면 이 안에서 스크롤)
      final availH = mq.size.height - mq.padding.top - mq.padding.bottom;

      return SafeArea(
        child: Align(
          alignment: const Alignment(0, -0.3), // 가운데보다 조금 위
          child: Material(
            color: Colors.transparent,
            child: Container(
              // 시안 폭 360 중 324 (태블릿처럼 넓어도 화면 폭을 넘지 않게)
              width: math.min(d(324), mq.size.width - d(16)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(d(36)),
              ),
              padding: EdgeInsets.fromLTRB(d(22), d(28), d(22), d(18)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 제목
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: d(20), color: mFontMain),
                    textAlign: TextAlign.center,
                  ),
                  // 안내문
                  Padding(
                    padding: EdgeInsets.fromLTRB(d(4), d(18), d(4), d(24)),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: availH * 0.5),
                      child: SingleChildScrollView(
                        child: Text(
                          message,
                          textAlign: TextAlign.start,
                          style: TextStyle(fontSize: d(13.5), height: 1.5, color: mFontMain),
                        ),
                      ),
                    ),
                  ),
                  // 닫기 버튼
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: double.infinity,
                      height: d(44),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(d(22)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '닫기',
                        style: TextStyle(color: Colors.white, fontSize: d(15), fontWeight: FontWeight.bold),
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
