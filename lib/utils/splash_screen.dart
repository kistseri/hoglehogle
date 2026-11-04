import 'package:flutter/material.dart';

// Android 전용 스플래시
// Android 12+ 시스템 스플래시는 로고를 작은 원 안에만 그려서, 시스템 스플래시는 비워두고
// 첫 화면 위에 큰 로고를 덮어 보여준 뒤 사라지게 함 (iOS 네이티브 스플래시와 같은 크기)
class SplashScreen extends StatefulWidget {
  final Widget child; // 스플래시 뒤에서 미리 준비되는 첫 화면
  final Duration duration;

  const SplashScreen({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // 네이티브 스플래시가 splash.png 를 4배 해상도로 보고 그리는 크기 (1204px / 4)
  static const double logoWidth = 301;

  bool _visible = true; // 페이드 아웃 시작
  bool _removed = false; // 페이드 끝나면 위젯 트리에서 뺌

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.duration, () {
      if (mounted) setState(() => _visible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 네이티브 스플래시 배경색과 맞춤 (라이트: 흰색, 다크: 검정)
    final isDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Stack(
      children: [
        widget.child,
        if (!_removed)
          AnimatedOpacity(
            opacity: _visible ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            onEnd: () => setState(() => _removed = true),
            child: Container(
              color: isDark ? Colors.black : Colors.white,
              alignment: Alignment.center,
              child: Image.asset(
                "assets/images/splash.png",
                width: logoWidth < screenWidth * 0.85 ? logoWidth : screenWidth * 0.85,
                fit: BoxFit.contain,
              ),
            ),
          ),
      ],
    );
  }
}
