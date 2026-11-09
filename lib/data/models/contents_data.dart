import 'package:get/get.dart';
import 'package:hoho_hanja/data/models/json_parse.dart';

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
      // 서버 값 타입이 바뀌어도 TypeError 없이 받음 (C-37)
      : result = jsonStr(json["result"]),
        phase = jsonStr(json["phase"]),
        code = jsonStr(json["code"]),
        contentName = jsonStr(json["contentsName"]),
        lock = jsonStr(json["lock"]).trim().toUpperCase() == "Y",
        openPage = jsonInt(json["openpage"]);
}

class ContentsDataController extends GetxController {
  List<ContentsData> _contentsDataList = <ContentsData>[]; // 화면이 값을 지켜보지 않고 열기 전에 넣으므로 일반 List + update() (C-38)

  // 받은 급수 것만 바꾸고 다른 급수 것은 그대로 둠
  // (급수를 빨리 바꿔 이전 급수 응답이 늦게 와도 지금 급수 정보를 지우지 않도록)
  void setContentsDataList(List<ContentsData> contentsDataList) {
    final phases = contentsDataList.map((c) => c.phase).toSet();
    _contentsDataList = [
      ..._contentsDataList.where((c) => !phases.contains(c.phase)),
      ...contentsDataList,
    ];
    update();
  }

  // 로그아웃·탈퇴 때 (다음 계정이 이전 계정의 잠금 정보로 콘텐츠에 들어가지 않도록)
  void clear() {
    _contentsDataList = [];
    update();
  }

  List<ContentsData> get contentsDataList => _contentsDataList;
}
