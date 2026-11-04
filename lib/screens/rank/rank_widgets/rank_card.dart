import 'package:flutter/material.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/data/models/rank_data.dart';
import 'package:hoho_hanja/screens/rank/rank_widgets/rank_circle_avatar.dart';
import 'package:hoho_hanja/utils/formatter.dart';

/// 1~3위 카드 (시안 단위 96 x 141, [s] = 시안 → 화면 배율)
class RankCard extends StatelessWidget {
  static const double width = 96;
  static const double height = 141;

  final int rank; // 순위 (점수가 같으면 같은 순위)
  final int place; // 자리 (1·2·3: 카드 색·왕관)
  final RankData data;
  final double s;

  const RankCard({
    super.key,
    required this.rank,
    required this.place,
    required this.data,
    required this.s,
  });

  static const _box = ['first', 'second', 'third'];
  static const _pillColor = [Color(0xFFFCF0B6), Color(0xFFC1F0F1), Color(0xFFF0E4C9)];
  // 순위 방패 (시안 색): 바탕, 숫자
  static const _shieldColor = [Color(0xFFFCEC7C), Color(0xFF8FEFEA), Color(0xFFF7D992)];
  static const _shieldText = [Color(0xFFC79A00), Color(0xFF2A9E99), Color(0xFFA9792F)];

  @override
  Widget build(BuildContext context) {
    double d(num v) => v * s;
    const avatar = 58.0; // 흰 테두리 포함
    const ring = 2.5;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: Image.asset('assets/images/icon/${_box[place - 1]}.png', fit: BoxFit.fill),
        ),
        // 아바타 (흰 테두리)
        Positioned(
          top: d(22),
          left: d((width - avatar) / 2),
          width: d(avatar),
          height: d(avatar),
          child: Container(
            padding: EdgeInsets.all(d(ring)),
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: RankCircleAvatar(size: d(avatar - ring * 2), data: data),
          ),
        ),
        // 닉네임 (길면 …)
        Positioned(
          left: d(6),
          right: d(6),
          top: d(84),
          height: d(20),
          child: Center(
            child: Text(
              data.nickName,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white, fontSize: d(12), fontWeight: FontWeight.bold, height: 1.2),
            ),
          ),
        ),
        // 점수
        Positioned(
          left: d(8),
          right: d(8),
          top: d(103.5),
          height: d(13),
          child: Center(
            child: Container(
              height: d(13),
              constraints: BoxConstraints(minWidth: d(41)),
              padding: EdgeInsets.symmetric(horizontal: d(8)),
              decoration: BoxDecoration(
                color: _pillColor[place - 1],
                borderRadius: BorderRadius.circular(d(6.5)),
              ),
              // 글자 폭만큼만 (가로로 늘어나지 않게)
              child: Center(
                widthFactor: 1,
                child: Text(
                  '${formatNumber(data.totalPoints)}점',
                  maxLines: 1,
                  style: TextStyle(color: mFontMain, fontSize: d(8.5), height: 1),
                ),
              ),
            ),
          ),
        ),
        // 왕관 (1등 자리, 아바타 왼쪽 위에 걸침)
        if (place == 1)
          Positioned(
            top: d(12),
            left: d(10),
            width: d(33),
            height: d(26),
            child: Image.asset('assets/images/icon/crown.png', fit: BoxFit.contain),
          ),
        // 순위 방패 (카드 오른쪽 위, 위로 살짝 튀어나옴)
        Positioned(
          top: d(-4),
          left: d(65),
          width: d(23),
          height: d(24),
          child: Semantics(
            label: '$rank위',
            child: CustomPaint(
              painter: _ShieldPainter(color: _shieldColor[place - 1], stroke: d(1.5)),
              child: Padding(
                padding: EdgeInsets.only(bottom: d(3)),
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        color: _shieldText[place - 1],
                        fontSize: d(12),
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// 순위 방패: 카드보다 밝은 같은 계열 바탕 + 흰 테두리 (시안)
class _ShieldPainter extends CustomPainter {
  final Color color;
  final double stroke;

  _ShieldPainter({required this.color, required this.stroke});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final r = w * 0.3;
    final path = Path()
      ..moveTo(r, 0)
      ..lineTo(w - r, 0)
      ..quadraticBezierTo(w, 0, w, r)
      ..lineTo(w, h * 0.58)
      ..quadraticBezierTo(w, h * 0.78, w / 2, h)
      ..quadraticBezierTo(0, h * 0.78, 0, h * 0.58)
      ..lineTo(0, r)
      ..quadraticBezierTo(0, 0, r, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
  }

  @override
  bool shouldRepaint(_ShieldPainter old) => old.stroke != stroke || old.color != color;
}
