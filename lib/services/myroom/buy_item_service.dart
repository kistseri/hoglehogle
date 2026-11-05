import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/services/auth/my_goods_service.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/data/models/my_room_data.dart';
import 'package:hoho_hanja/services/myroom/my_room_service.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';
import 'package:logger/logger.dart';

bool _buying = false;

// 아이템 구매. 성공하면 true (코인·옷장을 새로 받은 뒤)
// 구매 요청이 끝나기 전에는 다시 보내지 않음 (연타로 두 번 사지 않도록)
// TODO(서버): 가격(coin)을 앱이 보내고 있음. 서버가 itemId로 가격을 직접 확인해야 함 (수정목록 M-04)
Future<bool> buyItemService(MyroomData item) async {
  if (_buying) return false;
  final connectivityController = Get.put(ConnectivityController());
  final id = Get.isRegistered<LoginDataController>() ? Get.find<LoginDataController>().loginData.value?.id : null;

  if (!connectivityController.isConnected.value || id == null) {
    failDialog("연결 실패", "인터넷 연결을 확인해주세요");
    return false;
  }

  _buying = true;
  try {
    final response = await dio.post(
      dotenv.get('BUY_ITEM_URL'),
      data: jsonEncode({'id': id, 'CharacterID': item.categoryId, 'ItemID': item.itemId, 'coin': item.coin}),
    );
    final data = response.data is String ? json.decode(response.data) : response.data;
    final List<dynamic> result = data is List ? data : [];
    if (response.statusCode != 200 || result.isEmpty || result[0]['result']?.toString() != '0000') {
      final message = result.isNotEmpty ? result[0]['message']?.toString() ?? '' : '';
      failDialog('구매 실패', message.isEmpty ? '잠시 후 다시 시도해 주세요' : message);
      return false;
    }
    // 구매 응답의 coin·dia는 남은 코인·다이아가 아닐 수 있어서 쓰지 않고, 서버에 저장된 값을 다시 받음
    Logger().i('아이템 구매 응답: ${result[0]}');
    await Future.wait([myGoodsService(), myroomService()]);
    return true;
  } catch (e) {
    Logger().w('아이템 구매 실패: $e');
    failDialog('구매 실패', '잠시 후 다시 시도해 주세요');
    return false;
  } finally {
    _buying = false;
  }
}
