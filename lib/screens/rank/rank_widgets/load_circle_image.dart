import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<ui.Image> loadImageFromUrl(String url) async {
  final ByteData data = await NetworkAssetBundle(Uri.parse(url)).load("");
  final Uint8List bytes = data.buffer.asUint8List();
  return decodeImageFromList(bytes);
}

Future<ImageProvider> getCombinedImageProvider(List<String> imageUrls) async {
  String characterImage = imageUrls[0];
  String hatImage = imageUrls[1];
  String clothesImage = imageUrls[2];
  String eyeImage = imageUrls[3];
  String backgroundImage = imageUrls[4];

  final imageFutures =
      imageUrls.where((url) => url.isNotEmpty).map(loadImageFromUrl).toList();
  final images = await Future.wait(imageFutures);

  final size = Size(500.h, 500.w); // 원하는 사이즈로 설정
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size.width, size.height));

  double characterX = 0, characterY = 0;
  int imageIndex = 0;

  // BackgroundImage (배경)
  if (backgroundImage.isNotEmpty && images.length > imageIndex) {
    final backgroundImg = images[imageIndex++];
    canvas.drawImage(backgroundImg, Offset(0, 0), Paint());
  }

  // Character 이미지가 중앙에 오도록 설정하고 위치를 저장
  ui.Image? characterImg;
  if (characterImage.isNotEmpty && images.length > imageIndex) {
    characterImg = images[imageIndex++];
    characterX = (size.width - characterImg.width) / 2;
    characterY = (size.height - characterImg.height) / 2;
    canvas.drawImage(characterImg, Offset(characterX, characterY), Paint());
  }

  // Hat 이미지가 character 이미지의 위쪽에 위치
  if (hatImage.isNotEmpty &&
      images.length > imageIndex &&
      characterImg != null) {
    final hatImg = images[imageIndex++];
    final hatX = characterX + (characterImg.width - hatImg.width) / 2; // 중앙 정렬
    final hatY = characterY - hatImg.height * 0.55; // 머리 위쪽에 배치
    canvas.drawImage(hatImg, Offset(hatX, hatY), Paint());
  }

  // Eye 이미지가 character 이미지에 겹쳐서 눈 위치에 배치
  if (eyeImage.isNotEmpty &&
      images.length > imageIndex &&
      characterImg != null) {
    final eyeImg = images[imageIndex++];
    final eyeX = characterX + (characterImg.width - eyeImg.width) / 2;
    final eyeY = characterY + eyeImg.height / 4;
    canvas.drawImage(eyeImg, Offset(eyeX, eyeY), Paint());
  }

  // Clothes 이미지가 character 이미지 아래쪽에 위치
  if (clothesImage.isNotEmpty &&
      images.length > imageIndex &&
      characterImg != null) {
    final clothesImg = images[imageIndex++];
    final clothesX = characterX + (characterImg.width - clothesImg.width) / 2;
    final clothesY = characterY + characterImg.height * 0.55; // 몸통 아래쪽에 배치
    canvas.drawImage(clothesImg, Offset(clothesX, clothesY), Paint());
  }

  final picture = recorder.endRecording();
  final combinedImage =
      await picture.toImage(size.width.toInt(), size.height.toInt());

  final byteData =
      await combinedImage.toByteData(format: ui.ImageByteFormat.png);
  return MemoryImage(byteData!.buffer.asUint8List());
}
