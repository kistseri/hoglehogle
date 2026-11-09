import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/screens/auth/auth_widgets/auth_layout.dart';

class JoinButton extends StatelessWidget {
  final String text;
  final FutureOr<void> Function() movePage;
  final bool? isEnabled;
  const JoinButton({
    super.key,
    required this.text,
    required this.movePage,
    this.isEnabled,
  });
  @override
  Widget build(BuildContext context) {
    return AuthButton(
      text: text,
      color: isEnabled == true ? mBtnActive : mBtnBack, // Color change based on isEnabled
      onTap: () async {
        if (isEnabled != false) {
          await movePage();
        }
      },
    );
  }
}
