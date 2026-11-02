import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:logger/logger.dart';

void showParentalDialog(BuildContext context, Function onSuccess) {
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

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext ctx) {
      return AlertDialog(
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        content: SizedBox(
          width: 500,
          height: MediaQuery.of(context).size.height / 2,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                children: [
                  // 위쪽: 문제 및 입력 상태
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Spacer(
                              flex: 1,
                            ),
                            Expanded(
                              flex: 1,
                              child: const Text(
                                "탈퇴 확인",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: GestureDetector(
                                child: Icon(Icons.clear),
                                onTap: () => Navigator.of(ctx).pop(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text("문제: $question = ?", style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              input.isEmpty ? "정답을 입력해주세요." : input,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        if (errorText != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              errorText!,
                              style: const TextStyle(color: Colors.red, fontSize: 14),
                            ),
                          ),
                        //                             onPressed: () => Navigator.of(ctx).pop(),
                      ],
                    ),
                  ),
                  // 아래: 키패드
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      width: 300,
                      child: _buildKeypad(onTap: (value) async {
                        setState(() {
                          if (value == '←') {
                            if (input.isNotEmpty) input = input.substring(0, input.length - 1);
                          } else if (value == '확인') {
                            final answer = int.tryParse(input);
                            if (answer == correctAnswer) {
                              onSuccess();
                              Navigator.of(ctx).pop();
                            } else {
                              errorText = "정답이 아닙니다.";
                            }
                          } else {
                            if (input.length < 4) input += value;
                          }
                        });
                      }),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    },
  );
}

Widget _buildKeypad({required void Function(String value) onTap}) {
  final keys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['←', '0', '확인'],
  ];

  return Column(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: keys.map(
          (row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: row.map((key) {
            return Padding(
              padding: const EdgeInsets.all(4),
              child: SizedBox(
                width: 45.w,
                height: 45.h,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  color: CupertinoColors.systemGrey5,
                  borderRadius: BorderRadius.circular(8),
                  onPressed: () => onTap(key),
                  child: Center(
                    child: Text(
                      key,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: CupertinoColors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    ).toList(),
  );
}
