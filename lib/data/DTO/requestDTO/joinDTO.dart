import 'package:get/get.dart';
import 'package:hoho_hanja/utils/encryption.dart';
import 'package:hoho_hanja/utils/split_string.dart';

class JoinDTO {
  final String email; // controller에서 받아옴
  final String? password; // controller에서 받아옴 + 가공
  final String? nickName; // controller에서 받아옴
  final String? tel1; // 전화번호 앞자리
  final String? tel2; // 전화번호 중간자리
  final String? tel3; // 전화번호 뒷자리
  final String? method;
  final String? snsToken;
  final String? jwtHead;
  final String? token;
  final String? agree1;
  final String? agree2;

  JoinDTO(
      {required this.email,
      this.password,
      this.nickName,
      this.tel1,
      this.tel2,
      this.tel3,
      this.method,
      this.snsToken,
      this.jwtHead,
      this.token,
      this.agree1,
      this.agree2});

  Map<String, dynamic> toJson() => {
        "id": email,
        "pwd": password ?? '',
        "nickname": nickName ?? '',
        "tel1": tel1 ?? '',
        "tel2": tel2 ?? '',
        "tel3": tel3 ?? '',
        "method": method ?? '',
        "snstoken": snsToken ?? '',
        "jwtHead": jwtHead ?? '',
        // TODO(AU-03/SV-11): 서버에서 이 값의 용도 확인 후 실제 token 인자로 교체.
        // 현재 서버가 이 고정값을 검증할 수 있어 임의 변경 시 가입이 막힐 위험이 있어 보류.
        "token": '111111111',
        "agree1": agree1 ?? '',
        "agree2": agree2 ?? '',
      };
}

class JoinReqDTOController extends GetxController {
  JoinDTO? _joinDTO;

  void setJoinDTO({
    required String email,
    String? password,
    String? nickName,
    String? phoneNumber,
    String? method,
    String? snsToken,
    String? jwtHead,
    String? token,
    String? agree1,
    String? agree2,
  }) {
    // 비밀번호가 없는 소셜 가입(예: 애플)은 빈 값을 보낸다.
    // 빈 문자열을 해시하면(sha256("")) 고정된 해시가 '비밀번호'로 저장되어
    // 그 값을 아는 사람이 로그인할 수 있으므로 해시하지 않는다. (서버는 소셜 계정 비밀번호 로그인 거부)
    String shaPassword = (password == null || password.isEmpty)
        ? ''
        : sha256_convertHash(password);

    final phoneNumbers = splitPhoneNumber(phoneNumber ?? "");

    _joinDTO = JoinDTO(
      email: email,
      password: shaPassword,
      nickName: nickName,
      tel1: phoneNumbers['firstNum'],
      tel2: phoneNumbers['middleNum'],
      tel3: phoneNumbers['lastNum'],
      method: method ?? "0",
      snsToken: snsToken,
      jwtHead: jwtHead,
      token: token,
      agree1: agree1,
      agree2: agree2,
    );
    update();
  }

  JoinDTO? get joinDTO => _joinDTO;
}
