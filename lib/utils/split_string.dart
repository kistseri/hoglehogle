Map<String, String> splitPhoneNumber(String phoneNumber) {
  if (phoneNumber.length == 11) {
    return {
      'firstNum': phoneNumber.substring(0, 3), // 첫 3자리
      'middleNum': phoneNumber.substring(3, 7), // 중간 4자리
      'lastNum': phoneNumber.substring(7, 11), // 마지막 4자리
    };
  }
  return {
    'firstNum': '',
    'middleNum': '',
    'lastNum': '',
  };
}
