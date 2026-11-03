import 'dart:async';

import 'package:flutter/material.dart';

// 곰 (입·눈을 0.5초마다 바꿈, 판이 거의 차면 우는 얼굴). 크기는 놓는 쪽에서 정함
class BakeBear extends StatefulWidget {
  final bool isWeep;

  const BakeBear({super.key, required this.isWeep});

  @override
  State<BakeBear> createState() => _BakeBearState();
}

class _BakeBearState extends State<BakeBear> {
  bool _isOpen = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) setState(() => _isOpen = !_isOpen);
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.isWeep
        ? (_isOpen ? 'bake_bear_open_weep' : 'bake_bear_close_weep')
        : (_isOpen ? 'bake_bear_open' : 'bake_bear_close');
    return Image.asset(
      'assets/images/bake/$name.png',
      fit: BoxFit.contain,
      // 그림을 바꿀 때 깜빡이지 않도록
      gaplessPlayback: true,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
