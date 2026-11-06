import 'package:flutter/material.dart';
import 'package:hoho_hanja/_core/constants.dart';

/// 캐릭터 + 모자·옷·배경을 동그라미 안에 그리는 아바타 (랭킹·앱바 프로필)
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

  // 모자별 위치 보정 표 (파일 이름 → 마이룸 단위, dx 양수 = 오른쪽, dy 양수 = 아래)
  // 새 모자 그림이 어긋나 보이면 여기에 한 줄 추가 (switch 문 대신 옷 보정과 같은 표 방식, C-43)
  static const Map<String, ({double dx, double dy})> hatOffsets = {
    'hat_6': (dx: 10, dy: 0),
    'hat_9': (dx: -10, dy: 0),
    'hat_8': (dx: 0, dy: 5),
  };

  static ({double dx, double dy}) hatAdjust(String url) => hatOffsets[_fileName(url)] ?? (dx: 0, dy: 0);

  // 옷별 크기 보정 (파일 이름 → 배율, 위쪽(목) 위치는 그대로)
  static final Map<String, double> clothesScale = {
    'KakaoTalk_20241128_144348851_04': 1.1, // 남색 셔츠 + 노란 반바지
  };

  // 옷별 가로 위치 보정 (파일 이름 → 마이룸 단위, 음수 = 왼쪽)
  static final Map<String, double> clothesShift = {
    'KakaoTalk_20241128_144348851_04': -1, // 남색 셔츠 + 노란 반바지
  };

  static String _fileName(String url) => RegExp(r'([^/]+)\.\w+$').firstMatch(url)?.group(1) ?? '';

  static bool _isHttp(String? url) => url != null && url.startsWith('http');

  /// 캐릭터·옷·모자 (마이룸 단위 배치). 아바타와 마이룸 화면이 함께 씀
  ///
  /// [k] 마이룸 단위 → 화면, [roomLeft] 마이룸 화면(폭 360)의 왼쪽 끝, [charTop] 캐릭터 위쪽 (모두 화면 px)
  static List<Widget> layers({
    required int characterIndex,
    String? hatUrl,
    String? clothesUrl,
    required double k,
    required double roomLeft,
    required double charTop,
  }) {
    final i = safeIndex(characterIndex);

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

    return [
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
          child: network(clothes!, BoxFit.contain),
        ),
      // 모자
      if (_isHttp(hat))
        place(
          left: adj.dx > 0 ? adj.dx * 2 : 0,
          right: adj.dx < 0 ? -adj.dx * 2 : 0,
          top: hatTop[i] + adj.dy,
          height: hatHeight,
          child: network(hat!, BoxFit.contain),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final k = size * characterRatio / characterHeight; // 마이룸 단위 → 화면
    final roomLeft = size / 2 - roomWidth / 2 * k; // 마이룸 화면 왼쪽 끝 (동그라미 밖까지)
    final charTop = size * (1 - characterRatio); // 캐릭터 발이 동그라미 아래에 닿게

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
                  ? network(backgroundUrl!, BoxFit.cover)
                  : ColoredBox(color: Colors.grey.shade200),
            ),
            ...layers(
              characterIndex: characterIndex,
              hatUrl: hatUrl,
              clothesUrl: clothesUrl,
              k: k,
              roomLeft: roomLeft,
              charTop: charTop,
            ),
          ],
        ),
      ),
    );
  }

  // 그림을 못 받아도 오류 표시 없이 빈 칸으로
  static Widget network(String url, BoxFit fit) {
    return Image.network(url, fit: fit, errorBuilder: (_, __, ___) => const SizedBox.shrink());
  }
}
