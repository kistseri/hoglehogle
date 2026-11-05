import 'package:flutter/material.dart';
import 'package:hoho_hanja/screens/setting/setting_widgets/setting_button.dart';
import 'package:hoho_hanja/utils/design_scale.dart';
import 'package:hoho_hanja/widgets/dialog/withdraw_dialog.dart';

class WithdrawButton extends StatelessWidget {
  final DesignScale scale;

  const WithdrawButton({super.key, required this.scale});

  @override
  Widget build(BuildContext context) {
    return SettingButton(scale: scale, text: '회원 탈퇴', onTap: () => showWithdrawDialog(context));
  }
}
