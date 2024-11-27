import 'package:flutter/material.dart';
import 'package:hoho_hanja/screens/auth/login/social_login_screen.dart';
import 'package:hoho_hanja/utils/setup_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // 초기화 작업을 수행하는 Future
  Future<void> _initializeApp() async {
    setupTheme();
    await Future.delayed(Duration(seconds: 3));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeApp(),
      builder: (context, snapshot) {
        // 초기화가 완료되면 실제 앱을 보여줌
        if (snapshot.connectionState == ConnectionState.done) {
          return LoginScreen(); // 초기화 후 보여줄 메인 화면
        } else {
          // 초기화 중일 때 로딩 화면
          return Scaffold(
            body: Center(
              child: Image.asset(
                "assets/images/splash.png",
                fit: BoxFit.fill,
              ), // 스플래시 화면에 사용할 위젯
            ),
          );
        }
      },
    );
  }
}
