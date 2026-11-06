import 'package:flutter/material.dart';
import 'package:hoho_hanja/screens/matching/matching_widgets/matching_body.dart';

/// 한자 맞추기 단원 선택 화면 (따라쓰기 TracingScreen과 같은 구조)
class MatchingMenuScreen extends StatelessWidget {
  final String phase;
  final int openPage;
  final bool isUnlocked; // 이 급수 콘텐츠가 열려 있는지

  const MatchingMenuScreen({
    super.key,
    required this.phase,
    required this.openPage,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    // 앱바까지 MatchingBody가 시안 비율대로 직접 그림
    return Scaffold(
      backgroundColor: const Color(0xFFFFFEF0),
      body: MatchingBody(
        phase: phase,
        openPage: openPage,
        isUnlocked: isUnlocked,
      ),
    );
  }
}
