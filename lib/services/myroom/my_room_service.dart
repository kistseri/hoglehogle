import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/data/models/my_room_data.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:logger/logger.dart';

Future<bool>? _running;

// 옷장 (아이템 목록·가진 아이템)
// 실패해도 팝업은 띄우지 않고 상태만 바꿈 (마이룸 화면에서 안내 + 다시 시도).
// 홈 시작·구매 후 새로고침이 겹쳐도 요청은 한 번만 보냄. 성공하면 true.
Future<bool> myroomService() {
  return _running ??= _load().whenComplete(() => _running = null);
}

Future<bool> _load() async {
  final connectivityController = Get.put(ConnectivityController());
  final myroomDataController = Get.put(MyroomDataController());
  final id = Get.isRegistered<LoginDataController>() ? Get.find<LoginDataController>().loginData.value?.id : null;

  if (id != null) myroomDataController.resetFor(id);
  if (!connectivityController.isConnected.value || id == null) {
    myroomDataController.setError();
    return false;
  }

  myroomDataController.setLoading();
  try {
    final response = await dio.post(dotenv.get('MYROOM_COPY_URL'), data: jsonEncode({'id': id}));
    final data = response.data is String ? json.decode(response.data) : response.data;
    final List<dynamic> resultList = data is List ? data : [];
    if (response.statusCode != 200 || resultList.isEmpty || resultList[0]['result']?.toString() != '0000') {
      Logger().w('옷장 불러오기 실패: ${resultList.isEmpty ? response.statusCode : resultList[0]['message']}');
      myroomDataController.setError();
      return false;
    }
    myroomDataController.setMyroomData(
      resultList.whereType<Map<String, dynamic>>().map(MyroomData.fromJson).toList(),
    );
    return true;
  } catch (e) {
    Logger().w('옷장 불러오기 실패: $e');
    myroomDataController.setError();
    return false;
  }
}
