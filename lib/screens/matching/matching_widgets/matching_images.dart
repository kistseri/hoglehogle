// 이미지의 앞면
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/data/models/matching_data.dart';

class MatchingImages extends StatefulWidget {
  final int numOfItems;
  final CarouselSliderController carouselController;
  final Function(int) onFlip;
  final Function(int) onPageChanged;

  const MatchingImages({
    super.key,
    required this.numOfItems,
    required this.carouselController,
    required this.onFlip,
    required this.onPageChanged,
  });

  @override
  State<MatchingImages> createState() => _MatchingImagesState();
}

class _MatchingImagesState extends State<MatchingImages> {
  final matchingDataController = Get.find<MatchingDataController>();
  late List<bool> isFlippedList;
  late List<String> imgList;
  late List<GlobalKey<FlipCardState>> cardKeys = [];

  @override
  void initState() {
    super.initState();
    cardKeys =
        List.generate(widget.numOfItems, (index) => GlobalKey<FlipCardState>());
    isFlippedList = List<bool>.filled(widget.numOfItems, false);
    imgList = List<String>.generate(widget.numOfItems, (index) {
      return 'https://sunandtree2.cafe24.com/app/memorize/80/img/8000${index + 1}_b.png';
    });
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      carouselController: widget.carouselController,
      options: CarouselOptions(
        height: double.infinity,
        enlargeCenterPage: true,
        enableInfiniteScroll: false,
        onPageChanged: (index, reason) {
          setState(() {
            widget.onPageChanged(index);
          });
        },
        viewportFraction: 0.65.sp,
      ),
      items: List.generate(widget.numOfItems, (index) {
        return Builder(
          builder: (BuildContext context) {
            return Padding(
              padding: EdgeInsets.all(8.0.sp),
              child: FlipCard(
                key: cardKeys[index],
                flipOnTouch: false, // 자동으로 뒤집히지 않도록 설정
                front: GestureDetector(
                  onTap: () {
                    cardKeys[index].currentState?.toggleCard();
                    widget.onFlip(index);
                  },
                  child: preImage(index),
                ),
                back: GestureDetector(
                  onTap: () {
                    cardKeys[index].currentState?.toggleCard();
                    widget.onFlip(index);
                  },
                  child: sufImage(index),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  // 이미지의 앞면
  Widget preImage(int index) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.network(
          matchingDataController.matchingData[index].frontImage,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // 이미지의 뒷면
  Widget sufImage(int index) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.network(
          matchingDataController.matchingData[index].backImage,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
