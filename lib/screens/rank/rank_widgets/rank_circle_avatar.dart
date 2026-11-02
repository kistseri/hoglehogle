import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hoho_hanja/_core/constants.dart';
import 'package:hoho_hanja/_core/size.dart';
import 'package:hoho_hanja/main.dart';
import 'package:hoho_hanja/screens/myroom/myroom_wigets/my_room_item.dart'; // 맵 재사용
import 'package:hoho_hanja/data/models/rank_data.dart';
import 'package:logger/logger.dart'; // RankData 정의 파일로 분리 권장

class RankCircleAvatar extends StatelessWidget {
  final RankData data;
  final double size;

  const RankCircleAvatar({
    super.key,
    required this.data,
    this.size = 100,
  });

  bool _isHttp(String? url) => url != null && url.startsWith('http');

  @override
  Widget build(BuildContext context) {
    final charIndex = int.parse(data.characterImage!);
    Logger().d(charIndex);
    Logger().d(characterList[charIndex].assetName);
    const double baseSize = 275.0;
    final double scale = size / baseSize;

    final Map<int, Size> clothesSizeMap = {
      0: Size(120.w, 70.h), // 호랑이
      1: Size(100.w, 48.h), // 토끼
      2: Size(140.w, 70.h), // 곰
      3: Size(110.w, 60.h), // 다람쥐
    };

    final Map<int, double> clothesTopMap = {
      0: 210.h, // 호랑이
      1: 170.h, // 토끼
      2: 210.h, // 곰
      3: 200.h, // 다람쥐
    };

    final Map<int, Size> hatSizeMap = {
      0: Size(80.w, 40.h), // 호랑이
      1: Size(70.w, 40.h), // 토끼
      2: Size(100.w, 50.h), // 곰
      3: Size(60.w, 40.h), // 다람쥐
    };

    final Map<int, double> hatTopMap = {
      4: screenHeight >= 1000 ? 250.h : 80.h,
      1: 800.h,
      2: screenHeight >= 1000 ? 150.h : 80.h,
      3: 250.h,
    };

    final clothesSize = MyroomItemController.clothesSizeMap[charIndex] ?? Size(120.w, 70.h);
    final hatSize = MyroomItemController.hatSizeMap[charIndex] ?? Size(80.w, 40.h);
    final clothesTop = clothesTopMap[charIndex] ?? 210.h;
    final hatTop = hatTopMap[charIndex] ?? 80.h;

    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: Stack(
          children: [
            // 배경
            if (_isHttp(data.backgroundImage))
              Image.network(
                data.backgroundImage!,
                width: size,
                height: size,
                fit: BoxFit.cover,
              )
            else
              Container(width: size, height: size, color: Colors.grey.shade200),

            // 캐릭터
            Positioned(
              bottom: 0,
              left: charIndex == 3 ? 0.2 * size : 0, // 다람쥐 좌측 보정
              right: 0,
              child: Image.asset(
                characterList[charIndex].assetName,
                height:screenHeight >= 1000 ? size * 0.475.h : size * 0.75.h,
                fit: BoxFit.contain,
              ),
            ),

            // 모자
            if (_isHttp(data.hatImage) && data.hatImage!.isNotEmpty)
              Positioned(
                top: screenHeight >= 1000 ? hatTop * scale * 0.2.h : hatTop * scale * 0.05.h,
                left: (() {
                  final url = data.hatImage!;
                  return (url.length >= 9 && url.substring(url.length - 9, url.length - 4) == 'hat_6') ? 5.w : 0.0;
                })(),
                right: 0,
                child: Image.network(
                  data.hatImage!,
                  width: hatSize.width * scale,
                  height: screenHeight >= 1000 ? hatSize.height * scale * 0.35.h : hatSize.height * scale,
                  fit: BoxFit.contain,
                ),
              ),

            // 옷
            if (_isHttp(data.clothesImage) && data.clothesImage!.isNotEmpty)
              Positioned(
                bottom: screenHeight >= 1000 ? clothesTop * scale * 0.026.h : clothesTop * scale* 0.09.h,
                left: 0,
                right: 0,
                child: Image.network(
                  data.clothesImage!,
                  height: screenHeight >= 1000 ? clothesSize.height * scale * 0.4.h : clothesSize.height * scale,
                  fit: BoxFit.contain,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
