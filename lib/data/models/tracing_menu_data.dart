import 'package:get/get.dart';

class TracingMenuData {
  final String phase;
  final String gubun;
  final String subject;
  final String hanja;

  TracingMenuData({
    required this.phase,
    required this.gubun,
    required this.subject,
    required this.hanja,
  });

  TracingMenuData.fromJson(Map<String, dynamic> json)
      : phase = json["phase"],
        gubun = json["gubun"],
        subject = json["subject"],
        hanja = (json["hanja_list"] as String).replaceAll(',', ' ');
}

class TracingMenuDataController extends GetxController {
  List<TracingMenuData> _tracingMenuDataList = <TracingMenuData>[].obs;

  void setTracingMenuData(List<TracingMenuData> tracingMenuDataList) {
    _tracingMenuDataList = tracingMenuDataList;

    update();
  }

  List<TracingMenuData>? get tracingMenuDataList => _tracingMenuDataList;
}
