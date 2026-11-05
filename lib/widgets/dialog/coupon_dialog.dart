import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/services/coupon/coupon_service.dart';
import 'package:hoho_hanja/utils/design_scale.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';

/// 쿠폰 입력 팝업 (크기는 시안 단위, 화면 배율대로)
Future<void> showCouponDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _CouponDialog(),
  );
}

// 소문자로 쳐도 대문자로 바꿔서 받음 (영문·숫자만)
class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

class _CouponDialog extends StatefulWidget {
  const _CouponDialog();

  @override
  State<_CouponDialog> createState() => _CouponDialogState();
}

class _CouponDialogState extends State<_CouponDialog> {
  final _controller = TextEditingController();
  bool _sending = false;

  Future<void> _submit() async {
    if (_sending) return; // 연타 막기
    final code = _controller.text.trim();
    if (code.isEmpty) {
      failDialog('등록 실패', '쿠폰 번호를 입력해주세요.');
      return;
    }
    setState(() => _sending = true);
    final ok = await couponService(code);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(); // 이 팝업만 닫고
      failDialog('쿠폰 등록', '쿠폰이 등록되었습니다.'); // 3초 뒤 저절로 닫히는 안내 (이미 닫았으면 그대로)
    } else {
      setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sc = DesignScale.of(mq.size, mq.padding);
    double d(num v) => sc.d(v);

    Widget button(String text, Color color, VoidCallback? onTap, {double left = 0}) {
      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(left: left),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              height: d(42),
              alignment: Alignment.center,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(d(10))),
              child: Text(text, style: TextStyle(color: mFontWhite, fontSize: d(15))),
            ),
          ),
        ),
      );
    }

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: d(8), vertical: d(24)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(d(20))),
      child: SizedBox(
        width: math.min(d(300), mq.size.width - d(16)),
        child: Padding(
          padding: EdgeInsets.fromLTRB(d(20), d(22), d(20), d(18)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('쿠폰 입력', style: TextStyle(color: primaryColor, fontSize: d(22), fontWeight: FontWeight.bold)),
              Padding(
                padding: EdgeInsets.symmetric(vertical: d(18)),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  enabled: !_sending,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: mFontMain, fontSize: d(17), letterSpacing: d(2)),
                  cursorColor: mFontMain,
                  keyboardType: TextInputType.visiblePassword, // 자동완성·한글 조합 없이 영문·숫자
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  inputFormatters: [
                    _UpperCaseFormatter(),
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                    LengthLimitingTextInputFormatter(9),
                  ],
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: mTextField,
                    contentPadding: EdgeInsets.symmetric(horizontal: d(14), vertical: d(12)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: mTextField, width: d(2)),
                      borderRadius: BorderRadius.circular(d(24)),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: mTextField, width: d(2)),
                      borderRadius: BorderRadius.circular(d(24)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: primaryColor, width: d(1.5)),
                      borderRadius: BorderRadius.circular(d(24)),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  button(_sending ? '등록 중…' : '등록', mBtnActive, _sending ? null : _submit),
                  button('취소', mBtnBack, _sending ? null : () => Navigator.of(context).pop(), left: d(10)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
