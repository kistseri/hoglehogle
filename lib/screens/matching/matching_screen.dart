import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/data/models/matching_data.dart';
import 'package:hoho_hanja/main.dart';
import 'package:hoho_hanja/screens/matching/matching_widgets/matching_counter.dart';
import 'package:hoho_hanja/screens/matching/matching_widgets/matching_header.dart';
import 'package:hoho_hanja/screens/matching/matching_widgets/matching_images.dart';
import 'package:hoho_hanja/widgets/appbar/custom_appbar.dart';

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
  final CarouselSliderController carouselController =
      CarouselSliderController();
  final MatchingDataController matchingDataController =
      Get.find<MatchingDataController>();

  int currentIndex = 0;
  int numOfItems = 64;
  List<bool> isFlippedList = [];
  List<String> imgList = [];

  @override
  void initState() {
    super.initState();
    music.playBackgroundMusic('matching');
    numOfItems = widget.openPage ?? matchingDataController.matchingData.length;
    isFlippedList = List<bool>.filled(numOfItems, false);
    imgList = List<String>.generate(numOfItems, (index) {
      if (!isFlippedList[index]) {
        return 'https://sunandtree2.cafe24.com/app/memorize/80/img/8000${index + 1}_b.png';
      }
      return 'https://sunandtree2.cafe24.com/app/memorize/80/img/8000${index + 1}_f.png';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FFF1),
      appBar: const CustomAppBar(),
      body: Padding(
        padding: EdgeInsets.only(bottom: 32.sp),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: MatchingHeader(phase: widget.phase),
            ),
            Expanded(
              flex: 8,
              child: MatchingImages(
                numOfItems: numOfItems,
                carouselController: carouselController,
                onFlip: (index) {
                  if (!isFlippedList[index]) {
                    String soundUrl =
                        matchingDataController.matchingData[index].sound;
                    effect.playFlipSound(soundUrl);
                  }
                  setState(() {
                    isFlippedList[index] = !isFlippedList[index];
                    imgList[index] = isFlippedList[index]
                        ? 'https://sunandtree2.cafe24.com/app/memorize/80/img/8000${index + 1}_f.png'
                        : 'https://sunandtree2.cafe24.com/app/memorize/80/img/8000${index + 1}_b.png';
                  });
                },
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
              ),
            ),
            MatchingCounter(
              currentIndex: currentIndex,
              numOfItems: numOfItems,
            ),
            // MatchingImageSave(
            //   isFlippedList: isFlippedList,
            //   currentIndex: currentIndex,
            // ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    music.stopBackgroundMusic();
    super.dispose();
  }
}
