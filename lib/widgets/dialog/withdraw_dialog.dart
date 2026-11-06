import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/screens/auth/login/social_login_screen.dart';
import 'package:hoho_hanja/services/auth/withdraw_service.dart';
import 'package:hoho_hanja/utils/design_scale.dart';
import 'package:hoho_hanja/widgets/dialog/math_gate_dialog.dart';

/// 회원 탈퇴 확인 → 계산 문제 → 탈퇴
/// 크기는 시안 단위, 화면 배율대로 (작은 폰·태블릿에서도 같은 비율)
void showWithdrawDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) {
      final sc = DesignScale.fromContext(ctx);
      double d(num v) => sc.d(v);

      Widget button(String text, Color color, VoidCallback onTap, {double left = 0}) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: left),
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                height: d(42),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(d(10))),
                child: Text(text, style: TextStyle(color: mFontWhite, fontSize: d(15))),
              ),
            ),
          ),
        );
      }

      return Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: d(8), vertical: d(24)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(d(20))),
        child: SizedBox(
          width: min(d(300), MediaQuery.sizeOf(ctx).width - d(16)),
          child: Padding(
            padding: EdgeInsets.fromLTRB(d(20), d(22), d(20), d(18)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('회원 탈퇴', style: TextStyle(color: mFontMain, fontSize: d(20), fontWeight: FontWeight.bold)),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: d(16)),
                  child: Text(
                    '모든 정보가 삭제되고 복구할 수 없습니다.\n정말로 탈퇴하시겠습니까?',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: mFontSub, fontSize: d(14), height: 1.5),
                  ),
                ),
                Row(
                  children: [
                    button('탈퇴', Colors.red, () {
                      // 이 창을 닫고 계산 문제로 (창이 겹쳐 남지 않게)
                      Navigator.of(ctx).pop();
                      showDeleteProtectDialog(context, () => withdrawService());
                    }),
                    // 취소는 이 창만 닫음
                    button('취소', mBtnBack, () => Navigator.of(ctx).pop(), left: d(10)),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

void withdrawDialog() {
  Get.defaultDialog(
    title: '알림',
    middleText: '계정이 삭제되었습니다.',
  );
  Future.delayed(
    const Duration(seconds: 2),
    () {
      Get.offAll(() => const LoginScreen());
    },
  );
}

/// 탈퇴 전 계산 문제 확인 (공용 계산 문제 창 사용)
void showDeleteProtectDialog(BuildContext context, Future<void> Function() onDeleteConfirmed) {
  if (!context.mounted) return;
  showMathGateDialog(context, title: '탈퇴 확인', onPassed: onDeleteConfirmed);
}
