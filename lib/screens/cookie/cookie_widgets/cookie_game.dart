import 'dart:math';

import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/data/models/cookie_data.dart';
import 'package:hoho_hanja/main.dart';
import 'package:hoho_hanja/screens/cookie/cookie_widgets/cookie_element.dart';
import 'package:hoho_hanja/utils/result_service.dart';
import 'package:hoho_hanja/widgets/dialog/result_dialog.dart';

class CookieGame extends FlameGame {
  // 기준 화면 높이: 이보다 긴 화면에서는 떨어지는 속도를 높여 바닥까지 걸리는 시간을 맞춤
  static const double baseHeight = 844;
  // 쿠키가 이 높이(화면 비율)를 지나면 다람쥐가 걱정, 게임오버 기준선
  static const double worryRatio = 0.47;
  static const double gameOverRatio = 0.9;

  final Random random = Random();
  final cookieController = Get.put(CookieDataController());
  RxInt currentIndex = 0.obs;
  int lives = 3;
  double speed = 30;
  final String code;
  final double topInset; // 앱바 아래부터 쿠키를 떨어뜨림
  final double cookieSize;
  bool isGameOver = false;
  int solved = 0; // 맞힌 문제 수 (점수)

  CookieGame({
    required this.code,
    required this.topInset,
    required this.cookieSize,
  });

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    cookieController.setWorry(false);
    if (cookieController.quiz.isEmpty) return;
    _loadLevel();
  }

  // 화면 높이에 맞춘 낙하 속도
  double get _fallSpeed => speed * max(1.0, size.y / baseHeight);

  void _loadLevel() {
    children.whereType<CookieElement>().forEach((element) {
      element.removeFromParent();
    });

    final quiz = cookieController.quiz[currentIndex.value];
    final texts = [quiz.answer, ...quiz.wrongAnswers];
    List<Vector2> positions = [];

    // 쿠키끼리 겹치지 않는 시작 위치 (좁은 화면에서 무한 반복하지 않도록 시도 횟수 제한)
    Vector2 generateNonOverlappingPosition() {
      final double minDistance = cookieSize * 1.08;
      final double maxX = max(0.0, size.x - cookieSize);
      Vector2 newPosition;
      int tries = 0;
      bool overlapping;

      do {
        overlapping = false;
        newPosition = Vector2(
          random.nextDouble() * maxX,
          topInset + random.nextDouble() * cookieSize * 1.6,
        );

        for (final position in positions) {
          if ((position - newPosition).length < minDistance) {
            overlapping = true;
            break;
          }
        }
      } while (overlapping && ++tries < 200);
      positions.add(newPosition);
      return newPosition;
    }

    for (int i = 0; i < texts.length; i++) {
      add(CookieElement(
          isCorrect: i == 0,
          text: texts[i],
          index: currentIndex.value,
          speed: _fallSpeed,
          cookieSize: cookieSize)
        ..position = generateNonOverlappingPosition());
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isGameOver) return;

    final elements =
        children.whereType<CookieElement>().where((e) => !e.isRemoving);
    if (elements.isEmpty) return;

    final lowestElement =
        elements.reduce((a, b) => a.position.y > b.position.y ? a : b);

    // 걱정·게임오버 모두 게임 화면 높이 기준 (기기마다 높이가 달라도 멈추지 않게)
    cookieController.setWorry(lowestElement.position.y >= size.y * worryRatio);

    if (lowestElement.position.y >= size.y * gameOverRatio) {
      gameOver();
    }
  }

  void onCookieTapped(CookieElement tappedElement) {
    if (isGameOver) return;

    if (tappedElement.isCorrect) {
      // 정답
      effect.correctSound();
      solved++;
      children.whereType<CookieElement>().forEach((element) {
        element.removeFromParent();
      });

      if (currentIndex.value + 1 >= cookieController.quiz.length) {
        gameOver();
      } else {
        nextLevel();
      }
      // 오답
    } else {
      effect.wrongSound();
      tappedElement.removeFromParent();
      lives--;
      if (lives <= 0) {
        gameOver();
      }
    }
  }

  // 게임 종료 (타이머·탭이 겹쳐도 결과 저장·결과창은 한 번만)
  Future<void> gameOver() async {
    if (isGameOver) return;
    isGameOver = true;
    cookieController.setWorry(false);
    children.whereType<CookieElement>().forEach((element) {
      element.removeFromParent();
    });

    final coin = await resultService(code, solved);
    // 결과를 기다리는 동안 화면을 나갔으면 결과창을 띄우지 않음
    final context = buildContext;
    if (context == null || !context.mounted) return;
    resultDialog(
      context,
      solved,
      cookieController.quiz.length,
      coin,
    );
  }

  void nextLevel() {
    cookieController.setWorry(false);

    currentIndex.value =
        (currentIndex.value + 1) % cookieController.quiz.length;

    if ((currentIndex.value + 1) % 4 == 0 && speed < 210) {
      speed += 15;
    }
    _loadLevel();
  }
}
