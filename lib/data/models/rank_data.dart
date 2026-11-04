import 'package:get/get.dart';

class RankData {
  final String result;
  final String id;
  final int totalPoints;
  final String nickName;
  final String? hatImage;
  final String? clothesImage;
  final String? eyeImage;
  final String? backgroundImage;
  final String? characterImage;

  RankData({
    required this.result,
    required this.id,
    required this.totalPoints,
    required this.nickName,
    this.hatImage,
    this.clothesImage,
    this.eyeImage,
    this.backgroundImage,
    this.characterImage,
  });

  // 서버가 값을 빼거나(null) 숫자·문자열을 섞어 보내도 한 사람 때문에 랭킹 전체가 깨지지 않게
  RankData.fromJson(Map<String, dynamic> json)
      : result = json["result"]?.toString() ?? '',
        id = json["id"]?.toString() ?? '',
        totalPoints = _toInt(json["total_points"]),
        nickName = json["nickname"]?.toString() ?? '',
        clothesImage = json["category10_item_img"]?.toString(),
        hatImage = json["category20_item_img"]?.toString(),
        eyeImage = json["category30_item_img"]?.toString(),
        backgroundImage = json["category40_item_img"]?.toString(),
        characterImage = json["character_img"]?.toString();

  static int _toInt(dynamic v) {
    if (v is num) return v.toInt();
    return int.tryParse(v?.toString().trim() ?? '') ?? 0;
  }
}

enum RankStatus { loading, done, error }

class RankDataController extends GetxController {
  final RxList<RankData> _rankDataList = <RankData>[].obs;
  // 순위 (점수가 같으면 같은 순위: 1, 2, 2, 4 ...)
  final RxList<int> ranks = <int>[].obs;
  final Rx<RankStatus> status = RankStatus.loading.obs;
  String errorMessage = '';

  void setRankData(List<RankData> rankDataList) {
    // 점수 높은 순 (서버 순서가 같으면 그대로 유지)
    final sorted = [...rankDataList];
    sortByPointsDesc(sorted);
    final r = <int>[];
    for (var i = 0; i < sorted.length; i++) {
      r.add(i > 0 && sorted[i].totalPoints == sorted[i - 1].totalPoints ? r[i - 1] : i + 1);
    }
    _rankDataList.assignAll(sorted);
    ranks.assignAll(r);
    status.value = RankStatus.done;
  }

  void setLoading() {
    // 이미 보여주는 랭킹이 있으면 새로 받는 동안에도 그대로 보여줌
    if (_rankDataList.isEmpty) status.value = RankStatus.loading;
  }

  void setError(String message) {
    errorMessage = message;
    // 이미 보여주는 랭킹이 있으면 그대로 두고, 없을 때만 오류 화면
    if (_rankDataList.isEmpty) status.value = RankStatus.error;
  }

  List<RankData> get rankDataList => _rankDataList;

  // 점수가 같을 때 서버 순서를 지키는 정렬 (List.sort는 순서 유지를 보장하지 않음)
  static void sortByPointsDesc(List<RankData> list) {
    final indexed = List.generate(list.length, (i) => MapEntry(i, list[i]));
    indexed.sort((a, b) {
      final c = b.value.totalPoints.compareTo(a.value.totalPoints);
      return c != 0 ? c : a.key.compareTo(b.key);
    });
    for (var i = 0; i < list.length; i++) {
      list[i] = indexed[i].value;
    }
  }
}
