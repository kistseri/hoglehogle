import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/services/matching/save_matching_image.dart';
import 'package:logger/logger.dart';

class MatchingImageSave extends StatelessWidget {
  const MatchingImageSave({
    super.key,
    required this.isFlippedList,
    required this.currentIndex,
  });

  final List<bool> isFlippedList;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: GestureDetector(
        onTap: () async {
          // 이미지 저장
          Logger().d('이미지 저장됨');
          if (!isFlippedList[currentIndex]) {
            await saveImage(
                'https://sunandtree2.cafe24.com/app/memorize/80/img/8000${currentIndex + 1}_f.png');
          } else {
            await saveImage(
                'https://sunandtree2.cafe24.com/app/memorize/80/img/8000${currentIndex + 1}_b.png');
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0.sp),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF9AC4C9),
              borderRadius: BorderRadius.circular(15.sp),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/icon/save.png'),
                Text(
                  '사진으로 저장하기',
                  style: TextStyle(
                      color: mFontWhite,
                      fontSize: 14.0.sp,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
