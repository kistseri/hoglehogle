import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

List<String> getSocialPlatforms() {
  if (Platform.isIOS) {
    return [
      "local",
      "apple",
      "kakao",
      // "naver",
    ];
  } else if (Platform.isAndroid) {
    return [
      "local",
      "google",
      "kakao",
      // "naver",
    ];
  }
  return ["local"]; // 기본값 (웹이나 다른 플랫폼일 경우)
}

final List<Map<String, dynamic>> iconData = [
  {
    'icon': Icons.circle,
    'color': Colors.amber,
    'size': 30.sp,
    'top': 135.h,
    'left': 35.w
  },
  {
    'icon': Icons.circle,
    'color': Colors.amber,
    'size': 15.sp,
    'top': 165.h,
    'left': 20.w
  },
  {
    'icon': Icons.circle,
    'color': Colors.lightGreen,
    'size': 7.5.sp,
    'top': 400.h,
    'left': 15.w
  },
  {
    'icon': Icons.star,
    'color': Colors.white,
    'size': 10.sp,
    'top': 520.h,
    'left': 35.w
  },
  {
    'icon': Icons.star,
    'color': Colors.amber,
    'size': 20.sp,
    'top': 160.h,
    'left': 300.w
  },
  {
    'icon': Icons.circle,
    'color': Colors.lightGreen,
    'size': 10.sp,
    'top': 180.h,
    'left': 325.w
  },
  {
    'icon': Icons.star,
    'color': Colors.white,
    'size': 25.sp,
    'top': 520.h,
    'left': 300.w
  },
  {
    'icon': Icons.circle,
    'color': Colors.amber,
    'size': 10.sp,
    'top': 505.h,
    'left': 325.w
  },
];

const List<Color> gridColors = [
  Color(0xFFC7E7C1),
  Color(0xFFF8EA8D),
  Color(0xFFEFD6DD),
  Color(0xFFAAE4DA),
  Color(0xFFCBD8EE),
  Color(0xFFFFDCD0),
  Color(0xFFE5D0F0),
  Color(0xFFDFF2B1),
  Color(0xFFC7E7C1),
  Color(0xFFF8EA8D),
  Color(0xFFEFD6DD),
  Color(0xFFAAE4DA),
];
const List<Color> gridInsideColors = [
  Color(0xFF8FBC86),
  Color(0xFFF1C64F),
  Color(0xFFDA9DAE),
  Color(0xFF6FC1B3),
  Color(0xFF94AFDC),
  Color(0xFFEAA993),
  Color(0xFFD1B3E0),
  Color(0xFFAECA69),
  Color(0xFF8FBC86),
  Color(0xFFF1C64F),
  Color(0xFFDA9DAE),
  Color(0xFF6FC1B3),
];
const List<Color> gridElement = [
  Color(0xFF407237),
  Color(0xFFE48100),
  Color(0xFFC7607D),
  Color(0xFF389988),
  Color(0xFF5277B5),
  Color(0xFFD47F62),
  Color(0xFF966BAD),
  Color(0xFF85A33A),
  Color(0xFF407237),
  Color(0xFFE48100),
  Color(0xFFC7607D),
  Color(0xFF389988),
];

const List<AssetImage> bakeIcons = [
  AssetImage('assets/images/bake/bake_b01.png'),
  AssetImage('assets/images/bake/bake_b02.png'),
  AssetImage('assets/images/bake/bake_b03.png'),
  AssetImage('assets/images/bake/bake_b04.png'),
  AssetImage('assets/images/bake/bake_b05.png'),
  AssetImage('assets/images/bake/bake_b06.png'),
  AssetImage('assets/images/bake/bake_b07.png'),
  AssetImage('assets/images/bake/bake_b08.png'),
  AssetImage('assets/images/bake/bake_b09.png'),
  AssetImage('assets/images/bake/bake_b10.png'),
  AssetImage('assets/images/bake/bake_b11.png'),
  AssetImage('assets/images/bake/bake_b12.png'),
  AssetImage('assets/images/bake/bake_b13.png'),
];

Map<String, String> grades = {
  "80": "8급",
  "70": "7급",
  "62": "준6급",
  "60": "6급",
  "52": "준5급",
  "50": "5급",
};
Map<String, String> alias = {
  "80": "수재",
  "70": "신동",
  "62": "천재",
  "60": "박사",
  "52": "한스쿨1",
  "50": "한스쿨2",
};

Map<String, String> contentsCodes = {
  "tracing": "10",
  "matching": "15",
  "define": "20",
  "bake": "25",
  "cookie": "30",
  "idiom": "35",
};

enum TextFieldType { email, password, phone, normal }

class GetCurrentYM {
  static final currentYM = DateTime.now();
  static final DateFormat formattedYM = DateFormat('yyyyMM');
  static final String ym = formattedYM.format(currentYM);
}

const List<String> myroomTab = [
  'assets/images/myroom/myroom_menu1.png',
  'assets/images/myroom/myroom_menu2.png',
  'assets/images/myroom/myroom_menu3.png',
  'assets/images/myroom/myroom_menu4.png',
];

const List<AssetImage> charcater = [
  AssetImage('assets/images/myroom/tiger.png'),
  AssetImage('assets/images/myroom/bear.png'),
  // AssetImage('assets/images/myroom/squirrel.png'),
  // AssetImage('assets/images/myroom/rabbit.png'),
];
