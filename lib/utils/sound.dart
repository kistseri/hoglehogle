import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';

class BackgroundMusicController {
  final AudioPlayer _audioPlayer = AudioPlayer();
  double _volume = 0;

  Future<void> playBackgroundMusic(String page) async {
    await _audioPlayer.setAsset('assets/audio/bgm/$page.mp3');
    _audioPlayer.setLoopMode(LoopMode.one);
    _audioPlayer.setVolume(_volume);
    _audioPlayer.play();
  }

  void stopBackgroundMusic() {
    _audioPlayer.stop();
  }

  void setVolume(double volume) {
    _volume = volume;
    _audioPlayer.setVolume(_volume);
  }

  double getVolume() => _volume;

  void dispose() {
    _audioPlayer.dispose();
  }
}

class SoundEffects {
  final AudioPlayer _effectPlayer = AudioPlayer();
  double _volume = 0.0;

  void setVolume(double volume) {
    _volume = volume;
    _effectPlayer.setVolume(_volume);
  }

  double getVolume() => _volume;

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
      await _effectPlayer.setAsset('assets/audio/effect/click.mp3');
      _effectPlayer.play();
    } catch (e) {
      Logger().e("효과음 로드 중 오류 발생: $e");
    }
  }

  Future<void> correctSound() async {
    if (_effectPlayer.volume > 0) {
      try {
        await _effectPlayer.setAsset('assets/audio/effect/correct.mp3');
        _effectPlayer.play();
      } catch (e) {
        Logger().e("효과음 로드 중 오류 발생: $e");
      }
    }
  }

  Future<void> wrongSound() async {
    if (_effectPlayer.volume > 0) {
      try {
        await _effectPlayer.setAsset('assets/audio/effect/no.mp3');
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
