/// 서버 JSON 값 변환 공통 함수 (C-37)
/// 서버가 숫자를 문자열("30")로 보내거나 문자열을 숫자로 보내거나, 값을 비워 보내도
/// TypeError 없이 받도록 모든 모델이 이 함수를 씀.

/// 정수로. 숫자·숫자 문자열("30", "30.0")을 받고, 그 외에는 [fallback]
int jsonInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final s = value.trim();
    return int.tryParse(s) ?? double.tryParse(s)?.toInt() ?? fallback;
  }
  return fallback;
}

/// 문자열로. null이면 [fallback], 숫자 등은 toString()
String jsonStr(dynamic value, [String fallback = '']) {
  if (value == null) return fallback;
  return value.toString();
}
