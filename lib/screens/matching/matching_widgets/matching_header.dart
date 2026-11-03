import 'package:flutter/material.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/constants.dart';
import 'package:hoho_hanja/utils/design_scale.dart';

// 제목·부제 (시안 좌표 titleY·subTitleY에 가운데 정렬)
List<Widget> matchingHeader(DesignScale sc, String phase, double titleY, double subTitleY) {
  return [
    sc.place(
      cx: sc.dw / 2,
      cy: titleY,
      size: 24,
      child: Text(
        '${grades[phase] ?? ''} 한자 맞추기',
        style: TextStyle(color: mFontMain, fontSize: sc.d(24), fontWeight: FontWeight.bold),
      ),
    ),
    sc.place(
      cx: sc.dw / 2,
      cy: subTitleY,
      size: 15,
      child: Text(
        '카드를 뒤집어 한자를 맞혀보세요',
        style: TextStyle(color: mFontSub, fontSize: sc.d(15)),
      ),
    ),
  ];
}
