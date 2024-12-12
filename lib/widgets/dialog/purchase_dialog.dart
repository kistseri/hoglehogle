import 'package:flutter/material.dart';
import 'package:get/get.dart';

void purchaseDialog(context) {
  showGeneralDialog(
    context: context,
    pageBuilder: (context, animation, secondaryAnimation) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Container(),
      );
    },
  );
}
