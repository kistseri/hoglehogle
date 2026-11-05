import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/utils/design_scale.dart';

/// 결제 화면 맨 아래 '다이아 이용 안내' (눌러서 펼치기)
///
/// 흰 바탕은 화면 끝까지 깔고, 글자는 안드로이드 내비게이션 바·홈 표시줄 위에 오게 아래 여백을 둠.
class ToggleButton extends StatefulWidget {
  final DesignScale scale;

  const ToggleButton({super.key, required this.scale});

  @override
  State<ToggleButton> createState() => _ToggleState();
}

class _ToggleState extends State<ToggleButton> {
  bool _isToggled = false;

  @override
  Widget build(BuildContext context) {
    final sc = widget.scale;
    double d(num v) => sc.d(v);
    final bodyStyle = TextStyle(fontSize: d(10), color: mFontMain);

    return ColoredBox(
      color: mBackWhite,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
        child: Center(
          child: SizedBox(
            width: d(DesignScale.designWidth),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _isToggled = !_isToggled),
                  child: Padding(
                    padding: EdgeInsets.all(d(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('다이아 이용 안내', style: TextStyle(fontSize: d(16), color: mFontMain)),
                        Icon(_isToggled ? Icons.expand_more : Icons.expand_less, size: d(24)),
                      ],
                    ),
                  ),
                ),
                // 펼친 내용 (글자 줄 수에 맞춰 높이가 정해져 넘치지 않음)
                ClipRect(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    alignment: Alignment.topCenter,
                    child: !_isToggled
                        ? const SizedBox(width: double.infinity)
                        : Padding(
                            padding: EdgeInsets.fromLTRB(d(8), 0, d(8), d(8)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('- 충전된 다이아는 호글호글 한자탐험 앱 내에서 사용할 수 있습니다.', style: bodyStyle),
                                Text('- 충전된 다이아와 해제한 콘텐츠는 별도의 유효기한이 없이 사용이 가능합니다.', style: bodyStyle),
                                Text(
                                  Platform.isAndroid
                                      ? '- Google Play결제로 구매하신 경우, Google Play 고객센터를 통해서\n  구매를 취소할 수 있습니다.'
                                      : '- iOS 앱에서 충전한 다이아의 구매취소는 App Store 정책 상\n  Apple 고객센터를 통해서만 취소가 가능합니다.',
                                  style: bodyStyle,
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
