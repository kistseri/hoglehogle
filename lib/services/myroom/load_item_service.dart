import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/screens/myroom/myroom_wigets/my_room_item.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:logger/logger.dart';

Future<void>? _running;

// 저장된 캐릭터·착용 아이템 불러오기 (앱 시작 때)
// 실패하면 기본 캐릭터 그대로 두고 팝업은 띄우지 않음 (홈 시작 때 팝업이 겹치지 않도록)
Future<void> loadItemService() {
  return _running ??= _load().whenComplete(() => _running = null);
}

Future<void> _load() async {
  final connectivityController = Get.put(ConnectivityController());
  final id = Get.isRegistered<LoginDataController>() ? Get.find<LoginDataController>().loginData.value?.id : null;
  if (id == null) return;
  MyroomItemController.to.resetFor(id);
  if (!connectivityController.isConnected.value) return;

  try {
    final response = await dio.post(dotenv.get('SELECTED_ITEM_READ_URL'), data: jsonEncode({'user_id': id}));
    final result = response.data is String ? json.decode(response.data) : response.data;
    if (response.statusCode == 200 && result is Map<String, dynamic> && result['result']?.toString() == '0000') {
      MyroomItemController.to.applyItemResponse(result);
    } else {
      Logger().w('착용 아이템 불러오기 실패: ${result is Map ? result['message'] : response.statusCode}');
    }
  } catch (e) {
    Logger().w('착용 아이템 불러오기 실패: $e');
  }
}
