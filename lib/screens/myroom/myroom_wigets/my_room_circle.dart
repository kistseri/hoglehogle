import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/main.dart';
import 'package:hoho_hanja/screens/myroom/myroom_wigets/my_room_item.dart';
import 'package:logger/logger.dart';

class MyRoomCircleAvatar extends StatelessWidget {
  final double size;

  const MyRoomCircleAvatar({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    final itemController = Get.put(MyroomItemController());

    final Map<int, Size> clothesSizeMap = {
      0: Size(120.w, 70.h), // 호랑이
      1: Size(100.w, 48.h), // 토끼
      2: Size(140.w, 70.h), // 곰
      3: Size(110.w, 60.h), // 다람쥐
    };

    final Map<int, double> clothesTopMap = {
      0: 210.h, // 호랑이
      1: 234.h, // 토끼
      2: 210.h, // 곰
      3: 223.h, // 다람쥐
    };

    final Map<int, Size> hatSizeMap = {
      0: Size(80.w, 40.h), // 호랑이
      1: Size(70.w, 40.h), // 토끼
      2: Size(100.w, 50.h), // 곰
      3: Size(60.w, 40.h), // 다람쥐
    };

    final Map<int, double> hatTopMap = {
      0: screenHeight >= 1000 ? 250.h : 80.h,
      1: 800.h,
      2: screenHeight >= 1000 ? 150.h : 80.h,
      3: 250.h,
    };

    return Obx(() {
      final charIndex = itemController.currentCharacter;

      final clothingImg = itemController.clothingImage.value;
      final hatImg = itemController.hatImage.value;
      final charImg = itemController.characterImage.value;
      final bgImg = itemController.backgroundImage.value;

      const double baseSize = 275.0;

      final double scale = size / baseSize;

      final clothesSize = clothesSizeMap[charIndex] ?? const Size(120, 70);

      final hatTop = hatTopMap[charIndex] ?? 210;
      final hatSize = hatSizeMap[charIndex] ?? const Size(120, 70);
      return SizedBox(
        width: size,
        height: size,
        child: ClipOval(
          child: Stack(
            children: [
              // 배경
              bgImg.isNotEmpty
                  ? Image.network(
                      bgImg,
                      width: size,
                      height: size,
                      fit: BoxFit.contain,
                    )
                  : Container(
                      width: size,
                      height: size,
                      color: Colors.grey.shade200,
                    ),
              //캐릭터
              Positioned(
                bottom: 0,
                left: charIndex == 3 ? 0.2 * size : 0,
                right: 0,
                child: Image(
                  image: charImg,
                  height: screenHeight >= 1000 ? size * 0.5.h : size * 0.75.h,
                  fit: BoxFit.contain,
                ),
              ),
              // 모자
              if (hatImg.isNotEmpty)
                Positioned(
                  top: screenHeight >= 1000 ? hatTop * scale * 0.035.h : hatTop * scale * 0.05.h,
                  left: hatImg.substring(hatImg.length - 9, hatImg.length - 4) == 'hat_6' ? 2.w : 0,
                  right: 0,
                  child: Image.network(
                    hatImg,
                    width: hatSize.width * scale,
                    height: screenHeight >= 1000 ? hatSize.height * scale * 0.35.h : hatSize.height * scale,
                    fit: BoxFit.contain,
                  ),
                ),
              // 옷
              if (clothingImg.isNotEmpty)
                Positioned(
                  bottom: screenHeight >= 1000 ? size * 0.05.h : size * 0.08.h,
                  left: 0,
                  right: 0,
                  child: Image.network(
                    clothingImg,
                    height: screenHeight >= 1000 ? clothesSize.height * scale * 0.4.h : clothesSize.height * scale,
                    fit: BoxFit.contain,
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}
