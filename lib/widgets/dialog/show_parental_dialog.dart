import 'package:flutter/material.dart';
import 'package:hoho_hanja/widgets/dialog/math_gate_dialog.dart';

/// 결제·외부 링크 전 보호자 확인 (계산 문제). 맞히면 창을 닫고 [onSuccess] 실행
/// 탈퇴 확인 창과 같은 공용 위젯 사용 (C-45), 화면 배율에 맞춤 (C-34)
void showParentalDialog(BuildContext context, Function onSuccess) {
  showMathGateDialog(context, title: '보호자 확인', onPassed: () async {
    await onSuccess();
  });
}
