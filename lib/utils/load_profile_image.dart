import 'dart:async';
import 'dart:ui' as ui;

import 'package:flame/extensions.dart';
import 'package:flame/image_composition.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';

Future<Map<String, ImageProvider?>> loadProfileImage(String userId) async {
  var selectedItemBox = await Hive.openBox('selectedItemBox');

  // character 기본값 설정
  if (!selectedItemBox.containsKey('${userId}_character')) {
    await selectedItemBox.put(
        '${userId}_character', 'assets/images/myroom/tiger.png');
  }

  // 비어 있는 URL을 null로 처리
  ImageProvider? getImageProvider(String? url, {bool isAsset = false}) {
    if (url == null || url.isEmpty) return null;
    return isAsset ? AssetImage(url) : NetworkImage(url);
  }

  return {
    'character': getImageProvider(selectedItemBox.get('${userId}_character'),
        isAsset: true),
    'hatImage': getImageProvider(selectedItemBox.get('${userId}_hatImage')),
    'clothingImage':
        getImageProvider(selectedItemBox.get('${userId}_clothingImage')),
    'accessoriesImage':
        getImageProvider(selectedItemBox.get('${userId}_accessoriesImage')),
    'backgroundImage':
        getImageProvider(selectedItemBox.get('${userId}_backgroundImage')),
  };
}

Future<ui.Image> loadImageFromProvider(ImageProvider provider) async {
  final completer = Completer<ui.Image>();
  final stream = provider.resolve(ImageConfiguration.empty);

  stream.addListener(ImageStreamListener((ImageInfo info, bool _) {
    completer.complete(info.image);
  }));

  return completer.future;
}

Future<ImageProvider> getProfileImageProvider(
    Map<String, ImageProvider?> imageProviders) async {
  final characterImage = imageProviders['character'];
  final hatImage = imageProviders['hatImage'];
  final clothesImage = imageProviders['clothingImage'];
  final accessoriesImage = imageProviders['accessoriesImage'];
  final backgroundImage = imageProviders['backgroundImage'];

  final imageFutures = [
    if (backgroundImage != null) loadImageFromProvider(backgroundImage),
    if (characterImage != null) loadImageFromProvider(characterImage),
    if (hatImage != null) loadImageFromProvider(hatImage),
    if (clothesImage != null) loadImageFromProvider(clothesImage),
    if (accessoriesImage != null) loadImageFromProvider(accessoriesImage),
  ];

  final images = await Future.wait(imageFutures);

  final size = Size(400.w, 400.h);
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size.width, size.height));

  double characterX = 0, characterY = 0;
  int imageIndex = 0;

  // BackgroundImage
  if (backgroundImage != null && images.length > imageIndex) {
    final backgroundImg = images[imageIndex++];
    canvas.drawImage(backgroundImg, Offset(0, 0), Paint());
  }

  // Character Image
  ui.Image? characterImg;
  if (characterImage != null && images.length > imageIndex) {
    characterImg = images[imageIndex++];
    characterX = (size.width - characterImg.width) / 2;
    characterY = (size.height - characterImg.height) / 2 + 50.h;
    canvas.drawImage(characterImg, Offset(characterX, characterY), Paint());
  }

  // Hat Image
  if (hatImage != null && images.length > imageIndex && characterImg != null) {
    final hatImg = images[imageIndex++];
    final hatX = characterX + (characterImg.width - hatImg.width) / 2;
    final hatY = characterY - hatImg.height * 0.55;
    canvas.drawImage(hatImg, Offset(hatX, hatY), Paint());
  }

  // Clothing Image
  if (clothesImage != null &&
      images.length > imageIndex &&
      characterImg != null) {
    final clothesImg = images[imageIndex++];
    final clothesX = characterX + (characterImg.width - clothesImg.width) / 2;
    final clothesY = characterY + characterImg.height * 0.55;
    canvas.drawImage(clothesImg, Offset(clothesX, clothesY), Paint());
  }

  // Accessories Image
  if (accessoriesImage != null &&
      images.length > imageIndex &&
      characterImg != null) {
    final accessoriesImg = images[imageIndex++];
    final accessoriesX =
        characterX + (characterImg.width - accessoriesImg.width) / 2;
    final accessoriesY = characterY + characterImg.height * 0.8;
    canvas.drawImage(
        accessoriesImg, Offset(accessoriesX, accessoriesY), Paint());
  }

  final picture = recorder.endRecording();
  final combinedImage =
      await picture.toImage(size.width.toInt(), size.height.toInt());

  final byteData =
      await combinedImage.toByteData(format: ui.ImageByteFormat.png);
  return MemoryImage(byteData!.buffer.asUint8List());
}
