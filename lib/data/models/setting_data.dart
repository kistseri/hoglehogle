import 'package:get/get.dart';
import 'package:hoho_hanja/data/models/json_parse.dart';

class SettingData {
  final String yn;

  SettingData({
    required this.yn,
  });

  SettingData.fromJson(Map<String, dynamic> json) : yn = jsonStr(json['yn']);
}

class SettingDataController extends GetxController {
  var isVisible = "".obs;

  void settinData(String yn) {
    isVisible.value = yn;
  }

}
