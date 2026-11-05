import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:hoho_hanja/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Box box;
  setUpAll(() async {
    Hive.init(Directory.systemTemp.createTempSync('vol').path);
    box = await Hive.openBox('settingBox');
  });

  test('저장한 소리 크기를 앱 시작 때 복원', () async {
    await box.put('bgmVolume', 0.4);
    await box.put('effectVolume', 0.7);
    restoreVolumes(box);
    expect(music.getVolume(), 0.4);
    expect(effect.getVolume(), 0.7);
  });

  test('예전 버전의 효과음 값(0~10)은 0~1로 바꿔 저장', () async {
    await box.put('effectVolume', 8.0);
    restoreVolumes(box);
    expect(effect.getVolume(), closeTo(0.8, 1e-9));
    expect(box.get('effectVolume'), closeTo(0.8, 1e-9));
  });

  test('저장값이 없거나 이상하면 0', () async {
    await box.clear();
    await box.put('bgmVolume', 'x');
    restoreVolumes(box);
    expect(music.getVolume(), 0);
    expect(effect.getVolume(), 0);
  });
}
