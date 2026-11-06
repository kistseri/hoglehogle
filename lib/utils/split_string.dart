/// 휴대폰 번호(숫자만)를 앞·중간·끝으로 나눔
/// 11자리(010-1234-5678)와 10자리(011-123-4567) 모두 처리. 그 외 길이는 빈 값. (C-26)
Map<String, String> splitPhoneNumber(String phoneNumber) {
  final digits = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.length == 11) {
    return {
      'firstNum': digits.substring(0, 3), // 첫 3자리
      'middleNum': digits.substring(3, 7), // 중간 4자리
      'lastNum': digits.substring(7, 11), // 마지막 4자리
    };
  }
  if (digits.length == 10) {
    return {
      'firstNum': digits.substring(0, 3), // 첫 3자리
      'middleNum': digits.substring(3, 6), // 중간 3자리
      'lastNum': digits.substring(6, 10), // 마지막 4자리
    };
  }
  return {
    'firstNum': '',
    'middleNum': '',
    'lastNum': '',
  };
}
