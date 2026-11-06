import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/data/models/cookie_data.dart';
import 'package:hoho_hanja/main.dart';
import 'package:hoho_hanja/screens/cookie/cookie_widgets/cookie_element.dart';
import 'package:hoho_hanja/utils/result_service.dart';
import 'package:hoho_hanja/widgets/dialog/result_dialog.dart';

// 한자가 계속 떨어지는 방식
// - 다람쥐 말풍선에 문제 하나, 한자 쿠키는 쉬지 않고 한 번에 1~2개씩 떨어짐
// - 문제의 정답 한자를 누르면 맞힌 개수 +1, 바로 다음 문제
// - 정답이 아닌 한자를 누르거나, 정답 한자가 땅에 닿으면 목숨 -1 (목숨이 다 떨어지면 게임오버)
// - 다른 한자는 땅에 닿으면 그냥 사라짐
// - 문제를 모두 맞히면 클리어
class CookieGame extends FlameGame {
  // 기준 화면 높이: 화면 높이에 비례해 떨어지는 속도를 맞춰, 어느 기기에서나 바닥까지 걸리는 시간이 같게
  static const double baseHeight = 844;
  // 정답 쿠키가 이 높이(화면 비율)를 지나면 다람쥐가 걱정
  static const double worryRatio = 0.6;
  // 쿠키마다 떨어지는 속도를 이 비율만큼 다르게 (±)
  static const double speedJitter = 0.1;
  static const int maxLives = 5; // 대상이 1~3학년이라 넉넉하게

  // 떨어지는 속도(기준 화면에서 초당 픽셀)·묶음이 나오는 간격(초): 맞힐수록 빨라지고 촘촘해짐
  static const double startSpeed = 35;
  static const double speedPerSolve = 1.5;
  static const double maxSpeed = 80;
  static const double startInterval = 1.8;
  static const double intervalPerSolve = 0.02;
  static const double minInterval = 1.3;
  // 한 번에 떨어지는 쿠키 수 (이 범위에서 랜덤)
  static const int minPerWave = 1;
  static const int maxPerWave = 2;

  // 정답 쿠키 전에 나오는 다른 쿠키 수: 문제마다(놓쳤을 때도) 이 범위에서 새로 뽑음
  // (항상 비슷한 때 정답이 나오면 뻔해짐)
  static const int minWrongBeforeAnswer = 1;
  static const int maxWrongBeforeAnswer = 5;

  final Random random = Random();
  final cookieController = Get.put(CookieDataController());
  RxInt currentIndex = 0.obs; // 지금 문제 번호 (말풍선 표시)
  final RxInt lives = maxLives.obs; // 남은 목숨 (화면 표시)
  final RxInt solved = 0.obs; // 맞힌 문제 수 (점수, 화면 표시)
  final String code;
  final double topInset; // 앱바 아래부터 쿠키를 떨어뜨림
  final double groundTop; // 땅 윗면 (쿠키는 땅 뒤로 쑥 들어가며 사라짐)
  final double cookieSize;
  bool isGameOver = false;

  double _spawnTimer = 0;
  int _sinceAnswer = 0; // 마지막 정답 쿠키 이후 나온 다른 쿠키 수
  int _wrongBeforeAnswer = minWrongBeforeAnswer; // 이번 정답 전에 나올 다른 쿠키 수
  final List<int> _recentLanes = []; // 최근에 쿠키가 나온 줄 (같은 자리에 몰리지 않게)

  // 화면 가운데 큰 글자: 시작 카운트다운(3 → 2 → 1 → 시작!), 끝날 때 '다 모았어요!'/'아쉬워요!'
  static const double countdownSeconds = 3;
  static const double startTextSeconds = 0.7; // '시작!' 보여주는 시간
  final RxString bannerText = ''.obs;
  double _countdown = countdownSeconds + startTextSeconds;

  // 정답을 맞히면 다람쥐가 잠깐 좋아하고, 틀리면 잠깐 걱정함
  static const double happySeconds = 0.9;
  static const double sadSeconds = 0.9;
  double _happyTime = 0;
  double _sadTime = 0;

  // 게임이 끝나고 결과창이 뜨기 전 잠깐 멈춰 보여주는 시간
  static const Duration endPause = Duration(milliseconds: 1100);

  CookieGame({
    required this.code,
    required this.topInset,
    required this.groundTop,
    required this.cookieSize,
  });

  CookieQuiz get _quiz => cookieController.quiz[currentIndex.value];

  // 화면 높이에 맞춘 낙하 속도
  double get _fallSpeed => min(maxSpeed, startSpeed + solved.value * speedPerSolve) * size.y / baseHeight;

  double get _spawnInterval => max(minInterval, startInterval - solved.value * intervalPerSolve);

  // 사라지는 연출 중인 쿠키(정답·오답·놓침)는 빼고 셈
  Iterable<CookieElement> get _cookies =>
      children.whereType<CookieElement>().where((e) => !e.isRemoving && !e.isLeaving);

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    cookieController.setWorry(false);
    _resetAnswerTiming();
    // 첫 쿠키는 바로 떨어지게
    _spawnTimer = startInterval;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver || cookieController.quiz.isEmpty) return;

    // 시작 카운트다운 동안은 쿠키를 떨어뜨리지 않음
    if (_countdown > 0) {
      _countdown -= dt;
      final remain = _countdown - startTextSeconds;
      bannerText.value = _countdown <= 0
          ? ''
          : remain > 0
              ? '${remain.ceil()}'
              : '시작!';
      if (_countdown > startTextSeconds) return;
    }

    if (_happyTime > 0) {
      _happyTime -= dt;
      if (_happyTime <= 0) cookieController.setHappy(false);
    }
    if (_sadTime > 0) _sadTime -= dt;

    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _spawnWave();
    }

    final answer = _quiz.answer;
    bool worried = _sadTime > 0;

    for (final cookie in _cookies.toList()) {
      // 지금 문제의 정답으로 떨어뜨린 쿠키만 놓치면 목숨 -1
      // (다른 문제 때 나온 같은 글자가 문제가 바뀌자마자 땅에 닿아 억울하게 깎이지 않게)
      final isAnswer = cookie.isAnswer && cookie.text == answer;
      if (isAnswer && cookie.position.y >= groundTop) {
        // 정답이 반쯤 땅에 묻히면 놓친 것
        cookie.missed();
        _loseLife();
        if (isGameOver) return;
        // 놓친 정답도 다시 랜덤하게 (바로 다음에 나오면 뻔해짐)
        _resetAnswerTiming();
      } else if (!isAnswer && cookie.position.y - cookie.size.y / 2 >= groundTop) {
        // 다른 쿠키는 땅 뒤로 완전히 들어가면 정리
        cookie.removeFromParent();
      } else if (isAnswer && cookie.position.y >= size.y * worryRatio) {
        worried = true;
      }
    }
    cookieController.setWorry(worried);
  }

  // 쿠키 1~2개를 한 번에 떨어뜨리기
  void _spawnWave() {
    final quiz = _quiz;
    final count = minPerWave + random.nextInt(maxPerWave - minPerWave + 1);
    // 이번 묶음에서 고른 글자·위치도 함께 봄 (add 한 쿠키는 다음 프레임에야 children 에 들어오므로)
    final onScreen = _cookies.map((e) => e.text).toSet();
    final usedLanes = <int>{}; // 이번 묶음에서 쓴 줄
    // 정답 글자는 화면에 하나만 (이전 문제 때 오답으로 나온 같은 글자가 남아 있어도 또 떨어뜨리지 않음)
    bool answerOnScreen = onScreen.contains(quiz.answer);

    for (int i = 0; i < count; i++) {
      final bool isAnswer = !answerOnScreen && _sinceAnswer >= _wrongBeforeAnswer;
      final String text;
      if (isAnswer) {
        text = quiz.answer;
        answerOnScreen = true;
        _sinceAnswer = 0;
      } else {
        text = _pickWrong(quiz, onScreen);
        _sinceAnswer++;
      }
      onScreen.add(text);

      final x = _spawnX(usedLanes);
      // 같은 묶음이라도 높이·속도를 살짝 다르게 해서 자연스럽게 (위치는 쿠키 가운데)
      add(CookieElement(
        isAnswer: isAnswer,
        text: text,
        speed: _fallSpeed * (1 - speedJitter + random.nextDouble() * speedJitter * 2),
        cookieSize: cookieSize,
      )..position = Vector2(x + cookieSize / 2, topInset + cookieSize / 2 + random.nextDouble() * cookieSize * 0.4));
    }
  }

  // 정답이 아닌 한자: 이 문제의 오답 → 다른 문제의 정답 순으로, 화면에 없는 글자를 먼저
  String _pickWrong(CookieQuiz quiz, Set<String> onScreen) {
    final others = cookieController.quiz.map((q) => q.answer).where((a) => a != quiz.answer).toSet();
    final candidates = [
      quiz.wrongAnswers.where((w) => !onScreen.contains(w)).toList(),
      others.where((a) => !onScreen.contains(a)).toList(),
      quiz.wrongAnswers,
      others.toList(),
    ];
    for (final pool in candidates) {
      if (pool.isNotEmpty) return pool[random.nextInt(pool.length)];
    }
    return quiz.answer; // 문제가 하나뿐이고 오답도 없는 경우
  }

  // 가로 위치: 화면 폭을 쿠키 크기만큼의 줄로 나누고, 이번 묶음·최근에 안 쓴 줄을 골라 화면 전체에 고루 퍼지게
  double _spawnX(Set<int> usedLanes) {
    final laneWidth = cookieSize * 1.1;
    final laneCount = max(1, (size.x / laneWidth).floor());
    final free = [for (int i = 0; i < laneCount; i++) i].where((i) => !usedLanes.contains(i)).toList();
    final fresh = free.where((i) => !_recentLanes.contains(i)).toList();
    final pool = fresh.isNotEmpty ? fresh : (free.isNotEmpty ? free : [random.nextInt(laneCount)]);
    final lane = pool[random.nextInt(pool.length)];

    usedLanes.add(lane);
    _recentLanes.add(lane);
    // 줄 수의 절반 정도만 기억 (너무 많이 기억하면 고를 줄이 없어짐)
    while (_recentLanes.length > laneCount ~/ 2) {
      _recentLanes.removeAt(0);
    }

    // 줄 안에서 살짝 흔들어 줄 맞춰 떨어지는 느낌이 안 나게
    final laneLeft = (size.x - laneWidth * laneCount) / 2 + lane * laneWidth;
    final x = laneLeft + random.nextDouble() * (laneWidth - cookieSize);
    return x.clamp(0.0, max(0.0, size.x - cookieSize));
  }

  void onCookieTapped(CookieElement cookie) {
    if (isGameOver) return;

    // 정답 판정은 누르는 순간의 문제로 함
    if (cookie.text == _quiz.answer) {
      effect.correctSound();
      solved.value++;
      _celebrate(cookie);
      if (currentIndex.value + 1 >= cookieController.quiz.length) {
        gameOver(cleared: true);
      } else {
        _nextQuestion();
      }
      return;
    }

    // 오답
    cookie.reject();
    _loseLife();
  }

  // 정답 연출: 쿠키가 톡 터지고, 그 자리에서 +1 이 떠오르고, 다람쥐가 좋아함
  void _celebrate(CookieElement cookie) {
    final center = cookie.position.clone();
    cookie.pop();

    add(
      TextComponent(
        text: '+1',
        anchor: Anchor.center,
        position: center,
        priority: 10,
        textRenderer: TextPaint(
          style: TextStyle(
            fontSize: cookieSize * 0.45,
            fontWeight: FontWeight.w900,
            color: const Color(0xFFFFD70D),
            shadows: const [
              Shadow(color: Color(0xFF673E1A), blurRadius: 0, offset: Offset(1.5, 1.5)),
              Shadow(color: Color(0xFF673E1A), blurRadius: 0, offset: Offset(-1.5, -1.5)),
              Shadow(color: Color(0xFF673E1A), blurRadius: 0, offset: Offset(1.5, -1.5)),
              Shadow(color: Color(0xFF673E1A), blurRadius: 0, offset: Offset(-1.5, 1.5)),
            ],
          ),
        ),
      )..addAll([
          MoveByEffect(Vector2(0, -cookieSize * 0.9), EffectController(duration: 0.7, curve: Curves.easeOut)),
          RemoveEffect(delay: 0.7),
        ]),
    );

    cookieController.setWorry(false);
    cookieController.setHappy(true);
    _happyTime = happySeconds;
    _sadTime = 0;
  }

  // 목숨 -1 (오답을 눌렀거나 정답을 놓쳤을 때), 다 떨어지면 게임오버
  void _loseLife() {
    effect.wrongSound();
    _sadTime = sadSeconds;
    _happyTime = 0;
    cookieController.setHappy(false);
    cookieController.setWorry(true);
    lives.value--;
    if (lives.value <= 0) gameOver();
  }

  void _nextQuestion() {
    cookieController.setWorry(false);
    _pickNextQuiz();
    currentIndex.value++;
    _resetAnswerTiming();
  }

  // 정답이 나올 때까지의 다른 쿠키 수를 새로 뽑음
  void _resetAnswerTiming() {
    _sinceAnswer = 0;
    _wrongBeforeAnswer = minWrongBeforeAnswer + random.nextInt(maxWrongBeforeAnswer - minWrongBeforeAnswer + 1);
  }

  // 다음 문제 고르기: 지금 화면에 떨어지고 있는 글자가 정답인 문제는 뒤로 미룸
  // (남은 쿠키와 같은 정답이 또 떨어지는 중복을, 정답 쿠키를 만들 때 확인하는 것과 함께 두 겹으로 막음)
  void _pickNextQuiz() {
    final quiz = cookieController.quiz;
    final next = currentIndex.value + 1;
    final onScreen = _cookies.map((e) => e.text).toSet();
    if (!onScreen.contains(quiz[next].answer)) return;

    // 남은 문제 중 정답이 화면에 없는 첫 문제를 다음 자리로 가져옴 (모두 화면에 있으면 그대로)
    for (int i = next + 1; i < quiz.length; i++) {
      if (!onScreen.contains(quiz[i].answer)) {
        final picked = quiz[i];
        quiz[i] = quiz[next];
        quiz[next] = picked;
        return;
      }
    }
  }

  // 게임 종료 (탭·땅 닿기가 겹쳐도 결과 저장·결과창은 한 번만)
  // 쿠키를 그 자리에 멈추고 '다 모았어요!'/'아쉬워요!'를 잠깐 보여준 뒤 결과창
  Future<void> gameOver({bool cleared = false}) async {
    if (isGameOver) return;
    isGameOver = true;
    bannerText.value = cleared ? '다 모았어요!' : '아쉬워요!';
    cookieController.setHappy(cleared);
    cookieController.setWorry(!cleared);

    // 결과 저장은 멈춰 있는 동안 함께 진행
    final results = await Future.wait([
      resultService(code, solved.value),
      Future.delayed(endPause),
    ]);
    final coin = results[0] as String;

    bannerText.value = '';
    children.whereType<CookieElement>().forEach((element) {
      element.removeFromParent();
    });
    // 결과를 기다리는 동안 화면을 나갔으면 결과창을 띄우지 않음
    final context = buildContext;
    if (context == null || !context.mounted) return;
    resultDialog(
      context,
      solved.value,
      cookieController.quiz.length,
      coin,
      onRetry: () => resultService(code, solved.value),
    );
  }
}
