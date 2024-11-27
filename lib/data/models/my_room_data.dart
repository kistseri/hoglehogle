import 'package:get/get.dart';

class MyroomData {
  final int itemId;
  final String categoryId;
  final String item;
  final int coin;
  final String useyn;

  MyroomData({
    required this.itemId,
    required this.categoryId,
    required this.item,
    required this.coin,
    required this.useyn,
  });

  MyroomData.fromJson(Map<String, dynamic> json)
      : itemId = json["itemid"],
        categoryId = json["categoryId"],
        item = json["itemimg"],
        coin = json["coin"],
        useyn = json["useyn"];
}

class MyroomDataController extends GetxController {
  final RxList<MyroomData> _myroomDataList = <MyroomData>[].obs;
  final RxMap<String, List<MyroomData>> myroomDataByCategory =
      <String, List<MyroomData>>{}.obs;

  void setMyroomData(List<MyroomData> myroomDataList) {
    _myroomDataList.assignAll(myroomDataList);
    _categorizeDataByCategory();
  }

  List<MyroomData>? get myroomDataList => _myroomDataList;

  void _categorizeDataByCategory() {
    myroomDataByCategory.clear();
    for (var data in _myroomDataList) {
      myroomDataByCategory.putIfAbsent(data.categoryId, () => []).add(data);
    }
  }

  List<MyroomData> getDataByCategory(String categoryId) {
    return myroomDataByCategory[categoryId] ?? [];
  }
}
