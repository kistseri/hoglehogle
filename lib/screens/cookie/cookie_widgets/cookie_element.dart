import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/screens/cookie/cookie_widgets/cookie_game.dart';

// 그림마다 글자를 놓을 가운데 (그림 폭·높이 비율). 꼭지·심지를 뺀 몸통 가운데에 맞춤
final Map<int, Vector2> _textCenters = {
  1: Vector2(0.41, 0.60), // 도토리: 왼쪽 아래 밝은 얼굴 부분
  2: Vector2(0.50, 0.50), // 쿠키: 정가운데
  3: Vector2(0.50, 0.565), // 사과: 위 꼭지·잎을 빼고 조금 아래
  4: Vector2(0.505, 0.58), // 폭탄: 위 심지를 빼고 조금 아래
};

class CookieElement extends SpriteComponent
    with TapCallbacks, HasGameReference<CookieGame> {
  // 문제의 정답으로 떨어뜨린 쿠키인지 (놓치면 게임오버, 정답 판정은 누르는 순간의 문제로 함)
  final bool isAnswer;
  final String text;
  final double speed;
  bool isPopping = false; // 정답을 맞혀 터지는 중 (더 떨어지지 않고 눌리지 않음)

  CookieElement({
    required this.isAnswer,
    required this.text,
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
        isAnswer ? Random().nextInt(3) + 1 : Random().nextInt(4) + 1;

    final imagePath = 'cookie/cookie_c0$imageIndex.png';
    sprite = await Sprite.load(imagePath);

    final textComponent = TextComponent(
      text: text,
      textRenderer: TextPaint(
        style: TextStyle(
          // 쿠키 크기에 비례 (시안: 쿠키 65에 글자 25)
          fontSize: width * 25 / 65,
          // 3번(사과)·4번(폭탄)은 바탕이 진해서 글자를 흰색으로
          color: imageIndex == 3 || imageIndex == 4 ? mFontWhite : mFontMain,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(width * _textCenters[imageIndex]!.x, height * _textCenters[imageIndex]!.y),
      anchor: Anchor.center,
    );

    add(textComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (game.isGameOver || isPopping) return;
    position.y += speed * dt;
  }

  // 정답 연출: 제자리에서 톡 커졌다가 사라짐
  void pop() {
    if (isPopping) return;
    isPopping = true;
    // 가운데를 기준으로 커지게
    anchor = Anchor.center;
    position += size / 2;
    addAll([
      ScaleEffect.to(Vector2.all(1.4), EffectController(duration: 0.15, curve: Curves.easeOut)),
      RemoveEffect(delay: 0.18),
    ]);
  }

  @override
  void onTapDown(TapDownEvent event) {
    // 이미 사라지는 중인 쿠키를 같은 순간 또 누르면 무시 (목숨 두 번 깎임 방지)
    if (isRemoving || isPopping) return;
    game.onCookieTapped(this);
  }
}
