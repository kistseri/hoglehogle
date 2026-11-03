// 넘겨 보는 카드 목록 (앞면 한자, 뒷면 그림)
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/data/models/matching_data.dart';
import 'package:hoho_hanja/screens/matching/matching_widgets/matching_tap_hint.dart';

class MatchingImages extends StatefulWidget {
  final int numOfItems;
  final CarouselSliderController carouselController;
  final double viewportFraction; // 한 장이 화면 폭에서 차지하는 비율
  final double enlargeFactor; // 옆 카드 축소율
  final double cardGap; // 카드 둘레 여백
  final double radius; // 카드 모서리
  final bool showTapHint; // 첫 카드에 누르기 안내 애니메이션
  final double tapHintSize;
  final Function(int) onFlip;
  final Function(int) onPageChanged;

  const MatchingImages({
    super.key,
    required this.numOfItems,
    required this.carouselController,
    required this.viewportFraction,
    required this.enlargeFactor,
    required this.cardGap,
    required this.radius,
    required this.showTapHint,
    required this.tapHintSize,
    required this.onFlip,
    required this.onPageChanged,
  });

  @override
  State<MatchingImages> createState() => _MatchingImagesState();
}

class _MatchingImagesState extends State<MatchingImages> {
  final matchingDataController = Get.find<MatchingDataController>();
  late final List<GlobalKey<FlipCardState>> cardKeys =
      List.generate(widget.numOfItems, (index) => GlobalKey<FlipCardState>());

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      carouselController: widget.carouselController,
      options: CarouselOptions(
        height: double.infinity,
        enlargeCenterPage: true,
        enlargeFactor: widget.enlargeFactor,
        enableInfiniteScroll: false,
        onPageChanged: (index, reason) => widget.onPageChanged(index),
        viewportFraction: widget.viewportFraction,
      ),
      items: List.generate(widget.numOfItems, (index) {
        void flip() {
          cardKeys[index].currentState?.toggleCard();
          widget.onFlip(index);
        }

        return Padding(
          padding: EdgeInsets.all(widget.cardGap),
          child: FlipCard(
            key: cardKeys[index],
            flipOnTouch: false, // 자동으로 뒤집히지 않도록 설정
            front: GestureDetector(
              onTap: flip,
              child: index == 0 && widget.showTapHint
                  ? Stack(
                      children: [
                        _image(matchingDataController.matchingData[index].frontImage),
                        Align(
                          alignment: const Alignment(0, 0.6),
                          child: MatchingTapHint(size: widget.tapHintSize),
                        ),
                      ],
                    )
                  : _image(matchingDataController.matchingData[index].frontImage),
            ),
            back: GestureDetector(
              onTap: flip,
              child: _image(matchingDataController.matchingData[index].backImage),
            ),
          ),
        );
      }),
    );
  }

  // 카드 한 면 (불러오는 중·실패 표시 포함)
  Widget _image(String url) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(widget.radius)),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : const Center(child: CircularProgressIndicator()),
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.image_not_supported_outlined, color: mFontSub, size: 40),
        ),
      ),
    );
  }
}
