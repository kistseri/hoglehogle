import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/constants.dart';
import 'package:hoho_hanja/data/models/my_room_data.dart';
import 'package:hoho_hanja/screens/myroom/myroom_wigets/my_room_item.dart';
import 'package:hoho_hanja/services/myroom/my_room_service.dart';

/// 마이룸 아래 판: 카테고리 탭 4개 + 아이템 그리드
class MyroomTab extends StatelessWidget {
  final MyroomItemController itemController;
  final double s; // 시안 → 화면 배율 (앱바와 같음)
  final double bottomPadding; // 홈 바 (화면 px)

  const MyroomTab({
    super.key,
    required this.itemController,
    required this.s,
    required this.bottomPadding,
  });

  static const _brown = Color(0xFF8B5A2B);
  static const _paper = Color(0xFFFFF8E7);

  double d(num v) => v * s;

  @override
  Widget build(BuildContext context) {
    final myroomDataController = Get.put(MyroomDataController());
    return Column(
      children: [
        SizedBox(height: d(40), child: _tabs()),
        Expanded(
          child: ColoredBox(
            color: _paper,
            child: Obx(() {
              final status = myroomDataController.status.value;
              final items = myroomDataController.getDataByCategory(itemController.selectedCategory.value);
              if (myroomDataController.myroomDataList.isEmpty) return Center(child: _emptyState(status));
              return LayoutBuilder(builder: (context, c) {
                // 칸 크기가 휴대폰과 비슷하게 유지되도록 넓으면 줄 수를 늘림 (3~6칸)
                final count = (c.maxWidth / (110 * math.min(s, 1.3))).floor().clamp(3, 6);
                return GridView.builder(
                  padding: EdgeInsets.fromLTRB(d(16), d(12), d(16), d(12) + bottomPadding),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: count,
                    mainAxisSpacing: d(12),
                    crossAxisSpacing: d(12),
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return GestureDetector(
                      onTap: () => itemController.tapItem(item),
                      // 착용 표시는 착용 목록이 바뀔 때마다 다시 그림
                      child: Obx(() => MyroomItem(item: item, isWorn: itemController.isWorn(item))),
                    );
                  },
                );
              });
            }),
          ),
        ),
      ],
    );
  }

  Widget _tabs() {
    return Obx(() {
      final selected = itemController.selectedCategory.value;
      return Row(
        children: [
          for (var i = 0; i < MyroomDataController.categoryIds.length; i++)
            Expanded(child: _tab(i, selected == MyroomDataController.categoryIds[i])),
        ],
      );
    });
  }

  Widget _tab(int index, bool isSelected) {
    final side = BorderSide(color: Colors.brown, width: d(2));
    return GestureDetector(
      onTap: () => itemController.setSelectedCategory(MyroomDataController.categoryIds[index]),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? _paper : const Color(0xFFF99D9D),
          borderRadius: BorderRadius.vertical(top: Radius.circular(d(15))),
          // 고른 탭은 아래 판과 이어지도록 아래 테두리 없음
          border: isSelected ? Border(top: side, left: side, right: side) : Border.fromBorderSide(side),
        ),
        padding: EdgeInsets.all(d(6)),
        child: Image.asset(myroomTab[index], fit: BoxFit.contain),
      ),
    );
  }

  Widget _emptyState(MyroomStatus status) {
    switch (status) {
      case MyroomStatus.loading:
        return const CircularProgressIndicator(color: primaryColor);
      case MyroomStatus.error:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '옷장을 불러오지 못했어요',
              style: TextStyle(color: mFontSub, fontSize: d(14)),
            ),
            Padding(
              padding: EdgeInsets.only(top: d(16)),
              child: ElevatedButton(
                onPressed: myroomService,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: mFontWhite,
                  shape: const StadiumBorder(),
                  padding: EdgeInsets.symmetric(horizontal: d(24), vertical: d(10)),
                ),
                child: Text('다시 시도', style: TextStyle(fontSize: d(14))),
              ),
            ),
          ],
        );
      case MyroomStatus.done:
        return Text(
          '아직 아이템이 없어요',
          style: TextStyle(color: _brown, fontSize: d(14)),
        );
    }
  }
}
