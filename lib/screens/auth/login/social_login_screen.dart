import 'package:flutter/material.dart';
import 'package:hoho_hanja/screens/auth/auth_widgets/auth_layout.dart';
import 'package:hoho_hanja/screens/auth/login/login_widgets/social_login.dart';
import 'package:hoho_hanja/utils/design_scale.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final sc = DesignScale.fromContext(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AuthSheetLayout(
        scale: sc,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.only(top: sc.d(25)),
              child: Text(
                '호글호글과 함께\n한자모험을 떠나요!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: sc.d(24), fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: sc.d(10)),
              child: Text(
                '한자의 의미시각화부터 급수시험까지',
                style: TextStyle(color: const Color(0xFFAAAAAA), fontSize: sc.d(10)),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: sc.d(25)),
              child: socialLogin(context, sc),
            ),
          ],
        ),
      ),
    );
  }
}
