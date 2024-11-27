import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  RxString themeMode = 'system'.obs;
  RxBool isLightTheme = true.obs;

  //  화면 모드 로드를 로컬 저장소에 저장
  Future<void> changeAndStoreThemeMode(String value) async {
    themeMode.value = value;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('themeMode', value);
  }

  void changeIsLightTheme(bool value) {
    isLightTheme.value = value;
  }
}

void changeSystemMode() {
  final themeController = Get.put(ThemeController());
  Brightness systemBrightness = MediaQuery.of(Get.context!).platformBrightness;

  if (systemBrightness == Brightness.light) {
    themeController.changeIsLightTheme(true);
  } else {
    themeController.changeIsLightTheme(false);
  }
}
