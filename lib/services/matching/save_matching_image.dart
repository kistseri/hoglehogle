import 'dart:io';

import 'package:hoho_hanja/_core/http.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> saveImage(String imageUrl) async {
  try {
    // 저장 권한 요청
    if (await Permission.storage.request().isGranted) {
      final galleryDir = Directory('/storage/emulated/0/Pictures/호글호글');

      if (!await galleryDir.exists()) {
        await galleryDir.create(recursive: true);
      }

      final imagePath =
          '${galleryDir.path}/image_${DateTime.now().millisecondsSinceEpoch}.png';
      await dio.download(imageUrl, imagePath);

      print('Image saved to HogleHogle folder at $imagePath');
    } else {
      if (await Permission.storage.request().isDenied) {
        await Permission.storage.request();
      }
    }
  } catch (e) {
    print('Error saving image: $e');
  }
}
