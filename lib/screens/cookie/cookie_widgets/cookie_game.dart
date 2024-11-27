import 'dart:math';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/data/models/cookie_data.dart';
import 'package:hoho_hanja/main.dart';
import 'package:hoho_hanja/screens/cookie/cookie_widgets/cookie_element.dart';
import 'package:hoho_hanja/utils/result_service.dart';
import 'package:hoho_hanja/widgets/dialog/result_dialog.dart';

class CookieGame extends FlameGame with TapDetector {
  final Random random = Random();
  final cookieController = Get.put(CookieDataController());
  RxInt currentIndex = 0.obs;
  int lives = 3;
  double speed = 30;
  String code;
  bool isGameOver = false;

  CookieGame({required this.code});

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _loadLevel();
  }

  void _loadLevel() {
    children.whereType<CookieElement>().forEach((element) {
      element.removeFromParent();
    });

    List<Vector2> positions = [];

    Vector2 generateNonOverlappingPosition() {
      const double minDistance = 70;
      Vector2 newPosition;
      bool overlapping;

      do {
        overlapping = false;
        newPosition = Vector2(
          random.nextDouble() * (size.x - 65),
          100 + random.nextDouble() * 100,
        );

        for (final position in positions) {
          if ((position - newPosition).length < minDistance) {
            overlapping = true;
            break;
          }
        }
      } while (overlapping);
      positions.add(newPosition);
      return newPosition;
    }

    final correctCookie = CookieElement(
        isCorrect: true,
        text: cookieController.quiz[currentIndex.value]['options'][1],
        index: currentIndex.value,
        speed: speed)
      ..position = generateNonOverlappingPosition();
    add(correctCookie);

    for (int i = 0; i < 3; i++) {
      add(CookieElement(
          isCorrect: false,
          text: cookieController.quiz[currentIndex.value]['wrongAnswer'][i],
          index: currentIndex.value,
          speed: speed)
        ..position = generateNonOverlappingPosition());
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (isGameOver) return;

    if (children.whereType<CookieElement>().isNotEmpty) {
      final lowestElement = children
          .whereType<CookieElement>()
          .reduce((a, b) => a.position.y > b.position.y ? a : b);

      double gameOverThreshold = MediaQuery.of(Get.context!).size.height * 0.9;

      if (lowestElement.position.y >= gameOverThreshold) {
        isGameOver = true;
        gameOver();
        children.whereType<CookieElement>().forEach((element) {
          element.removeFromParent();
        });
      }
    }
  }

  @override
  void onTapDown(TapDownInfo info) {
    final tappedElement = children.whereType<CookieElement>().firstWhere(
          (component) =>
              component.toRect().contains(info.eventPosition.global.toOffset()),
          orElse: () => CookieElement(
              isCorrect: false,
              text: cookieController.quiz[currentIndex.value]['wrongAnswer'],
              index: currentIndex.value,
              speed: speed),
        );

    if (tappedElement != null) {
      if (tappedElement.isCorrect) {
        // 정답
        effect.correctSound();
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
  }

  void gameOver() async {
    if (currentIndex.value + 1 >= cookieController.quiz.length) {
      final coin = await resultService(code, currentIndex.value + 1);
      resultDialog(
        Get.context!,
        currentIndex.value + 1,
        cookieController.quiz.length,
        coin,
      );
    } else {
      final coin = await resultService(code, currentIndex.value);
      resultDialog(
        Get.context!,
        currentIndex.value,
        cookieController.quiz.length,
        coin,
      );
    }
  }

  void nextLevel() {
    cookieController.isWorried.value = false;

    currentIndex.value =
        (currentIndex.value + 1) % cookieController.quiz.length;

    if ((currentIndex.value + 1) % 4 == 0 && speed < 210) {
      speed += 15;
    }
    _loadLevel();
  }
}
