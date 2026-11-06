import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';

class BackgroundMusicController {
  final AudioPlayer _audioPlayer = AudioPlayer();
  double _volume = 0;

  Future<void> playBackgroundMusic(String page) async {
    // 파일이 없거나 오디오 장치 오류가 나도 화면 진입은 계속되도록 (C-30)
    try {
      await _audioPlayer.setAsset('assets/audio/bgm/$page.mp3');
      await _audioPlayer.setLoopMode(LoopMode.one);
      await _audioPlayer.setVolume(_volume);
      _audioPlayer.play();
    } catch (e) {
      Logger().e("배경음 로드 중 오류 발생 ($page): $e");
    }
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

/// 효과음
/// 예전에는 플레이어 1개를 같이 써서 효과음이 연달아 나면 앞의 소리가 끊겼음.
/// 플레이어 몇 개를 돌려 가며 써서 겹쳐 나도 끊기지 않게 함 (C-30)
class SoundEffects {
  static const int _poolSize = 3;
  final List<AudioPlayer> _players = List.generate(_poolSize, (_) => AudioPlayer());
  int _next = 0;
  double _volume = 0.0;

  void setVolume(double volume) {
    _volume = volume;
    for (final p in _players) {
      p.setVolume(_volume);
    }
  }

  double getVolume() => _volume;

  AudioPlayer _takePlayer() {
    final player = _players[_next];
    _next = (_next + 1) % _poolSize;
    return player;
  }

  Future<void> _play(Future<Duration?> Function(AudioPlayer p) load) async {
    if (_volume <= 0) return; // 무음이면 불러오지 않음
    final player = _takePlayer();
    try {
      await player.stop();
      await load(player);
      await player.setVolume(_volume);
      player.play();
    } catch (e) {
      Logger().e("효과음 로드 중 오류 발생: $e");
    }
  }

  Future<void> playFlipSound(String soundUrl) => _play((p) => p.setUrl(soundUrl));

  Future<void> tapSound() => _play((p) => p.setAsset('assets/audio/effect/click.mp3'));

  Future<void> correctSound() => _play((p) => p.setAsset('assets/audio/effect/correct.mp3'));

  Future<void> wrongSound() => _play((p) => p.setAsset('assets/audio/effect/no.mp3'));

  Future<void> dispose() async {
    for (final p in _players) {
      await p.dispose();
    }
  }
}
