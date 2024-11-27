import 'package:flutter/material.dart';
import 'package:hoho_hanja/_core/colors.dart';

class DashedHorizontalDivider extends StatelessWidget {
  final double height;
  final Color color;

  const DashedHorizontalDivider({
    super.key,
    this.height = 1.0,
    this.color = mFontLightGray,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();

        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color),
              ),
            );
          }),
        );
      },
    );
  }
}
