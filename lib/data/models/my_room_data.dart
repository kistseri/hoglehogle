import 'package:get/get.dart';

int _toInt(dynamic v) => v is int ? v : int.tryParse('${v ?? ''}'.trim()) ?? 0;

class MyroomData {
  final int itemId;
  final String categoryId;
  final String item; // 그림 URL
  final int coin; // 가격
  final String useyn; // 'Y' = 가진 아이템

  MyroomData({
    required this.itemId,
    required this.categoryId,
    required this.item,
    required this.coin,
    required this.useyn,
  });

  bool get isOwned => useyn == 'Y';

  // 숫자가 문자열로 오거나 값이 비어도 받음 (한 개가 이상해서 옷장 전체가 비지 않도록)
  MyroomData.fromJson(Map<String, dynamic> json)
      : itemId = _toInt(json["itemid"]),
        categoryId = '${json["categoryId"] ?? ''}'.trim(),
        item = json["itemimg"]?.toString() ?? '',
        coin = _toInt(json["coin"]),
        useyn = '${json["useyn"] ?? ''}'.trim().toUpperCase();
}

enum MyroomStatus { loading, done, error }

class MyroomDataController extends GetxController {
  // 탭 순서: 옷, 모자, 액세서리, 배경
  static const categoryIds = ['10', '20', '30', '40'];

  final RxList<MyroomData> _myroomDataList = <MyroomData>[].obs;
  final RxMap<String, List<MyroomData>> myroomDataByCategory = <String, List<MyroomData>>{}.obs;
  final Rx<MyroomStatus> status = MyroomStatus.loading.obs;

  // 이 옷장이 누구 것인지 (다른 계정으로 들어오면 이전 옷장을 비움)
  String? _userId;

  void resetFor(String userId) {
    if (_userId == userId) return;
    _userId = userId;
    _myroomDataList.clear();
    _categorizeDataByCategory();
    status.value = MyroomStatus.loading;
  }

  void setMyroomData(List<MyroomData> myroomDataList) {
    _myroomDataList.assignAll(myroomDataList);
    _categorizeDataByCategory();
    status.value = MyroomStatus.done;
  }

  // 이미 받은 옷장이 있으면 그대로 보여 주고, 없을 때만 불러오는 중·실패로 표시
  void setLoading() {
    if (_myroomDataList.isEmpty) status.value = MyroomStatus.loading;
  }

  void setError() {
    if (_myroomDataList.isEmpty) status.value = MyroomStatus.error;
  }

  List<MyroomData> get myroomDataList => _myroomDataList;

  void _categorizeDataByCategory() {
    final map = {for (final id in categoryIds) id: <MyroomData>[]};
    for (final data in _myroomDataList) {
      map[data.categoryId]?.add(data);
    }
    myroomDataByCategory.assignAll(map);
  }

  List<MyroomData> getDataByCategory(String categoryId) {
    return myroomDataByCategory[categoryId] ?? [];
  }

  MyroomData? findItem(String categoryId, int itemId) {
    return _myroomDataList.firstWhereOrNull((e) => e.categoryId == categoryId && e.itemId == itemId);
  }
}
