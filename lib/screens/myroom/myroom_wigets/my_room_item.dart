import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/constants.dart';
import 'package:hoho_hanja/_core/style.dart';
import 'package:hoho_hanja/data/models/my_room_data.dart';
import 'package:hoho_hanja/services/myroom/selected_item_service.dart';
import 'package:hoho_hanja/widgets/character_avatar.dart';
import 'package:hoho_hanja/widgets/dialog/buy_item_dialog.dart';

/// 마이룸에서 고른 캐릭터·착용 아이템 (앱바 프로필·랭킹 미리보기도 같이 씀)
///
/// 앱 어디서든 [MyroomItemController.to]로 꺼냄. 다른 컨트롤러가 아직 없어도 만들어지도록
/// 생성할 때 다른 컨트롤러를 찾지 않음.
class MyroomItemController extends GetxController {
  static MyroomItemController get to => Get.isRegistered<MyroomItemController>()
      ? Get.find<MyroomItemController>()
      : Get.put(MyroomItemController(), permanent: true);

  final RxString selectedCategory = MyroomDataController.categoryIds.first.obs;
  final RxInt characterIndex = 0.obs; // characterList 순서
  final RxString clothingImage = ''.obs; // 옷 이미지 URL
  final RxString accessoriesImage = ''.obs; // 안경 이미지 URL
  final RxString backgroundImage = ''.obs; // 배경 이미지 URL
  final RxString hatImage = ''.obs; // 모자 이미지 URL
  final RxMap<String, int?> selectedItems = <String, int?>{}.obs; // 카테고리 → 착용 아이템 id

  // 이 상태가 누구 것인지 (로그아웃 후 다른 계정으로 들어오면 이전 계정의 옷을 지움)
  String? _userId;

  void resetFor(String userId) {
    if (_userId == userId) return;
    _userId = userId;
    selectedCategory.value = MyroomDataController.categoryIds.first;
    characterIndex.value = 0;
    clothingImage.value = '';
    accessoriesImage.value = '';
    backgroundImage.value = '';
    hatImage.value = '';
    selectedItems.clear();
    _dirty = false;
  }

  // 마지막 저장 뒤 바뀐 것이 있는지 (서버에서 받은 착용 상태로 덮어쓰지 않도록, 나갈 때 저장하도록)
  bool _dirty = false;
  bool get hasChanges => _dirty;

  void setSelectedCategory(String categoryId) {
    selectedCategory.value = categoryId;
  }

  // 지금 입고 있는 아이템인지 (배경 포함)
  bool isWorn(MyroomData item) => selectedItems[item.categoryId] == item.itemId;

  // 아이템을 누르면: 가진 것은 바로 입히고, 안 가진 것은 구매 팝업만 (사기 전에는 착용 목록에 넣지 않음)
  void tapItem(MyroomData item) {
    if (item.isOwned) {
      wear(item);
    } else {
      showBuyItemDialog(item);
    }
  }

  void wear(MyroomData item) {
    if (!item.isOwned) return;
    selectedItems[item.categoryId] = item.itemId;
    _setImage(item.categoryId, item.item);
    _dirty = true;
  }

  void _setImage(String categoryId, String url) {
    switch (categoryId) {
      case '10':
        clothingImage.value = url;
      case '20':
        hatImage.value = url;
      case '30':
        accessoriesImage.value = url;
      case '40':
        backgroundImage.value = url;
    }
  }

  void nextCharacter() {
    characterIndex.value = (characterIndex.value + 1) % characterList.length;
    _dirty = true;
  }

  /// 서버에 저장된 착용 상태 반영 (앱 시작 때)
  /// 그사이 사용자가 마이룸에서 바꾼 게 있으면 덮어쓰지 않음.
  void applyItemResponse(Map<String, dynamic> json) {
    if (_dirty) return;
    final charIndex = int.tryParse('${json['char_index'] ?? ''}'.trim()) ?? 0;
    characterIndex.value = CharacterAvatar.safeIndex(charIndex);

    final items = json['items'];
    if (items is! List) return;
    for (final item in items) {
      if (item is! Map) continue;
      final categoryId = '${item['categoryId'] ?? ''}'.trim();
      if (categoryId.isEmpty) continue;
      selectedItems[categoryId] = int.tryParse('${item['itemId'] ?? ''}'.trim());
      _setImage(categoryId, item['itemimg']?.toString() ?? '');
    }
  }

  /// 바뀐 게 있으면 서버에 저장 (마이룸을 나갈 때·앱이 백그라운드로 갈 때)
  Future<void> saveIfChanged() async {
    if (!_dirty) return;
    _dirty = false;
    final items = selectedItems.entries.map((e) => {'categoryId': e.key, 'itemId': e.value}).toList();
    final ok = await selectedItemService(items, characterIndex.value.toString().padLeft(2, '0'));
    if (!ok) _dirty = true; // 다음에 나갈 때 다시 저장
  }
}

/// 아이템 칸 (그리드 한 칸)
class MyroomItem extends StatelessWidget {
  final MyroomData item;
  final bool isWorn;

  const MyroomItem({
    super.key,
    required this.item,
    required this.isWorn,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth; // 칸 크기 기준 (기기와 상관없이 같은 비율)
      final isBackground = item.categoryId == '40';
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF4E9D0),
          borderRadius: BorderRadius.circular(w * 0.08),
          border: Border.all(color: isWorn ? const Color(0xFFEF6363) : Colors.transparent, width: w * 0.02),
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isBackground ? w * 0.04 : w * 0.12,
                  isBackground ? w * 0.04 : w * 0.1,
                  isBackground ? w * 0.04 : w * 0.12,
                  item.isOwned ? (isBackground ? w * 0.04 : w * 0.1) : 0,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(isBackground ? w * 0.05 : 0),
                  child: item.item.startsWith('http')
                      ? CharacterAvatar.network(item.item, isBackground ? BoxFit.cover : BoxFit.contain)
                      : const SizedBox.shrink(),
                ),
              ),
            ),
            // 안 가진 아이템은 가격
            if (!item.isOwned)
              SizedBox(
                height: w * 0.26,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/icon/coin.png', height: w * 0.18),
                    Padding(
                      padding: EdgeInsets.only(left: w * 0.02),
                      child: Text('${item.coin}', style: outlineTextStyle(w * 0.13).copyWith(fontSize: w * 0.13)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}
