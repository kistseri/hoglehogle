import 'dart:math' as math;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/data/models/matching_data.dart';
import 'package:hoho_hanja/main.dart';
import 'package:hoho_hanja/screens/matching/matching_widgets/matching_counter.dart';
import 'package:hoho_hanja/screens/matching/matching_widgets/matching_header.dart';
import 'package:hoho_hanja/screens/matching/matching_widgets/matching_images.dart';
import 'package:hoho_hanja/utils/design_scale.dart';
import 'package:hoho_hanja/widgets/appbar/design_app_bar.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';

/// 한자 맞추기 (카드를 넘기며 뒤집어 보기)
///
/// 홈과 같이 시안(360 x 698, 상태바 제외) 좌표를 배율 하나로만 키우거나 줄인다.
class MatchingScreen extends StatefulWidget {
  final String phase;
  final int? openPage;

  const MatchingScreen({
    super.key,
    required this.phase,
    this.openPage,
  });

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  // 시안 좌표
  static const double titleY = 72; // 제목 세로 가운데
  static const double subTitleY = 98;
  static const double cardsY = 375; // 카드 세로 가운데
  static const double maxCardH = 460; // 카드 최대 높이 (폭은 그림 비율로)
  static const double cardGap = 8; // 카드 둘레 여백
  static const double peek = 38; // 양옆에 이전·다음 카드가 보이는 폭 (기기와 관계없이 같게)
  static const double baseShrink = 0.97; // 옆 카드 크기 (가운데 카드 대비, 카드가 최대 크기면 더 줄여서 보이는 폭을 맞춤)
  static const double counterY = 640;
  // 카드 그림 크기 (서버 그림 748 x 1105)
  static const double imageAspect = 748 / 1105;

  final CarouselSliderController carouselController = CarouselSliderController();
  final MatchingDataController matchingDataController = Get.find<MatchingDataController>();
  final AudioPlayer _voicePlayer = AudioPlayer();

  int currentIndex = 0;
  late final int numOfItems;
  late final List<bool> isFlippedList;
  int? _loadedVoice; // 미리 불러 둔 소리의 카드 번호
  bool _showTapHint = true; // 첫 카드 누르기 안내 (처음 뒤집을 때까지)

  @override
  void initState() {
    super.initState();
    music.playBackgroundMusic('matching');
    // 열린 카드 수가 실제 카드 수보다 많거나 음수여도 안전하게
    final count = matchingDataController.matchingData.length;
    numOfItems = (widget.openPage ?? count).clamp(0, count);
    isFlippedList = List<bool>.filled(numOfItems, false);
    _preloadVoice(0);
  }

  // 옆 카드 크기(shrink)가 되는 carousel 축소율
  // (carousel은 옆 카드 크기를 easeOut(1 - 축소율)로 정하므로 거꾸로 구함)
  double _enlargeFactorFor(double shrink) {
    double lo = 0, hi = 1;
    for (int i = 0; i < 30; i++) {
      final mid = (lo + hi) / 2;
      if (Curves.easeOut.transform(mid) < shrink) {
        lo = mid;
      } else {
        hi = mid;
      }
    }
    return 1 - lo;
  }

  // 지금 카드의 소리를 미리 불러 둠 (뒤집을 때 바로 나오도록)
  Future<void> _preloadVoice(int index) async {
    if (index >= numOfItems) return;
    final url = matchingDataController.matchingData[index].sound;
    if (url.isEmpty) return;
    try {
      _loadedVoice = null;
      await _voicePlayer.setUrl(url);
      if (index == currentIndex) _loadedVoice = index;
    } catch (e) {
      Logger().e('맞추기 소리 불러오기 오류: $e');
    }
  }

  Future<void> _playVoice(int index) async {
    try {
      if (_loadedVoice != index) {
        final url = matchingDataController.matchingData[index].sound;
        if (url.isEmpty) return;
        await _voicePlayer.setUrl(url);
        _loadedVoice = index;
      }
      await _voicePlayer.seek(Duration.zero);
      _voicePlayer.play();
    } catch (e) {
      Logger().e('맞추기 소리 재생 오류: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FFF1),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final sc = DesignScale.of(constraints.biggest, mq.padding);
            // 옆 카드가 보이는 폭 = 화면 반 - (한 장 폭 x (1 + 축소율)) / 2 이 peek이 되도록 한 장 폭을 정함
            // 옆 카드가 보이는 폭 = 화면 반 - 한 장 폭 + 옆 카드 크기 x (한 장 폭 반 - 둘레 여백)
            // 이 값이 peek이 되도록 한 장 폭을 정함
            var pageW = (sc.dw / 2 - peek - baseShrink * cardGap) / (1 - baseShrink / 2);
            final cardH = math.min(maxCardH, (pageW - cardGap * 2) / imageAspect);
            pageW = cardH * imageAspect + cardGap * 2;
            // 카드가 최대 크기에 걸린 넓은 화면(태블릿)은 옆 카드를 더 줄여서 같은 폭만 보이게
            final shrink = ((peek - sc.dw / 2 + pageW) / (pageW / 2 - cardGap)).clamp(0.3, 1.0);
            final viewportFraction = pageW / sc.dw;

            return Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  right: 0,
                  child: DesignAppBar(scale: sc, inset: (sc.dw - sc.maxContentWidth) / 3),
                ),
                ...matchingHeader(sc, widget.phase, titleY, subTitleY),
                if (numOfItems == 0)
                  sc.place(
                    cx: sc.dw / 2,
                    cy: cardsY,
                    size: 16,
                    child: Text('준비 중입니다.', style: TextStyle(color: mFontSub, fontSize: sc.d(16))),
                  )
                else ...[
                  Positioned(
                    left: 0,
                    right: 0,
                    top: sc.y(cardsY - cardH / 2 - cardGap),
                    height: sc.d(cardH + cardGap * 2),
                    child: MatchingImages(
                      numOfItems: numOfItems,
                      carouselController: carouselController,
                      viewportFraction: viewportFraction,
                      enlargeFactor: _enlargeFactorFor(shrink),
                      cardGap: sc.d(cardGap),
                      radius: sc.d(27),
                      showTapHint: _showTapHint,
                      tapHintSize: sc.d(56),
                      onFlip: (index) {
                        // 앞면(한자) → 뒷면(그림)으로 뒤집을 때 소리
                        if (!isFlippedList[index]) _playVoice(index);
                        setState(() {
                          isFlippedList[index] = !isFlippedList[index];
                          // 한 번 뒤집어 봤으면 안내는 그만
                          _showTapHint = false;
                        });
                      },
                      onPageChanged: (index) {
                        setState(() {
                          currentIndex = index;
                        });
                        _preloadVoice(index);
                      },
                    ),
                  ),
                  sc.place(
                    cx: sc.dw / 2,
                    cy: counterY,
                    size: 26,
                    child: MatchingCounter(
                      currentIndex: currentIndex,
                      numOfItems: numOfItems,
                      fontSize: sc.d(26),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _voicePlayer.dispose();
    music.stopBackgroundMusic();
    super.dispose();
  }
}
