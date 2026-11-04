import 'package:flutter/material.dart';
import 'package:hoho_hanja/_core/constants.dart';

/// 캐릭터 + 모자·옷·배경을 동그라미 안에 그리는 아바타 (랭킹 등)
///
/// 마이룸 화면에서 옷을 입히는 배치(마이룸 단위: 화면 폭 360, 캐릭터 키 200)를 그대로 축소해서 그림.
/// 그래서 마이룸에서 입은 모습과 똑같고, 모든 위치·크기가 아바타 크기 [size] 기준이라 기기와 상관없이 같게 보임.
class CharacterAvatar extends StatelessWidget {
  final int characterIndex; // characterList 순서 (호랑이, 토끼, 곰, 다람쥐)
  final String? backgroundUrl;
  final String? hatUrl;
  final String? clothesUrl;
  final double size;

  const CharacterAvatar({
    super.key,
    required this.characterIndex,
    this.backgroundUrl,
    this.hatUrl,
    this.clothesUrl,
    required this.size,
  });

  // ── 마이룸 단위 (캐릭터 위쪽 = 0, 캐릭터 키 = 200, 화면 폭 = 360, 가운데 = 180) ──
  static const double roomWidth = 360;
  static const double characterHeight = 200;
  static const List<double> characterLeft = [0, 0, 0, 55]; // 다람쥐는 그림이 왼쪽으로 치우쳐 있어서 오른쪽으로
  static const List<double> hatTop = [-20, 30, -20, -20];
  static const double hatHeight = 40;
  static const List<double> clothesTop = [110, 134, 110, 123];
  static const List<double> clothesHeight = [70, 50, 70, 60];

  // 동그라미 안에서 캐릭터 키 (아바타 크기 대비)와 캐릭터 아래쪽 위치
  static const double characterRatio = 0.75;

  static int safeIndex(int i) => (i >= 0 && i < characterList.length) ? i : 0;

  // 모자별 위치 보정 (마이룸과 같음): 파일 이름 hat_6 → 오른쪽, hat_9 → 왼쪽, hat_8 → 아래
  static ({double dx, double dy}) hatAdjust(String url) {
    switch (_fileName(url)) {
      case 'hat_6':
        return (dx: 10, dy: 0);
      case 'hat_9':
        return (dx: -10, dy: 0);
      case 'hat_8':
        return (dx: 0, dy: 5);
      default:
        return (dx: 0, dy: 0);
    }
  }

  // 옷별 크기 보정 (파일 이름 → 배율, 위쪽(목) 위치는 그대로)
  static final Map<String, double> clothesScale = {
    'KakaoTalk_20241128_144348851_04': 1.1, // 남색 셔츠 + 노란 반바지
  };

  // 옷별 가로 위치 보정 (파일 이름 → 마이룸 단위, 음수 = 왼쪽)
  static final Map<String, double> clothesShift = {
    'KakaoTalk_20241128_144348851_04': -1, // 남색 셔츠 + 노란 반바지
  };

  static String _fileName(String url) => RegExp(r'([^/]+)\.\w+$').firstMatch(url)?.group(1) ?? '';

  bool _isHttp(String? url) => url != null && url.startsWith('http');

  @override
  Widget build(BuildContext context) {
    final i = safeIndex(characterIndex);
    final k = size * characterRatio / characterHeight; // 마이룸 단위 → 화면
    final roomLeft = size / 2 - roomWidth / 2 * k; // 마이룸 화면 왼쪽 끝 (동그라미 밖까지)
    final charTop = size * (1 - characterRatio); // 캐릭터 발이 동그라미 아래에 닿게

    // 마이룸 좌표 (가로: 화면 폭 전체 안에서 가운데 정렬, 세로: 캐릭터 위쪽 기준)로 배치
    Widget place(
        {required double left, double right = 0, required double top, required double height, required Widget child}) {
      return Positioned(
        left: roomLeft + left * k,
        width: (roomWidth - left - right) * k,
        top: charTop + top * k,
        height: height * k,
        child: child,
      );
    }

    final hat = hatUrl;
    final clothes = clothesUrl;
    final adj = _isHttp(hat) ? hatAdjust(hat!) : (dx: 0.0, dy: 0.0);
    final clothesDx = _isHttp(clothes) ? (clothesShift[_fileName(clothes!)] ?? 0.0) : 0.0;
    final clothesK = _isHttp(clothes) ? (clothesScale[_fileName(clothes!)] ?? 1.0) : 1.0;

    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 배경
            Positioned.fill(
              child: _isHttp(backgroundUrl)
                  ? _network(backgroundUrl!, BoxFit.cover)
                  : ColoredBox(color: Colors.grey.shade200),
            ),
            // 캐릭터
            place(
              left: characterLeft[i],
              top: 0,
              height: characterHeight,
              child: Image.asset(characterList[i].assetName, fit: BoxFit.contain),
            ),
            // 옷
            if (_isHttp(clothes))
              place(
                // 왼쪽 끝을 옮기면 가운데가 그 절반만 움직이므로 두 배로 (모자 보정과 같은 방식)
                left: clothesDx > 0 ? clothesDx * 2 : 0,
                right: clothesDx < 0 ? -clothesDx * 2 : 0,
                top: clothesTop[i],
                height: clothesHeight[i] * clothesK,
                child: _network(clothes!, BoxFit.contain),
              ),
            // 모자
            if (_isHttp(hat))
              place(
                left: adj.dx > 0 ? adj.dx * 2 : 0,
                right: adj.dx < 0 ? -adj.dx * 2 : 0,
                top: hatTop[i] + adj.dy,
                height: hatHeight,
                child: _network(hat!, BoxFit.contain),
              ),
          ],
        ),
      ),
    );
  }

  // 그림을 못 받아도 오류 표시 없이 빈 칸으로
  Widget _network(String url, BoxFit fit) {
    return Image.network(url, fit: fit, errorBuilder: (_, __, ___) => const SizedBox.shrink());
  }
}
