import 'package:get/get.dart';

class JoinData {
  final String result;

  JoinData({
    required this.result,
  });

  factory JoinData.fromJson(Map<String, dynamic> json) {
    return JoinData(
      result: json['result'] ?? "",
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
