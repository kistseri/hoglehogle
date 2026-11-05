import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:logger/logger.dart';

// 캐릭터·착용 아이템 저장. 성공하면 true
// 마이룸을 나가거나 앱이 백그라운드로 갈 때 불리므로 팝업은 띄우지 않음 (실패하면 다음에 나갈 때 다시 저장)
Future<bool> selectedItemService(List<Map<String, dynamic>> items, String character) async {
  final connectivityController = Get.put(ConnectivityController());
  final id = Get.isRegistered<LoginDataController>() ? Get.find<LoginDataController>().loginData.value?.id : null;
  if (!connectivityController.isConnected.value || id == null) return false;

  try {
    final response = await dio.post(
      dotenv.get('SELECTED_ITEM_COPY_URL'),
      data: jsonEncode({'user_id': id, 'char_index': character, 'items': items}),
    );
    final result = response.data is String ? json.decode(response.data) : response.data;
    if (response.statusCode == 200 && result is Map && result['result']?.toString() == '0000') return true;
    Logger().w('착용 아이템 저장 실패: ${result is Map ? result['message'] : response.statusCode}');
    return false;
  } catch (e) {
    Logger().w('착용 아이템 저장 실패: $e');
    return false;
  }
}
