import 'dart:math' as math;

import 'package:flutter/material.dart';

// 첫 카드에 "눌러서 뒤집기"를 알려 주는 애니메이션 (손가락이 누르고 물결이 퍼짐)
class MatchingTapHint extends StatefulWidget {
  final double size; // 손가락 아이콘 크기

  const MatchingTapHint({super.key, required this.size});

  @override
  State<MatchingTapHint> createState() => _MatchingTapHintState();
}

class _MatchingTapHintState extends State<MatchingTapHint> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    // 카드를 누르는 동작은 터치를 막지 않음
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          // 0~0.3 누르기, 0.3~0.5 떼기, 이후 쉬기
          final press = t < 0.3 ? t / 0.3 : (t < 0.5 ? 1 - (t - 0.3) / 0.2 : 0.0);
          // 누른 순간부터 물결이 퍼짐
          final ripple = t < 0.3 ? 0.0 : math.min(1.0, (t - 0.3) / 0.6);

          return SizedBox(
            width: size * 2,
            height: size * 2,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (ripple > 0)
                  Container(
                    width: size * (0.6 + ripple * 1.2),
                    height: size * (0.6 + ripple * 1.2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.5 * (1 - ripple)),
                      border: Border.all(color: Colors.white.withValues(alpha: 1 - ripple), width: size * 0.05),
                    ),
                  ),
                // 손끝이 물결 가운데에 오도록 아이콘을 오른쪽 아래로
                Transform.translate(
                  offset: Offset(size * 0.25, size * (0.4 + 0.08 * press)),
                  child: Transform.scale(
                    scale: 1 - 0.12 * press,
                    child: Icon(
                      Icons.touch_app,
                      size: size,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black38, blurRadius: size * 0.15)],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
