import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/utils/design_scale.dart';

class TermsAndPrivacy extends StatelessWidget {
  final DesignScale scale;

  const TermsAndPrivacy({super.key, required this.scale});

  @override
  Widget build(BuildContext context) {
    double d(num v) => scale.d(v);
    final style = TextStyle(color: mFontLightGray, fontSize: d(12));
    return SizedBox(
      height: d(18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => _showTerms(context, '호글호글 이용약관', 'hogulhogul_terms.txt'),
            child: Text('호글호글 이용약관', style: style),
          ),
          VerticalDivider(color: mFontLightGray, thickness: d(1), width: d(16)),
          GestureDetector(
            onTap: () => _showTerms(context, '개인정보 처리방침', 'hogulhogul_privacy.txt'),
            child: Text('개인정보 처리방침', style: style),
          ),
        ],
      ),
    );
  }

  Future<void> _showTerms(BuildContext context, String title, String file) async {
    final content = await rootBundle.loadString('assets/text/$file');
    if (!context.mounted) return;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      pageBuilder: (context, animation, secondaryAnimation) {
        final mq = MediaQuery.of(context);
        final sc = DesignScale.of(mq.size, mq.padding);
        double d(num v) => sc.d(v);
        final availH = mq.size.height - mq.padding.top - mq.padding.bottom;
        return SafeArea(
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: math.min(d(324), mq.size.width - d(16)),
                // 약관이 길어도 화면 안에서 스크롤
                constraints: BoxConstraints(maxHeight: availH * 0.85),
                padding: EdgeInsets.fromLTRB(d(20), d(22), d(20), d(8)),
                decoration: BoxDecoration(color: mBackWhite, borderRadius: BorderRadius.circular(d(16))),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: d(20), fontWeight: FontWeight.bold, color: mFontMain)),
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.only(top: d(12)),
                        child: SingleChildScrollView(
                          child: Text(content, style: TextStyle(color: mFontSub, fontSize: d(12.5), height: 1.5)),
                        ),
                      ),
                    ),
                    Center(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => Navigator.of(context).pop(),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: d(24), vertical: d(12)),
                          child: Text('닫기', style: TextStyle(color: mFontMain, fontSize: d(15))),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
