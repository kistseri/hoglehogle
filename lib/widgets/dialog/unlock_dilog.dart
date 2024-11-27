import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/utils/contents_lock.dart';

void showUnlockDialog(phase) {
  Get.defaultDialog(
    title: '컨텐츠 잠금',
    middleText: '잠금을 해제하시겠습니까?',
    textConfirm: '잠금 해제',
    buttonColor: primaryColor,
    textCancel: '취소',
    onConfirm: () async {
      await contentsUnlock(phase);
      Get.back();
    },
    onCancel: () {
      Get.back();
    },
  );
}

void unlockDialog(String title, String content) async {
  List<String> splitContent =
      content.split(RegExp(r'[.,]')).map((s) => s.trim()).toList();
  Get.defaultDialog(
    title: title,
    middleText: '${splitContent[0]}\n${splitContent[1]}\n${splitContent[2]}',
    middleTextStyle: const TextStyle(),
  );
  Future.delayed(
    const Duration(seconds: 3),
    () {
      Get.back();
    },
  );
}
