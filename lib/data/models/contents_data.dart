import 'package:get/get.dart';

class ContentsData {
  final String result;
  final String phase;
  final String code;
  final String contentName;
  final bool lock;
  final int openPage;

  ContentsData({
    required this.result,
    required this.phase,
    required this.code,
    required this.contentName,
    required this.lock,
    required this.openPage,
  });

  ContentsData.fromJson(Map<String, dynamic> json)
      : result = json["result"],
        phase = json["phase"],
        code = json["code"],
        contentName = json["contentsName"],
        lock = json["lock"] == "Y",
        openPage = json["openpage"];
}

class ContentsDataController extends GetxController {
  List<ContentsData> _contentsDataList = <ContentsData>[].obs;

  void setContentsDataList(List<ContentsData> contentsDataList) {
    _contentsDataList = contentsDataList;
    update();
  }

  List<ContentsData> get contentsDataList => _contentsDataList;
}
