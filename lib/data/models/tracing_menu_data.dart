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
      : phase = json["phase"]?.toString() ?? '',
        gubun = json["gubun"]?.toString() ?? '',
        subject = json["subject"]?.toString() ?? '',
        hanja = (json["hanja_list"]?.toString() ?? '').replaceAll(',', ' ');
}

class TracingMenuDataController extends GetxController {
  List<TracingMenuData> _tracingMenuDataList = <TracingMenuData>[].obs;

  void setTracingMenuData(List<TracingMenuData> tracingMenuDataList) {
    _tracingMenuDataList = tracingMenuDataList;

    update();
  }

  List<TracingMenuData>? get tracingMenuDataList => _tracingMenuDataList;
}
