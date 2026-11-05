import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/data/models/goods_data.dart';
import 'package:hoho_hanja/data/models/my_room_data.dart';
import 'package:hoho_hanja/screens/myroom/myroom_wigets/my_room_item.dart';
import 'package:hoho_hanja/services/myroom/buy_item_service.dart';
import 'package:hoho_hanja/utils/formatter.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';

void showBuyItemDialog(MyroomData item) {
  var pressed = false;
  Get.defaultDialog(
    title: '알림',
    middleText: '${formatNumber(item.coin)}코인으로\n이 아이템을 구매하시겠습니까?',
    textCancel: '취소', // 취소는 GetX가 팝업만 닫음 (여기서 또 닫으면 화면까지 닫힘)
    textConfirm: '구매',
    buttonColor: primaryColor,
    onConfirm: () async {
      // 연타해도 한 번만 (닫히는 동안 두 번째 누름으로 화면이 닫히지 않도록)
      if (pressed) return;
      pressed = true;
      Get.back(); // 구매 팝업 닫기

      final coin = Get.isRegistered<GoodsDataController>() ? Get.find<GoodsDataController>().goodsData?.coin : null;
      if (coin == null) {
        failDialog('알림', '코인 정보를 불러오지 못했어요.\n잠시 후 다시 시도해 주세요.');
        return;
      }
      if (coin < item.coin) {
        failDialog('알림', '코인이 부족해요');
        return;
      }
      if (await buyItemService(item)) {
        // 산 아이템을 바로 입힘 (새로 받은 옷장 데이터로)
        final controller = MyroomItemController.to;
        final bought = Get.find<MyroomDataController>().findItem(item.categoryId, item.itemId);
        controller.wear(bought ?? MyroomData(
          itemId: item.itemId,
          categoryId: item.categoryId,
          item: item.item,
          coin: item.coin,
          useyn: 'Y',
        ));
      }
    },
  );
}
