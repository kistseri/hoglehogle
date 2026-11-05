import 'package:flutter/material.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/utils/design_scale.dart';

/// 게임 진행 표시 (남은 목숨 ♥ + 맞힌 문제 수)
///
/// 앱바 바로 아래 가운데에 놓는다: [GameHud.place] 를 Stack 에 그대로 넣으면 됨.
class GameHud extends StatelessWidget {
  final DesignScale scale;
  final int solved;
  final int total;
  final int? lives; // null 이면 목숨 표시 안 함
  final int maxLives;

  const GameHud({
    super.key,
    required this.scale,
    required this.solved,
    required this.total,
    this.lives,
    this.maxLives = 3,
  });

  // 앱바 바로 아래 칸 (시안 y, 높이)
  static const double top = 54;
  static const double height = 26;
  static const double bottom = top + height; // 이 아래부터 게임 내용

  /// 앱바 바로 아래 가운데에 배치
  static Widget place(DesignScale sc, Widget hud) {
    return sc.box(0, top, sc.dw, height, IgnorePointer(child: Center(child: hud)));
  }

  @override
  Widget build(BuildContext context) {
    double d(num v) => scale.d(v);

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Container(
        height: d(height),
        padding: EdgeInsets.symmetric(horizontal: d(10)),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(d(13)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (lives != null)
              for (int i = 0; i < maxLives; i++)
                Padding(
                  padding: EdgeInsets.only(right: d(1)),
                  child: Icon(
                    i < lives! ? Icons.favorite : Icons.favorite_border,
                    size: d(15),
                    color: i < lives! ? const Color(0xFFFF5A5A) : const Color(0xFFBBBBBB),
                  ),
                ),
            Padding(
              padding: EdgeInsets.only(left: lives != null ? d(7) : 0),
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: '$solved', style: const TextStyle(color: primaryColor)),
                    TextSpan(text: '/$total', style: const TextStyle(color: mFontMain)),
                  ],
                ),
                style: TextStyle(fontSize: d(14), fontWeight: FontWeight.bold, height: 1.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
