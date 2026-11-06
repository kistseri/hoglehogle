import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hoho_hanja/utils/design_scale.dart';

/// 계산 문제를 맞혀야 [onPassed]가 실행되는 확인 창 (보호자 확인·탈퇴 확인 공용, C-45)
/// 크기는 시안 단위로 화면 배율에 맞춤 (작은 폰·태블릿에서도 같은 비율, C-34)
void showMathGateDialog(BuildContext context, {required String title, required Future<void> Function() onPassed}) {
  if (!context.mounted) return;
  final rand = Random();
  final isSimple = rand.nextBool();

  late String question;
  late int correctAnswer;

  if (isSimple) {
    int num1 = rand.nextInt(999) + 1;
    int num2 = rand.nextInt(999) + 1;
    bool isAddition = rand.nextBool();

    if (!isAddition && num1 < num2) {
      final temp = num1;
      num1 = num2;
      num2 = temp;
    }

    final operator = isAddition ? '+' : '-';
    question = "$num1 $operator $num2";
    correctAnswer = isAddition ? num1 + num2 : num1 - num2;
  } else {
    final a = rand.nextInt(9) + 1;
    final b = rand.nextInt(9) + 1;
    final c = rand.nextInt(9) + 1;
    question = "$a × ($b + $c)";
    correctAnswer = a * (b + c);
  }

  String input = '';
  String? errorText;
  bool sending = false;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext ctx) {
      final sc = DesignScale.fromContext(ctx);
      double d(num v) => sc.d(v);

      return Dialog(
        backgroundColor: Colors.white,
        insetPadding: EdgeInsets.symmetric(horizontal: d(8), vertical: d(24)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(d(20))),
        child: SizedBox(
          width: min(d(300), MediaQuery.sizeOf(ctx).width - d(16)),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: EdgeInsets.fromLTRB(d(16), d(12), d(16), d(18)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 제목 + 닫기
                    SizedBox(
                      height: d(40),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(title, style: TextStyle(fontSize: d(18), fontWeight: FontWeight.bold)),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: sending ? null : () => Navigator.of(ctx).pop(),
                              child: Icon(Icons.clear, size: d(24)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: d(8)),
                      child: Text("문제: $question = ?", style: TextStyle(fontSize: d(17))),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: d(12)),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(d(12)),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(d(8)),
                        ),
                        child: Text(
                          input.isEmpty ? "정답을 입력해주세요." : input,
                          style: TextStyle(fontSize: d(17), fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: d(26),
                      child: Center(
                        child: errorText == null
                            ? null
                            : Text(errorText!, style: TextStyle(color: Colors.red, fontSize: d(13))),
                      ),
                    ),
                    // 키패드 (정사각 버튼)
                    _buildKeypad(
                      d: d,
                      onTap: (value) async {
                        if (sending) return;
                        if (value == '←') {
                          setState(() {
                            if (input.isNotEmpty) input = input.substring(0, input.length - 1);
                          });
                        } else if (value == '확인') {
                          if (int.tryParse(input) == correctAnswer) {
                            setState(() => sending = true);
                            Navigator.of(ctx).pop();
                            await onPassed();
                          } else {
                            setState(() => errorText = "정답이 아닙니다.");
                          }
                        } else {
                          setState(() {
                            if (input.length < 4) input += value;
                            errorText = null;
                          });
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    },
  );
}

Widget _buildKeypad({required double Function(num) d, required void Function(String value) onTap}) {
  const keys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['←', '0', '확인'],
  ];

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (final row in keys)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final key in row)
              Padding(
                padding: EdgeInsets.all(d(4)),
                child: SizedBox(
                  width: d(56),
                  height: d(48),
                  child: CupertinoButton(
                    padding: EdgeInsets.zero,
                    color: CupertinoColors.systemGrey5,
                    borderRadius: BorderRadius.circular(d(8)),
                    onPressed: () => onTap(key),
                    child: Text(
                      key,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: d(key == '확인' ? 16 : 20),
                        fontWeight: FontWeight.w500,
                        color: CupertinoColors.black,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
    ],
  );
}
