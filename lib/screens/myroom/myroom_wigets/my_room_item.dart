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
import 'package:hoho_hanja/widgets/dialog/buy_item_dialog.dart';

class MyroomItemController extends GetxController {
  final MyroomDataController myroomDataController =
      Get.find<MyroomDataController>();
  final LoginDataController loginDataController =
      Get.find<LoginDataController>();
  final GoodsDataController goodsDataController =
      Get.find<GoodsDataController>();

  final RxString selectedCategory = ''.obs;
  final RxInt selectedItem = (-1).obs;
  final RxString clothingImage = ''.obs; // 옷 이미지 URL
  final RxString accessoriesImage = ''.obs; // 모자 이미지 URL
  final RxString backgroundImage = ''.obs;
  final RxString hatImage = ''.obs; // 모자 이미지 URL
  var characterImage = charcater[0].obs;
  int currentCharacter = 0;

  void setSelectedCategory(String categoryId) {
    selectedCategory.value = categoryId;
    selectedItem.value = -1;
  }

  void selectItem(int index) {
    selectedItem.value = index;

    var item =
        myroomDataController.getDataByCategory(selectedCategory.value)[index];
    updateScreenImage(item);
  }

  void updateScreenImage(MyroomData item) {
    if (item.useyn == 'Y') {
      // 옷 이미지를 업데이트
      if (item.categoryId == '10') {
        clothingImage.value = item.item;
        saveSelectedItem('clothingImage', item.item);
      }
      // 모자 이미지를 업데이트
      else if (item.categoryId == '20') {
        hatImage.value = item.item;
        saveSelectedItem('hatImage', item.item);
      }
      // 안경 이미지를 업데이트
      else if (item.categoryId == '30') {
        accessoriesImage.value = item.item;
        saveSelectedItem('accessoriesImage', item.item);
      }
      // 배경 이미지를 업데이트
      else if (item.categoryId == '40') {
        backgroundImage.value = item.item;
        saveSelectedItem('backgroundImage', item.item);
      }
    } else {
      showBuyItemDialog(item);
    }
  }

  void nextCharacter() {
    currentCharacter = (currentCharacter + 1) % charcater.length;
    characterImage.value = charcater[currentCharacter];
    saveSelectedItem('character', charcater[currentCharacter].assetName);
  }

  void saveSelectedItem(String key, String value) {
    String userId = loginDataController.loginData.value!.id;
    var box = Hive.box('selectedItemBox');
    box.put('${userId}_$key', value);
  }
}

class MyroomItem extends StatelessWidget {
  final String itemName;
  final bool isSelected;
  final int price;
  final bool isOwn;

  const MyroomItem({
    super.key,
    required this.itemName,
    required this.isSelected,
    required this.price,
    required this.isOwn,
  });

  @override
  Widget build(BuildContext context) {
    final MyroomItemController itemController =
        Get.find<MyroomItemController>();
    bool isCurrentlyWorn = itemController.clothingImage.value == itemName ||
        itemController.hatImage.value == itemName ||
        itemController.accessoriesImage.value == itemName;
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF4E9D0),
        borderRadius: BorderRadius.circular(8.r),
        border: isCurrentlyWorn
            ? Border.all(color: Color(0xFFEF6363), width: 2.w)
            : Border.all(color: Colors.transparent),
      ),
      child: Padding(
        padding: EdgeInsets.all(gapQuarter),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: SizedBox(height: 4.h)),
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Image.network(
                  itemName,
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Expanded(
              child: !isOwn
                  ? SizedBox(
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
                    )
                  : SizedBox(height: 4.w),
            ),
          ],
        ),
      ),
    );
  }
}
