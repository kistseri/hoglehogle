import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hoho_hanja/_core/constants.dart';
import 'package:hoho_hanja/_core/size.dart';
import 'package:hoho_hanja/_core/style.dart';
import 'package:hoho_hanja/data/models/goods_data.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/data/models/my_room_data.dart';
import 'package:hoho_hanja/main.dart';
import 'package:hoho_hanja/widgets/dialog/buy_item_dialog.dart';
import 'package:logger/logger.dart';

class MyroomItemController extends GetxController {
  final MyroomDataController myroomDataController = Get.find<MyroomDataController>();
  final LoginDataController loginDataController = Get.find<LoginDataController>();
  final GoodsDataController goodsDataController = Get.find<GoodsDataController>();

  final RxString selectedCategory = ''.obs;
  final RxInt selectedItem = (-1).obs;
  final RxString clothingImage = ''.obs; // 옷 이미지 URL
  final RxString accessoriesImage = ''.obs; // 안경 이미지 URL
  final RxString backgroundImage = ''.obs; // 배경 이미지 URL
  final RxString hatImage = ''.obs; // 모자 이미지 URL
  var characterImage = characterList[0].obs;
  int currentCharacter = 0;

  final RxDouble characterLeft = 0.0.obs;
  final Rx<Size> clothesSize = Size.fromHeight(70.h).obs;
  final Rx<double> clothesTop = 210.h.obs;
  final Rx<Size> hatSize = Size.fromHeight(70.h).obs;
  final Rx<double> hatTop = 80.h.obs;
  final RxMap<String, int?> selectedItems = <String, int?>{}.obs;

  void updateSelectedItem(String categoryId, int? itemId) {
    selectedItems[categoryId] = itemId;
  }

  void setSelectedCategory(String categoryId) {
    selectedCategory.value = categoryId;
    selectedItem.value = -1;
  }

  void selectItem(int index) {
    selectedItem.value = index;

    var item = myroomDataController.getDataByCategory(selectedCategory.value)[index];

    updateSelectedItem(item.categoryId, item.itemId);

    updateScreenImage(item);
  }

  void updateScreenImage(MyroomData item) {
    if (item.useyn == 'Y') {
      // 옷 이미지를 업데이트
      if (item.categoryId == '10') {
        clothingImage.value = item.item;
      }
      // 모자 이미지를 업데이트
      else if (item.categoryId == '20') {
        hatImage.value = item.item;
      }
      // 안경 이미지를 업데이트
      else if (item.categoryId == '30') {
        accessoriesImage.value = item.item;
      }
      // 배경 이미지를 업데이트
      else if (item.categoryId == '40') {
        backgroundImage.value = item.item;
      }
    } else {
      showBuyItemDialog(item);
    }
  }

  void nextCharacter() {
    currentCharacter = (currentCharacter + 1) % characterList.length;
    characterImage.value = characterList[currentCharacter];
  }

  void applyItemResponse(Map<String, dynamic> json) {
    final charIndex = json['char_index'] ?? '00';
    final items = json['items'] as List;

    currentCharacter = int.tryParse(charIndex) ?? 0;
    characterImage.value = characterList[currentCharacter];
    applyCharacterSettings(currentCharacter);

    for (var item in items) {
      final categoryId = item['categoryId'].toString();
      final itemId = int.tryParse(item['itemId'].toString());
      ;
      final itemImg = item['itemimg'];

      updateSelectedItem(categoryId, itemId);

      switch (categoryId) {
        case '10':
          clothingImage.value = itemImg;
          break;
        case '20':
          hatImage.value = itemImg;
          break;
        case '30':
          accessoriesImage.value = itemImg;
          break;
        case '40':
          backgroundImage.value = itemImg;
          break;
      }
    }
  }

  void applyCharacterSettings(int index) {
    characterLeft.value = characterLeftMap[index] ?? 0.0;
    clothesSize.value = clothesSizeMap[index] ?? Size.fromHeight(70.h);
    clothesTop.value = clothesTopMap[index] ?? 210.h;
    hatSize.value = hatSizeMap[index] ?? Size.fromHeight(40.h);
    hatTop.value = hatTopMap[index] ?? 80.h;
  }

  static final Map<int, double> characterLeftMap = {
    0: 0.0, // 호랑이
    1: 0.0, // 토끼
    2: 0.0, // 곰
    3: screenHeight >= 1000 ? 40.w : 55.w, // 다람쥐
  };

  static final Map<int, Size> clothesSizeMap = {
    0: Size(120.w, 70.h), // 호랑이
    1: Size(100.w, 50.h), // 토끼
    2: Size(140.w, 70.h), // 곰
    3: Size(110.w, 60.h), // 다람쥐
  };

  static final Map<int, double> clothesTopMap = {
    0: 210.h, // 호랑이
    1: 234.h, // 토끼
    2: 210.h, // 곰
    3: 223.h, // 다람쥐
  };

  static final Map<int, Size> hatSizeMap = {
    0: Size(80.w, 40.h), // 호랑이
    1: Size(70.w, 40.h), // 토끼
    2: Size(100.w, 50.h), // 곰
    3: Size(60.w, 40.h), // 다람쥐
  };

  static final Map<int, double> hatTopMap = {
    0: 80.h,
    1: 130.h,
    2: 80.h,
    3: 80.h,
  };
}

class MyroomItem extends StatelessWidget {
  final String category;
  final String itemName;
  final bool isSelected;
  final int price;
  final bool isOwn;

  const MyroomItem({
    super.key,
    required this.category,
    required this.itemName,
    required this.isSelected,
    required this.price,
    required this.isOwn,
  });

  @override
  Widget build(BuildContext context) {
    final MyroomItemController itemController = Get.find<MyroomItemController>();
    bool isCurrentlyWorn = itemController.clothingImage.value == itemName ||
        itemController.hatImage.value == itemName ||
        itemController.accessoriesImage.value == itemName;
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF4E9D0),
        borderRadius: BorderRadius.circular(8.r),
        border: isCurrentlyWorn ? Border.all(color: Color(0xFFEF6363), width: 2.w) : Border.all(color: Colors.transparent),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: SizedBox(height: 4.h),
          ),
          Expanded(
            flex: category == "40" ? 5 : 3,
            child: Padding(
              padding: EdgeInsets.all(category == "40" ? 0.0 : 8.0),
              child: Image.network(
                itemName,
                fit: BoxFit.fill,
              ),
            ),
          ),
          Expanded(
              child: Visibility(
            visible: !isOwn,
            child: SizedBox(
              height: 4.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/icon/coin.png'),
                  Text(
                    '$price',
                    style: outlineTextStyle(14.sp),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}
