import 'package:flutter/material.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/utils/design_scale.dart';

class PurchaseHeader extends StatelessWidget {
  final DesignScale scale;

  const PurchaseHeader({super.key, required this.scale});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(scale.d(32)),
      child: Text(
        '다이아 충전',
        style: TextStyle(
          color: mFontMain,
          fontSize: scale.d(24),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
