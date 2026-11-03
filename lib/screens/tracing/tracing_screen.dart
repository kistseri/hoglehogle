import 'package:flutter/material.dart';
import 'package:hoho_hanja/screens/tracing/tracing_widgets/tracing_body.dart';

class TracingScreen extends StatelessWidget {
  final String phase;
  final String code;
  final int openPage;
  final bool isUnlocked; // 이 급수 콘텐츠가 열려 있는지

  const TracingScreen({
    super.key,
    required this.phase,
    required this.code,
    required this.openPage,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    // 앱바까지 TracingBody가 시안 비율대로 직접 그림
    return Scaffold(
      backgroundColor: const Color(0xFFFFFEF0),
      body: TracingBody(
        phase: phase,
        code: code,
        openPage: openPage,
        isUnlocked: isUnlocked,
      ),
    );
  }
}
