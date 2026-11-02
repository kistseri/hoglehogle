import 'dart:io';

import 'package:flutter/services.dart';

class NativeLogger {
  static const _channel = MethodChannel('custom_logger');

  static void log(String message) {
    if (Platform.isAndroid) {
      _channel.invokeMethod('log', {'message': message});
    } else {
      print(message); // iOS나 웹이면 그냥 출력
    }
  }
}
