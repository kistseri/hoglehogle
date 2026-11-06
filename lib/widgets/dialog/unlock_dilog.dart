import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/data/models/goods_data.dart';
import 'package:hoho_hanja/utils/contents_lock.dart';
import 'package:hoho_hanja/utils/design_scale.dart';

/// 콘텐츠 잠금 해제 안내 창
/// 예전에는 고정 글자 크기(20/12)·고정 여백과 '화면 높이 ≥ 1000' 태블릿 분기가 섞여 있어
/// 작은 폰에서 글자가 버튼과 겹치고 태블릿에서는 작게 보였음.
/// 시안(카드 폭 312) 기준 크기를 화면 배율 하나로만 키우거나 줄이고, 넘치면 스크롤 (C-32·C-34)
void showUnlockDialog(phase) {
  final coin = Get.find<GoodsDataController>();
  Get.generalDialog(
    barrierDismissible: true,
    barrierLabel: '',
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, anim1, anim2) {
      final sc = DesignScale.fromContext(context);
      double d(num v) => sc.d(v);
      final size = MediaQuery.sizeOf(context);
      final padding = MediaQuery.paddingOf(context);

      Widget button(String label, Color color, VoidCallback onTap) {
        return Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: d(4)),
              child: Container(
                height: d(40),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(d(50))),
                child: Text(label, style: TextStyle(color: Colors.white, fontSize: d(16))),
              ),
            ),
          ),
        );
      }

      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: min(d(312), size.width - d(24)),
            constraints: BoxConstraints(maxHeight: size.height - padding.vertical - d(48)),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(d(40))),
            padding: EdgeInsets.fromLTRB(d(20), d(28), d(20), d(16)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 내용이 화면보다 길면(아주 작은 폰) 스크롤
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 제목
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyle(color: mFontMain, fontSize: d(20), fontWeight: FontWeight.bold),
                            children: const [
                              TextSpan(text: '콘텐츠 잠금 해제', style: TextStyle(color: Color(0xFFE22D72))),
                              TextSpan(text: '를 위해서는\n'),
                              TextSpan(text: '다이아', style: TextStyle(color: Color(0xFFE22D72))),
                              TextSpan(text: '가 필요해요!'),
                            ],
                          ),
                        ),
                        // 다이아 그림
                        Padding(
                          padding: EdgeInsets.only(top: d(16)),
                          child: Container(
                            width: d(132),
                            height: d(132),
                            padding: EdgeInsets.all(d(18)),
                            decoration: const BoxDecoration(color: Color(0xFFF9E6EE), shape: BoxShape.circle),
                            child: Container(
                              padding: EdgeInsets.all(d(18)),
                              decoration: const BoxDecoration(color: Color(0xFFF3CEDD), shape: BoxShape.circle),
                              child: Image.asset('assets/images/icon/diamond.png', fit: BoxFit.contain),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: d(16)),
                          child: Text(
                            '한 번 잠금을 해제한 콘텐츠는\n기기 제한 없이 사용이 가능해요.',
                            style: TextStyle(color: const Color(0xFF323232), fontSize: d(16)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: d(8)),
                          child: Text(
                            '*코인은 캐릭터 꾸미기, 랭킹 등에 사용 가능하며\n잠금 해제는 다이아로만 가능합니다.',
                            style: TextStyle(color: const Color(0xFF939393), fontSize: d(11)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        // 급수별 다이아 표
                        Padding(
                          padding: EdgeInsets.only(top: d(12)),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(d(12)),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFEF6),
                              borderRadius: BorderRadius.circular(d(15)),
                              border: Border.all(color: const Color(0xFFD5CBAB)),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '급수별로 필요한 다이아 개수',
                                  style: TextStyle(
                                      color: const Color(0xFFBD8C4B), fontSize: d(13), fontWeight: FontWeight.bold),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: d(10)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildColumnItems(d, column1Items),
                                      _buildColumnItems(d, column2Items),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: d(12)),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(color: mFontMain, fontSize: d(13), fontWeight: FontWeight.bold),
                              children: [
                                const TextSpan(text: '현재 보유중인 다이아 개수: '),
                                TextSpan(
                                  text: '${coin.formattedDia}개',
                                  style: const TextStyle(color: Color(0xFFE22D72)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 버튼 (항상 보이게 스크롤 영역 밖)
                Padding(
                  padding: EdgeInsets.only(top: d(16)),
                  child: Row(
                    children: [
                      button('취소', mBtnBack, () => Get.back()),
                      button('잠금해제', primaryColor, () => contentsUnlock(phase)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
    transitionBuilder: (context, anim1, anim2, child) {
      return FadeTransition(opacity: anim1, child: child);
    },
  );
}

Widget _buildColumnItems(double Function(num) d, List<Map<String, String>> items) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: List.generate(items.length, (index) {
      // 첫 번째 항목이 아니라면 위쪽에 간격
      return Padding(
        padding: EdgeInsets.only(top: index == 0 ? 0 : d(8)),
        child: _buildRowItem(d, items[index]),
      );
    }),
  );
}

final List<Map<String, String>> column1Items = [
  {'level': '8급', 'count': '30개'},
  {'level': '7급', 'count': '30개'},
  {'level': '준6급', 'count': '40개'},
];

// Column 2에 들어갈 데이터
final List<Map<String, String>> column2Items = [
  {'level': '6급', 'count': '45개'},
  {'level': '준5급', 'count': '50개'},
  {'level': '5급', 'count': '55개'},
];

// 레벨 Badge
Widget _buildLevelBadge(double Function(num) d, String level) {
  return Container(
    width: d(56),
    decoration: BoxDecoration(color: const Color(0xFFFFF09E), borderRadius: BorderRadius.circular(d(10))),
    padding: EdgeInsets.symmetric(vertical: d(2)),
    child: Text(
      level,
      style: TextStyle(color: const Color(0xFFB68142), fontSize: d(13), fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    ),
  );
}

// 한 줄 (급수 배지 + 개수)
Widget _buildRowItem(double Function(num) d, Map<String, String> item) {
  return Row(
    children: [
      _buildLevelBadge(d, item['level']!),
      Padding(
        padding: EdgeInsets.only(left: d(8)),
        child: Text(item['count']!, style: TextStyle(fontSize: d(13), fontWeight: FontWeight.bold)),
      ),
    ],
  );
}
