import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/constants.dart';
import 'package:hoho_hanja/screens/auth/auth_widgets/auth_layout.dart';
import 'package:hoho_hanja/utils/design_scale.dart';

class JoinTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String icon;
  final TextFieldType type;
  final FocusNode? focusNode;
  final bool readOnly;

  const JoinTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    required this.type,
    this.focusNode,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final sc = DesignScale.fromContext(context);
    return Padding(
      padding: EdgeInsets.all(sc.d(8)),
      child: SizedBox(
        height: sc.d(50),
        child: TextField(
          focusNode: focusNode,
          controller: controller,
          readOnly: readOnly,
          style: authInputStyle(sc),
          decoration: authInputDecoration(
            sc,
            hintText: hintText,
            icon: icon,
            fillColor: mTextField,
          ),
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
