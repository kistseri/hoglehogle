import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// 시안 좌표 → 화면 좌표 (홈 화면과 같은 방식)
///
/// 시안(360 x 698, 상태바 제외)을 화면에 들어가는 배율 하나로만 키우거나 줄인다.
/// 그래서 휴대폰과 태블릿처럼 화면 비율이 달라도 배치가 똑같이 보인다.
class DesignScale {
  // 시안 크기 (상태바 제외)
  static const double designWidth = 360;
  static const double designHeight = 698;

  // 화면이 시안보다 옆으로 넓으면(태블릿) 카드는 시안 폭의 이 배수까지만 커지고, 그보다 넓으면 남는 폭은 여백·간격으로 나눔
  static const double maxWidthStretch = 1.35;

  final double s; // 시안 → 화면 배율
  final double dw; // 화면 폭 (시안 단위)
  final double top; // 시안 영역의 화면상 위쪽 (상태바 아래)

  const DesignScale._(this.s, this.dw, this.top);

  factory DesignScale.of(Size screen, EdgeInsets padding) {
    final availableH = screen.height - padding.top - padding.bottom;
    final s = math.min(screen.width / designWidth, availableH / designHeight);
    return DesignScale._(s, screen.width / s, padding.top);
  }

  // 현재 화면 기준 (키보드가 올라와도 배율은 그대로)
  factory DesignScale.fromContext(BuildContext context) {
    return DesignScale.of(MediaQuery.sizeOf(context), MediaQuery.paddingOf(context));
  }

  // 앱바 아래 본문처럼 Scaffold가 상단 여백을 지운 곳에서도 앱바와 같은 배율 (기기 화면 전체 기준)
  factory DesignScale.ofScreen(BuildContext context) {
    final view = MediaQueryData.fromView(View.of(context));
    return DesignScale.of(view.size, view.padding);
  }

  // 카드가 넓어질 수 있는 최대 폭 (시안 단위)
  double get maxContentWidth => math.min(dw, designWidth * maxWidthStretch);

  double d(num v) => v * s;
  double x(num v) => v * s;
  double y(num v) => top + v * s;

  // 시안에서 오른쪽 끝 기준으로 놓인 x를 화면 폭에 맞게 옮김 (inset: 시안보다 늘어난 양옆 여백)
  double r(num v, [num inset = 0]) => v + (dw - designWidth) - inset;

  // 시안 좌표 (x, y, 폭, 높이)에 배치
  Widget box(num left, num top, num w, num h, Widget child) {
    return Positioned(left: x(left), top: y(top), width: d(w), height: d(h), child: child);
  }

  // 글자 배치: 세로는 cy에 가운데, 가로는 cx에 가운데 정렬 또는 left부터 왼쪽 정렬
  // 글자는 터치를 막지 않도록 IgnorePointer
  Widget place({num? left, num? cx, required num cy, required num size, num w = 240, required Widget child}) {
    final h = size * 4;
    return box(
      cx != null ? cx - w / 2 : left!,
      cy - h / 2,
      w,
      h,
      IgnorePointer(
        child: Align(
          alignment: cx != null ? Alignment.center : Alignment.centerLeft,
          child: child,
        ),
      ),
    );
  }
}
