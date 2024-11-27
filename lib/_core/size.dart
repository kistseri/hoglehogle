import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 마진 및 간격의 크기
double gapMain = 32.r; // 기본 화면 padding
double gapHalf = 16.r;
double gapQuarter = 8.r;

double gapTiny = 5.r;
double gapXSmall = 10.r;
double gapSmall = 15.r;
double gapMediumSmall = 20.r;
double gapMedium = 25.r;
double gapMediumLarge = 30.r;
double gapLarge = 35.r;
double gapXLarge = 40.r;
double gapHuge = 50.r;

/// 글씨 크기
double fontTiny = 8.sp;
double fontXSmall = 10.0.sp;
double fontSmall = 12.0.sp;
double fontMediumSmall = 14.0.sp;
double fontMedium = 16.0.sp;
double fontMediumLarge = 18.0.sp;
double fontLarge = 20.0.sp;
double fontXLarge = 22.sp;
double fontHuge = 24.0.sp;
double fontMax = 30.0.sp;

/// 화면 최대 width
double getScreenWidth(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

/// 화면 최대 height
double getScreenHeight(BuildContext context) {
  return MediaQuery.of(context).size.height;
}

/// Drawer width
double getDrawerWidth(BuildContext context) {
  return getScreenWidth(context) * 0.6.w;
}
