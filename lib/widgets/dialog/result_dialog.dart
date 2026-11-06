import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/screens/home/home_screen.dart';
import 'package:hoho_hanja/services/auth/my_goods_service.dart';
import 'package:hoho_hanja/utils/design_scale.dart';
import 'package:lottie/lottie.dart';

// 결과창 (시안: 360 x 720 휴대폰 기준)
// 화면 가운데에 280 x 360 카드, 그 주위에 장식 아이콘. 모두 배율 하나로만 키우거나 줄여서
// 휴대폰·태블릿 어디서나 같은 모양으로 보이게 한다.
const double _cardW = 280;
const double _cardH = 360;

// 장식 아이콘 (시안 360 x 720 화면 좌표: 왼쪽 위 기준)
const List<({IconData icon, Color color, double size, double top, double left})> _decorations = [
  (icon: Icons.circle, color: Colors.amber, size: 30, top: 135, left: 35),
  (icon: Icons.circle, color: Colors.amber, size: 15, top: 165, left: 20),
  (icon: Icons.circle, color: Colors.lightGreen, size: 7.5, top: 400, left: 15),
  (icon: Icons.star, color: Colors.white, size: 10, top: 520, left: 35),
  (icon: Icons.star, color: Colors.amber, size: 20, top: 160, left: 300),
  (icon: Icons.circle, color: Colors.lightGreen, size: 10, top: 180, left: 325),
  (icon: Icons.star, color: Colors.white, size: 25, top: 520, left: 300),
  (icon: Icons.circle, color: Colors.amber, size: 10, top: 505, left: 325),
];

// 결과 저장에 실패하면 서버 문구('예외' 등) 대신 '-' 로 표시
String _coinText(String coin) => int.tryParse(coin.trim()) != null ? coin.trim() : '-';

/// [onRetry]: 결과 저장에 실패했을 때(코인 '-') '다시 저장' 버튼이 부를 함수. 보통 () => resultService(code, count) (C-19)
void resultDialog(BuildContext context, int correctAnswers, int totalQuestions, String coin,
    {Future<String> Function()? onRetry}) {
  String coinText = _coinText(coin);
  bool saving = false;

  showGeneralDialog(
    context: context,
    // 바깥 터치·뒤로가기로 닫히면 끝난 게임 화면에 갇히므로 '메인으로'로만 닫음
    barrierDismissible: false,
    barrierLabel: '',
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
      final sc = DesignScale.fromContext(buildContext);
      double d(num v) => sc.d(v);
      final size = MediaQuery.sizeOf(buildContext);
      // 시안 화면(360 x 720)을 실제 화면 가운데에 맞춤
      final cx = size.width / 2;
      final cy = size.height / 2;

      return StatefulBuilder(builder: (context, setDialogState) {
      final failed = coinText == '-';

      Widget button(String label, Color color, double width, VoidCallback? onTap) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            height: d(40),
            width: d(width),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: onTap == null ? color.withValues(alpha: 0.5) : color,
              borderRadius: BorderRadius.circular(d(50)),
            ),
            child: Text(
              label,
              style: TextStyle(color: mFontWhite, fontSize: d(16), fontWeight: FontWeight.bold),
            ),
          ),
        );
      }

      Future<void> retry() async {
        if (onRetry == null || saving) return;
        setDialogState(() => saving = true);
        final newCoin = await onRetry();
        setDialogState(() {
          saving = false;
          coinText = _coinText(newCoin);
        });
        if (coinText == '-') {
          Get.snackbar('저장 실패', '인터넷 연결을 확인하고 다시 시도해주세요.', snackPosition: SnackPosition.BOTTOM);
        }
      }

      Future<void> goHome() async {
        await myGoodsService();
        Get.offAll(() => const HomeScreen());
      }

      return PopScope(
        canPop: false,
        child: Material(
          type: MaterialType.transparency,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (final deco in _decorations)
                Positioned(
                  left: cx + d(deco.left - 180),
                  top: cy + d(deco.top - 360),
                  child: Icon(deco.icon, color: deco.color, size: d(deco.size)),
                ),
              Center(
                child: Container(
                  width: d(_cardW),
                  height: d(_cardH),
                  decoration: BoxDecoration(
                    color: mBoxBeige,
                    borderRadius: BorderRadius.circular(d(50)),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 반짝이 (카드 오른쪽 밖으로 조금 나감)
                      Positioned(
                        right: d(-40),
                        top: d(100),
                        width: d(332),
                        height: d(150),
                        child: IgnorePointer(
                          child: Lottie.asset('assets/lottie/star_animation.json', fit: BoxFit.cover),
                        ),
                      ),
                      // 위쪽 별 (카드 위로 반쯤 걸침)
                      Positioned(
                        left: d(85),
                        top: d(-68),
                        width: d(100),
                        height: d(100),
                        child: Image.asset('assets/images/icon/star.png', fit: BoxFit.contain),
                      ),
                      // 점수 · 받은 동전 · 메인으로
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: EdgeInsets.all(d(16)),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '$correctAnswers',
                                      style: TextStyle(
                                        color: const Color(0xFFFF7E00),
                                        fontSize: d(30),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '/$totalQuestions',
                                      style: TextStyle(
                                        color: const Color(0xFFB4A784),
                                        fontSize: d(30),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.all(d(20)),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Container(
                                width: d(150),
                                height: d(150),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset('assets/images/icon/coin.png', width: d(96), height: d(96), fit: BoxFit.contain),
                                    Text(
                                      coinText,
                                      style: TextStyle(
                                        fontSize: d(24),
                                        height: 1.2,
                                        color: Colors.brown,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(d(16)),
                              // 저장에 실패했으면 '다시 저장'과 '메인으로'를 나란히 (C-19)
                              child: failed && onRetry != null
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        button(saving ? '저장 중…' : '다시 저장', const Color(0xFF8BC34A), 112,
                                            saving ? null : retry),
                                        Padding(
                                          padding: EdgeInsets.only(left: d(12)),
                                          child: button('메인으로', const Color(0xFFFEBE30), 112, saving ? null : goHome),
                                        ),
                                      ],
                                    )
                                  : button('메인으로', const Color(0xFFFEBE30), 144, goHome),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      });
    },
  );
}
