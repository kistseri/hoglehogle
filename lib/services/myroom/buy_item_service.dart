import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/data/models/goods_data.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/services/myroom/my_room_service.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';
import 'package:logger/logger.dart';

// 아이템 구매
Future<void> buyItemService(categoryId, itemId, coin) async {
  final connectivityController = Get.put(ConnectivityController());
  final loginController = Get.find<LoginDataController>();

  if (connectivityController.isConnected.value) {
    String url = dotenv.get('BUY_ITEM_URL');
    String id = loginController.loginData.value!.id;

    final Map<String, dynamic> requestData = {
      'id': id,
      'CharacterID': categoryId,
      'ItemID': itemId,
      'coin': coin
    };

    // HTTP POST 요청
    final response = await dio.post(url, data: jsonEncode(requestData));

    try {
      // 응답을 성공적으로 받았을 때
      if (response.statusCode == 200) {
        final List<dynamic> result = json.decode(response.data);

        final resultValue = result[0]['result'];
        // 응답 결과가 있는 경우
        if (resultValue == "0000") {
          await myroomService();
          GoodsData goodsData = GoodsData.fromJson(result[0]);
          final goodsController = Get.find<GoodsDataController>();
          goodsController.setGoodsData(goodsData);
          Get.back();
        }
        // 응답 데이터가 오류일 때("9999": 오류)
        else {
          failDialog('불러오기 실패', '${result[0]['message']}');
        }
      }
    }
    // 예외처리
    catch (e) {
      Logger().d('e = $e');
    }
  } else {
    failDialog("연결 실패", "인터넷 연결을 확인해주세요");
  }
}
