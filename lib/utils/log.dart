import 'dart:developer' as dev;
import 'package:logger/logger.dart';

class LogcatOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    for (final line in event.lines) {
      // Logcat에서 tag를 쉽게 필터링하려고 level을 name으로 사용
      dev.log(line, name: event.level.name); // I/<level> 태그로 찍힘
    }
  }
}

final log = Logger(
  level: Level.verbose, // 릴리즈에서도 보려면 verbose
  printer: PrettyPrinter(
    noBoxingByDefault: true,
    printTime: true,
  ),
  output: MultiOutput([
    ConsoleOutput(),   // print 도 유지하고 싶으면 둠(선택)
    LogcatOutput(),    // **핵심: Logcat으로 보냄**
  ]),
);