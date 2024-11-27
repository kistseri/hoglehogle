import 'package:get/get.dart';

class TracingData {
  final String ilno;
  final String note;
  final String svg;

  TracingData({
    required this.ilno,
    required this.note,
    required this.svg,
  });

  TracingData.fromJson(Map<String, dynamic> json)
      : ilno = json["ilno"],
        note = json["note"],
        svg = json["itemimg"];
}

class TracingDataController extends GetxController {
  List<TracingData> _tracingDataList = <TracingData>[].obs;

  void setTracingData(List<TracingData> tracingDataList) {
    _tracingDataList = tracingDataList;
    update();
  }

  List<TracingData>? get tracingDataList => _tracingDataList;
}
