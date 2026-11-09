import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/utils/design_scale.dart';

/// 로그인 ~ 회원가입 화면 공통 배치
///
/// 모든 크기를 시안(360 폭) 단위로 적고 DesignScale 배율 하나로만 키우거나 줄인다 (홈 화면과 같은 방식).
/// 그래서 작은 휴대폰·긴 휴대폰·태블릿 어디서나 같은 비율로 보이고,
/// 태블릿처럼 시안보다 넓은 화면은 내용을 시안 폭 그대로 가운데에 두고 양옆을 비운다.

/// 시안 폭(360)으로 가운데에 놓는다
class AuthContent extends StatelessWidget {
  final DesignScale scale;
  final Widget child;

  const AuthContent({super.key, required this.scale, required this.child});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(width: scale.d(DesignScale.designWidth), child: child),
    );
  }
}

/// 흰 화면 앱바 (높이·뒤로가기 아이콘도 같은 배율)
PreferredSizeWidget authAppBar(DesignScale sc) {
  return AppBar(
    toolbarHeight: sc.d(kToolbarHeight),
    leadingWidth: sc.d(kToolbarHeight),
    iconTheme: IconThemeData(size: sc.d(24)),
  );
}

/// 입력칸 꾸밈 (둥근 테두리 + 왼쪽 아이콘)
InputDecoration authInputDecoration(
  DesignScale sc, {
  required String hintText,
  required String icon,
  Color fillColor = mBackWhite,
  Color focusColor = mBoxYellow,
  Widget? suffixIcon,
}) {
  OutlineInputBorder border(Color color) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: color, width: sc.d(2)),
      borderRadius: BorderRadius.circular(sc.d(50)),
    );
  }

  return InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(color: mFontSub, fontSize: sc.d(15), height: _inputLineHeight),
    isDense: true,
    // 테두리는 글자 줄 높이 + 위아래 여백으로 그려지므로, 여백으로 시안 높이 50을 맞춤
    contentPadding: EdgeInsets.symmetric(horizontal: sc.d(12), vertical: sc.d((50 - 15 * _inputLineHeight) / 2)),
    enabledBorder: border(mTextField),
    focusedBorder: border(focusColor),
    fillColor: fillColor,
    prefixIcon: Padding(
      padding: EdgeInsets.only(left: sc.d(16), right: sc.d(4)),
      child: Image.asset(icon, width: sc.d(22), height: sc.d(22)),
    ),
    prefixIconConstraints: const BoxConstraints(),
    suffixIcon: suffixIcon,
    suffixIconConstraints: const BoxConstraints(),
  );
}

/// 입력 글자 크기
TextStyle authInputStyle(DesignScale sc) => TextStyle(fontSize: sc.d(15), height: _inputLineHeight);

const double _inputLineHeight = 1.2; // 입력칸 글자 줄 높이 (글자 크기 배수)

/// 둥근 큰 버튼 (로그인·인증·확인 등)
/// [onTap]이 Future를 돌려주면 끝날 때까지 다시 눌러도 무시 (인증번호 문자·가입 요청이 두 번 가지 않도록)
class AuthButton extends StatefulWidget {
  final String text;
  final Color color;
  final FutureOr<void> Function()? onTap;
  final double fontSize; // 시안 단위
  final String? fontFamily;

  const AuthButton({
    super.key,
    required this.text,
    required this.color,
    this.onTap,
    this.fontSize = 18,
    this.fontFamily,
  });

  @override
  State<AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<AuthButton> {
  bool _busy = false;

  Future<void> _handleTap() async {
    if (_busy || widget.onTap == null) return;
    _busy = true;
    try {
      await widget.onTap!();
    } finally {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sc = DesignScale.fromContext(context);
    return GestureDetector(
      onTap: widget.onTap == null ? null : _handleTap,
      child: Container(
        width: double.infinity,
        height: sc.d(50),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: widget.color, borderRadius: BorderRadius.circular(sc.d(50))),
        child: Text(
          widget.text,
          style: TextStyle(color: Colors.white, fontSize: sc.d(widget.fontSize), fontFamily: widget.fontFamily),
        ),
      ),
    );
  }
}

/// 노란 배경 그림 + 아래 흰 시트 (소셜 로그인 · 이메일 로그인 공통)
///
/// 시안(360 x 720 휴대폰): 그림은 폭에 꽉 차고(높이 246), 흰 시트가 그림 아래쪽 40을 덮으며 y 206에서 시작.
/// 태블릿처럼 넓은 화면은 그림이 커지는 만큼 시트를 내리되, 시트 내용([sheetHeight])이 들어갈 자리는 남긴다.
class AuthSheetLayout extends StatelessWidget {
  static const double _imageAspect = 1080 / 737; // login_bg.png
  static const double _overlap = 40; // 시트가 그림 아래를 덮는 높이 (시안 단위)
  static const double _minSheetTop = 182; // 시트 시작 최소 y (시안 단위, 상태바 제외)

  final DesignScale scale;
  final double sheetHeight; // 시트 내용이 차지하는 높이 (시안 단위)
  final Widget child;
  final ScrollController? controller;

  const AuthSheetLayout({
    super.key,
    required this.scale,
    required this.child,
    this.sheetHeight = 470,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final sc = scale;
    final size = MediaQuery.sizeOf(context);
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    // 키보드가 없을 때도 안드로이드 내비게이션 바·홈 표시줄 아래로 내용이 들어가지 않게
    final bottomInset = math.max(keyboard, MediaQuery.paddingOf(context).bottom);

    // 그림 전체가 보일 때의 시트 위치 → 시트 내용이 들어갈 만큼만 허용 → 시안 위치보다 위로는 안 올림
    final fullImageTop = size.width / _imageAspect - sc.d(_overlap);
    final sheetTop = math.max(sc.y(_minSheetTop), math.min(fullImageTop, size.height - sc.d(sheetHeight)));

    return ColoredBox(
      color: mBoxYellow,
      child: Stack(
        children: [
          // 배경 그림: 시트 아래로 들어가는 부분까지, 비율 유지한 채 꽉 채움 (넘치는 하늘 쪽을 자름)
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: sheetTop + sc.d(_overlap),
            child: Image.asset(
              'assets/images/login_bg_2.png',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ),
          // 흰 시트
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: sheetTop + sc.d(_overlap-15),
            child: Image.asset(
              'assets/images/login_bg_1.png',
              fit: BoxFit.contain,
              alignment: Alignment.bottomCenter,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: sheetTop,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: mBackWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(sc.d(30))),
              ),
              child: SingleChildScrollView(
                controller: controller,
                // 키보드에 가려진 아래쪽도 밀어 올려 볼 수 있게
                padding: EdgeInsets.only(bottom: bottomInset),
                child: AuthContent(scale: sc, child: child),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
