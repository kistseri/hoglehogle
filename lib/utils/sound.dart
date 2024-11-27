import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';

class BackgroundMusic {
  final AudioPlayer _backgroundPlayer = AudioPlayer();

  Future<void> playBackgroundMusic(String page) async {
    try {
      if (page != 'main') {
        await _backgroundPlayer.stop();
      }
      await _backgroundPlayer.setLoopMode(LoopMode.one);
      await _backgroundPlayer.setAsset('assets/bgm/$page.mp3');
      _backgroundPlayer.play();
    } catch (e) {
      Logger().e("배경음악 로드 중 오류 발생: $e");
    }
  }

  Future<void> stopBackgroundMusic() async {
    await _backgroundPlayer.stop();
  }

  Future<void> dispose() async {
    await _backgroundPlayer.dispose();
  }
}

class SoundEffects {
  final AudioPlayer _effectPlayer = AudioPlayer();
  double _volume = 1.0;

  void setVolume(double volume) {
    _volume = volume;
    _effectPlayer.setVolume(_volume);
  }

  Future<void> playFlipSound(String soundUrl) async {
    try {
      await _effectPlayer.setUrl(soundUrl);
      _effectPlayer.play();
    } catch (e) {
      Logger().e("효과음 로드 중 오류 발생: $e");
    }
  }

  Future<void> tapSound() async {
    try {
      await _effectPlayer.setAsset('assets/bgm/click.mp3');
      _effectPlayer.play();
    } catch (e) {
      Logger().e("효과음 로드 중 오류 발생: $e");
    }
  }

  Future<void> correctSound() async {
    if (_effectPlayer.volume > 0) {
      try {
        await _effectPlayer.setAsset('assets/bgm/correct.mp3');
        _effectPlayer.play();
      } catch (e) {
        Logger().e("효과음 로드 중 오류 발생: $e");
      }
    }
  }

  Future<void> wrongSound() async {
    if (_effectPlayer.volume > 0) {
      try {
        await _effectPlayer.setAsset('assets/bgm/no.mp3');
        _effectPlayer.play();
      } catch (e) {
        Logger().e("효과음 로드 중 오류 발생: $e");
      }
    }
  }

  Future<void> dispose() async {
    await _effectPlayer.dispose();
  }
}
