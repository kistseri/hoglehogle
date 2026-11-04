import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/screens/cookie/cookie_widgets/cookie_game.dart';

class CookieElement extends SpriteComponent
    with TapCallbacks, HasGameReference<CookieGame> {
  final bool isCorrect;
  final String text;
  final int index;
  final double speed;

  CookieElement({
    required this.isCorrect,
    required this.text,
    required this.index,
    required this.speed,
    required double cookieSize,
  }) {
    // 정사각형 (태블릿에서 납작해지지 않게)
    width = cookieSize;
    height = cookieSize;
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
          // 4번(폭탄)은 바탕이 어두워서 글자를 흰색으로
          color: imageIndex == 4 ? mFontWhite : mFontMain,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(width / 2, height / 2),
      anchor: Anchor.center,
    );

    add(textComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += speed * dt;
  }

  @override
  void onTapDown(TapDownEvent event) {
    // 이미 사라지는 중인 쿠키를 같은 순간 또 누르면 무시 (목숨 두 번 깎임·문제 건너뜀 방지)
    if (isRemoving) return;
    game.onCookieTapped(this);
  }
}
