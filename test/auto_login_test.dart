import 'package:flutter_test/flutter_test.dart';
import 'package:hoho_hanja/services/auth/login/auto_login.dart';

void main() {
  test('JSON으로 저장하고 그대로 읽음', () {
    final s = encodeStoredLogin('kid@hohoedu.com', 'abc123');
    expect(s, '{"id":"kid@hohoedu.com","pw":"abc123"}');
    final r = decodeStoredLogin(s)!;
    expect(r.id, 'kid@hohoedu.com');
    expect(r.pw, 'abc123');
  });

  test('예전 형식("id 이메일 password 해시")도 읽음 (업데이트 후에도 자동 로그인 유지)', () {
    final r = decodeStoredLogin('id kid@hohoedu.com password abc123')!;
    expect(r.id, 'kid@hohoedu.com');
    expect(r.pw, 'abc123');
  });

  test('공백·특수문자가 있는 값도 JSON이면 안전', () {
    final r = decodeStoredLogin(encodeStoredLogin('a b@x.com', 'p w"\\'))!;
    expect(r.id, 'a b@x.com');
    expect(r.pw, 'p w"\\');
  });

  test('비었거나 형식이 틀리면 null (예전처럼 RangeError 나지 않음)', () {
    for (final bad in [null, '', 'id', 'id kid@hohoedu.com', 'id  password ', '{"id":"a"}', '{"id":"","pw":""}', '[1]', '{bad']) {
      expect(decodeStoredLogin(bad), isNull, reason: '$bad');
    }
  });
}
