import 'package:get/get.dart';

class SettingData {
  final String yn;

  SettingData({
    required this.yn,
  });

  SettingData.fromJson(Map<String, dynamic> json) : yn = json['yn'];
}

class SettingDataController extends GetxController {
  var isVisible = "".obs;

  void settinData(String yn) {
    isVisible.value = yn;
  }

}
