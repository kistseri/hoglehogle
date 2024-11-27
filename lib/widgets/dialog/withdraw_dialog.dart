import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/screens/auth/login/social_login_screen.dart';
import 'package:hoho_hanja/services/auth/withdraw_service.dart';

void showWithdrawDialog() {
  Get.defaultDialog(
    title: '회원 탈퇴',
    middleText: '모든 정보가 삭제되고 복구할 수 없습니다.\n정말로 탈퇴하시겠습니까?',
    textConfirm: '탈퇴',
    buttonColor: Colors.red,
    textCancel: '취소',
    onConfirm: () async {
      await withdrawService();
    },
    onCancel: () {
      Get.back();
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
