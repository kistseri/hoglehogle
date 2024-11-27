import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/screens/auth/login/login_widgets/social_login.dart';

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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Image.asset(
            'assets/images/login_bg.png',
            fit: BoxFit.fill,
          ),
          Column(
            children: [
              Expanded(
                flex: 30,
                child: Container(
                  width: double.infinity,
                  height: 200.h,
                  color: Colors.transparent,
                ),
              ),
              Expanded(
                flex: 75,
                child: Container(
                  decoration: BoxDecoration(
                    color: mBackWhite,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30.r),
                      topRight: Radius.circular(30.r),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 25.h),
                        Text(
                          '호글호글과 함께',
                          style: TextStyle(
                              fontSize: 24.sp, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '한자모험을 떠나요!',
                          style: TextStyle(
                              fontSize: 24.sp, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          '한자의 의미시각화부터 급수시험까지',
                          style: TextStyle(
                              color: Color(0xFFAAAAAA), fontSize: 10.sp),
                        ),
                        SizedBox(height: 25.h),
                        socialLogin(context)
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
