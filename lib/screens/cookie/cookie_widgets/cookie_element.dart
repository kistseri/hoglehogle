import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/data/models/cookie_data.dart';

class CookieElement extends SpriteComponent {
  final cookie = Get.put(CookieDataController());
  final bool isCorrect;
  final String text;
  final int index;
  final double speed;

  CookieElement({
    required this.isCorrect,
    required this.text,
    required this.index,
    required this.speed,
  }) {
    width = 65.w;
    height = 65.h;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    final imageIndex =
        isCorrect ? Random().nextInt(3) + 1 : Random().nextInt(4) + 1;

    final imagePath = 'cookie/cookie_c0$imageIndex.png';
    sprite = await Sprite.load(imagePath);

    final textComponent = TextComponent(
      text: text,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 25.sp,
          color: mFontMain,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(width / 2, height / 2),
      anchor: Anchor.center,
    );

    add(textComponent);
  }

  @override
  void update(double dt) async {
    super.update(dt);
    position.y += speed * dt;

    if (position.y > 400 && position.y < 500) {
      cookie.setWorry(true);
    } else if (position.y >= 800) {
      removeFromParent();
      cookie.setWorry(false);
    }
  }
}
