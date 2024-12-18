import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/constants.dart';
import 'package:hoho_hanja/_core/size.dart';

class JoinTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String icon;
  final TextFieldType type;
  final FocusNode? focusNode;

  const JoinTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    required this.type,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(gapQuarter),
      child: SizedBox(
        height: 50.h,
        child: TextField(
          focusNode: focusNode,
          controller: controller,
          decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: mFontSub),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: mTextField, width: 2.w),
                borderRadius: BorderRadius.all(Radius.circular(50.r)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: mBoxYellow, width: 2.sp),
                borderRadius: BorderRadius.all(Radius.circular(50.r)),
              ),
              fillColor: mTextField,
              prefixIcon: FittedBox(
                child: Padding(
                  padding: EdgeInsets.all(gapMain),
                  child: Image.asset(icon),
                ),
              )),
          cursorColor: mFontMain,
          keyboardType: _getKeyboardType(type),
          obscureText: type == TextFieldType.password,
          inputFormatters: _getInputFormatters(type),
        ),
      ),
    );
  }

  TextInputType _getKeyboardType(TextFieldType type) {
    switch (type) {
      case TextFieldType.email:
        return TextInputType.emailAddress;
      case TextFieldType.phone:
        return TextInputType.phone;
      case TextFieldType.password:
      case TextFieldType.normal:
      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter> _getInputFormatters(TextFieldType type) {
    if (type == TextFieldType.phone) {
      return [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ];
    }
    return [];
  }
}
