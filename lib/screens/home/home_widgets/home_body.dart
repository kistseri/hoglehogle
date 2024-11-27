import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/screens/home/home_widgets/home_header.dart';
import 'package:hoho_hanja/screens/home/home_widgets/home_main.dart';

class HomeBody extends StatelessWidget {
  final String grade;

  HomeBody({
    super.key,
    required this.grade,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 70.h,
          decoration: BoxDecoration(
            color: mBoxGreen,
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(100.r),
            ),
          ),
        ),
        Positioned(
          top: 130.h,
          child: Container(
            height: 50.h,
            width: 50.w,
            decoration: BoxDecoration(
              color: mBoxYellow,
            ),
          ),
        ),
        HomeHeader(),
        HomeMain(grade: grade),
        Container()
      ],
    );
  }
}
