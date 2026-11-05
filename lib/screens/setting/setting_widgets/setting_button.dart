import 'package:flutter/material.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/utils/design_scale.dart';

/// 설정 화면 큰 버튼 (쿠폰·로그아웃·탈퇴), 시안 단위 크기
class SettingButton extends StatelessWidget {
  final DesignScale scale;
  final String text;
  final IconData? icon;
  final Color? color; // 채운 버튼 색 (없으면 회색 테두리 버튼)
  final VoidCallback onTap;

  const SettingButton({
    super.key,
    required this.scale,
    required this.text,
    required this.onTap,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    double d(num v) => scale.d(v);
    final textColor = color == null ? mFontSub : mFontWhite;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: d(46),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(d(10)),
          border: color == null ? Border.all(color: Colors.grey, width: d(1)) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Padding(padding: EdgeInsets.only(right: d(6)), child: Icon(icon, color: textColor, size: d(20))),
            Text(text, style: TextStyle(color: textColor, fontSize: d(15))),
          ],
        ),
      ),
    );
  }
}
