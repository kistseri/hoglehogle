import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';

class BackgroundMusicController {
  final AudioPlayer _audioPlayer = AudioPlayer();
  double _volume = 0;

  String? _page; // 지금 틀어 둔 배경음 (없으면 null)

  Future<void> playBackgroundMusic(String page) async {
    _page = page;
    // 파일이 없거나 오디오 장치 오류가 나도 화면 진입은 계속되도록 (C-30)
    try {
      await _audioPlayer.setAsset('assets/audio/bgm/$page.mp3');
      // 불러오는 사이 다른 화면이 음악을 끄거나 바꿨으면 재생하지 않음
      if (_page != page) return;
      await _audioPlayer.setLoopMode(LoopMode.one);
      await _audioPlayer.setVolume(_volume);
      _audioPlayer.play();
    } catch (e) {
      Logger().e("배경음 로드 중 오류 발생 ($page): $e");
    }
  }

  /// [page]를 주면 그 음악이 아직 나오고 있을 때만 끔.
  /// 게임 화면은 닫히는 애니메이션이 끝난 뒤 dispose되므로, 그사이 홈이 다시 튼 홈 음악까지 끄지 않도록 자기 이름을 넘김.
  void stopBackgroundMusic([String? page]) {
    if (page != null && page != _page) return;
    _page = null;
    _audioPlayer.stop();
  }

  /// 앱이 백그라운드로 갈 때 잠깐 멈춤 (어느 화면이든 지금 음악 그대로)
  void pauseForBackground() => _audioPlayer.pause();

  /// 앱으로 돌아오면 멈췄던 음악을 다시 (게임 중이면 게임 음악, 끈 상태면 그대로 조용히)
  void resumeFromBackground() {
    if (_page != null) _audioPlayer.play();
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
