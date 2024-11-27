import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BakeBear extends StatefulWidget {
  final bool isWeep;

  const BakeBear({super.key, required this.isWeep});

  @override
  State<BakeBear> createState() => _BakeBearState();
}

class _BakeBearState extends State<BakeBear> {
  bool _isMouthOpen = true;
  bool _isEyeOpen = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      Duration(milliseconds: 500),
      (timer) {
        if (mounted) {
          setState(() {
            _isMouthOpen = !_isMouthOpen;
            _isEyeOpen = !_isEyeOpen;
          });
        } else {
          _timer?.cancel();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 100.0.h,
      left: 30.0.w,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 0),
        child: widget.isWeep
            ? _isEyeOpen
                ? Image.asset(
                    'assets/images/bake/bake_bear_open_weep.png',
                    key: ValueKey(1),
                    height: 100.h,
                    width: 100.w,
                  )
                : Image.asset(
                    'assets/images/bake/bake_bear_close_weep.png',
                    key: ValueKey(2),
                    height: 100.h,
                    width: 100.w,
                  )
            : _isMouthOpen
                ? Image.asset(
                    'assets/images/bake/bake_bear_open.png', // 입 벌린 이미지
                    key: ValueKey(1),
                    height: 100.0.h,
                    width: 100.0.w,
                  )
                : Image.asset(
                    'assets/images/bake/bake_bear_close.png', // 입 오므린 이미지
                    key: ValueKey(2),
                    height: 100.0.h,
                    width: 100.0.w,
                  ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
