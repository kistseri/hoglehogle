import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/data/models/goods_data.dart';
import 'package:hoho_hanja/data/models/my_room_data.dart';
import 'package:hoho_hanja/services/myroom/buy_item_service.dart';

void showBuyItemDialog(MyroomData item) {
  final goodsDataController = Get.put(GoodsDataController());
  Get.defaultDialog(
    title: '알림',
    middleText: '이 아이템을 구매하시겠습니까?',
    textCancel: '취소',
    textConfirm: '구매',
    buttonColor: primaryColor,
    onConfirm: () {
      if (goodsDataController.goodsData!.coin > item.coin) {
        buyItemService(item.categoryId, item.itemId, item.coin);
      } else {
        Get.defaultDialog(
          title: '알림',
          middleText: '코인이 부족해요',
        );
        Future.delayed(
          Duration(seconds: 1),
          () {
            Get.back();
          },
        );
      }
    },
    onCancel: () {
      Get.back();
    },
  );
}
