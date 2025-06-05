import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/data/models/goods_data.dart';
import 'package:hoho_hanja/utils/contents_lock.dart';

void showUnlockDialog(phase) {
  final coin = Get.find<GoodsDataController>();
  Get.generalDialog(
    barrierDismissible: true,
    barrierLabel: '',
    transitionDuration: Duration(milliseconds: 200),
    pageBuilder: (context, anim1, anim2) {
      final screenHeight = MediaQuery.of(context).size.height;
      final screenWidth = MediaQuery.of(context).size.width;

      return SafeArea(
        // Align으로 전체 화면 안에서 위치 지정
        child: Align(
          alignment: Alignment(0, -0.3), // Y축 음수 → 위쪽
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: Get.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.8,
              // 모서리 둥글게, 배경 흰색
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
              ),
              padding: EdgeInsets.only(
                top: 32,
                left: 24,
                right: 24,
                bottom: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 제목
                  Expanded(
                    flex: screenHeight >= 1000 ? 3 : 2,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(color: mFontMain, fontSize: 22.sp, fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(text: '콘텐츠 잠금 해제', style: TextStyle(color: Color(0xFFE22D72))),
                          TextSpan(text: '를 위해서는\n'),
                          TextSpan(text: '다이아', style: TextStyle(color: Color(0xFFE22D72))),
                          TextSpan(text: '가 필요해요!'),
                        ],
                      ),
                    ),
                  ),
                  // 메시지
                  Expanded(
                    flex: 12,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: Get.height * 0.5,
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xFFF9E6EE),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(0xFFF3CEDD),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Image.asset(
                                        'assets/images/icon/diamond.png',
                                        scale: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Column(
                                  children: [
                                    Text(
                                      '한 번 잠금을 해제한 콘텐츠는\n기기 제한 없이 사용이 가능해요.',
                                      style: TextStyle(color: Color(0xFF323232), fontSize: 20),
                                      textAlign: TextAlign.center,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        '*코인은 캐릭터 꾸미기, 랭킹 등에 사용 가능하며\n잠금 해제는 다이아로만 가능합니다.',
                                        style: TextStyle(color: Color(0xFF939393), fontSize: 12),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    SizedBox(),
                                    Container(
                                      width: screenHeight >= 1000 ? screenWidth * 0.5 : null,
                                      decoration: BoxDecoration(
                                          color: Color(0xFFFFFEF6),
                                          borderRadius: BorderRadius.circular(15),
                                          border: Border.all(color: Color(0xFFD5CBAB))),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 8.0),
                                              child: Text(
                                                '급수별로 필요한 다이아 개수',
                                                style: TextStyle(color: Color(0xFFBD8C4B), fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  _buildColumnItems(column1Items),
                                                  _buildColumnItems(column2Items),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 12.0),
                                      child: RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            color: mFontMain,
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          children: [
                                            TextSpan(text: '현재 보유중인 다이아 개수: '),
                                            TextSpan(
                                                text: '${coin.formattedDia}개',
                                                style: TextStyle(
                                                  color: Color(0xFFE22D72),
                                                )),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // 닫기 버튼
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Get.back(),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: Container(
                              height: 35.h,
                              decoration: BoxDecoration(
                                color: mBtnBack,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '취소',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            contentsUnlock(phase);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Container(
                              height: 35.h,
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '잠금해제',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
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

Widget _buildColumnItems(List<Map<String, String>> items) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: List.generate(items.length, (index) {
      // 첫 번째 항목이 아니라면 위쪽에 Padding을 추가
      return Padding(
        padding: EdgeInsets.only(top: index == 0 ? 0 : 8),
        child: _buildRowItem(items[index]),
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

// 레벨 Badge 스타일 함수
Widget _buildLevelBadge(String level) {
  return Container(
    width: 55.w,
    decoration: BoxDecoration(
      color: const Color(0xFFFFF09E),
      borderRadius: BorderRadius.circular(10),
    ),
    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 12),
    child: Text(
      level,
      style: TextStyle(color: Color(0xFFB68142), fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    ),
  );
}

// 단일 Row를 만들어주는 함수
Widget _buildRowItem(Map<String, String> item) {
  return Row(
    children: [
      _buildLevelBadge(item['level']!),
      const SizedBox(width: 8),
      Text(
        item['count']!,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ],
  );
}

// void unlockDialog(String title, String content) async {
//   List<String> splitContent = content.split(RegExp(r'[.,]')).map((s) => s.trim()).toList();
//   Get.defaultDialog(
//     title: title,
//     middleText: '${splitContent[0]}\n${splitContent[1]}\n${splitContent[2]}',
//     middleTextStyle: const TextStyle(),
//   );
//   Future.delayed(
//     const Duration(seconds: 3),
//     () {
//       Get.back();
//     },
//   );
// }
