import 'package:intl/intl.dart';

String formattedDate(String? date) {
  int timeStamp = int.parse(date!);
  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timeStamp);
  DateFormat dateFormat = DateFormat('yyyy/MM/dd HH:mm');
  return dateFormat.format(dateTime);
}

// 1234567 → 1,234,567
String formatNumber(int n) => NumberFormat('#,###').format(n);
