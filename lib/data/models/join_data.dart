import 'package:get/get.dart';
import 'package:hoho_hanja/data/models/json_parse.dart';

class JoinData {
  final String result;

  JoinData({
    required this.result,
  });

  factory JoinData.fromJson(Map<String, dynamic> json) {
    return JoinData(
      result: jsonStr(json['result']),
    );
  }
}

class JoinDataController extends GetxController {
  JoinData? _joinData;

  void setJoinData(JoinData joinData) {
    _joinData = joinData;
    update();
  }

  JoinData? get joinData => _joinData;
}
