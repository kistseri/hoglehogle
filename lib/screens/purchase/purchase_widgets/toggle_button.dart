import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hoho_hanja/_core/colors.dart';

class ToggleButton extends StatefulWidget {
  const ToggleButton({super.key});

  @override
  State<ToggleButton> createState() => _ToggleState();
}

class _ToggleState extends State<ToggleButton> {
  bool _isToggled = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            setState(
                  () {
                _isToggled = !_isToggled;
              },
            );
          },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: mBackWhite,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '다이아 이용 안내',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                  Icon(_isToggled ? Icons.expand_more : Icons.expand_less),
                ],
              ),
            ),
          ),
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          height: _isToggled ? 75.h : 0,
          curve: Curves.easeInOut,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(color: mBackWhite),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '- 충전된 다이아는 호글호글 한자탐험 앱 내에서 사용할 수 있습니다.',
                    style: TextStyle(fontSize: 10.sp),
                  ),
                  Text(
                    '- 충전된 다이아와 해제한 콘텐츠는 별도의 유효기한이 없이 사용이 가능합니다.',
                    style: TextStyle(fontSize: 10.sp),
                  ),
                  Text(
                    Platform.isAndroid
                        ? '- Google Play결제로 구매하신 경우, Google Play 고객센터를 통해서\n  구매를 취소할 수 있습니다.'
                        : '- iOS 앱에서 충전한 다이아의 구매취소는 App Store 정책 상\n  Apple 고객센터를 통해서만 취소가 가능합니다.',
                    style: TextStyle(fontSize: 10.sp),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}