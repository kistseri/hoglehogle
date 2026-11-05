import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/utils/design_scale.dart';

Widget socialLoginButton(String platform, Color color, String title, DesignScale sc) {
  return Container(
    width: double.infinity,
    height: sc.d(50),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(sc.d(50))),
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: sc.d(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: sc.d(25),
            width: sc.d(25),
            child: SvgPicture.asset("assets/images/social/$platform.svg"),
          ),
          Text(
            '$title로 로그인',
            style: TextStyle(color: platform == "kakao" ? mFontMain : mFontWhite, fontSize: sc.d(14)),
          ),
          // 글자가 가운데 오도록 아이콘과 같은 폭
          SizedBox(height: sc.d(25), width: sc.d(25)),
        ],
      ),
    ),
  );
}
