import 'package:flutter/material.dart';
import 'package:hoho_hanja/screens/setting/setting_widgets/setting_button.dart';
import 'package:hoho_hanja/utils/design_scale.dart';
import 'package:hoho_hanja/utils/logout.dart';

class LogoutButton extends StatelessWidget {
  final DesignScale scale;

  const LogoutButton({super.key, required this.scale});

  @override
  Widget build(BuildContext context) {
    return SettingButton(scale: scale, text: '로그아웃', onTap: logout);
  }
}
