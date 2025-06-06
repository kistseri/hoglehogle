import 'package:flutter/material.dart';
import 'package:hoho_hanja/screens/tracing/tracing_widgets/tracing_body.dart';
import 'package:hoho_hanja/widgets/appbar/custom_appbar.dart';

class TracingScreen extends StatelessWidget {
  final String phase;
  final String code;
  final int openPage;
  final bool isLocked;

  const TracingScreen({
    super.key,
    required this.phase,
    required this.code,
    required this.openPage,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFEF0),
      appBar: const CustomAppBar(),
      body: TracingBody(
        phase: phase,
        code: code,
        openPage: openPage,
        isLocked: isLocked,
      ),
    );
  }
}
