import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/utils/design_scale.dart';

/// 진행 중 로딩창 (EasyLoading.show 처럼, 눌러도·뒤로가기로도 안 닫힘)
///
/// showLoading('로그인 중...') 으로 띄우고 hideLoading() 으로 닫는다.
/// 띄운 로딩창 자체만 닫으므로 그 위에 다른 창이 떠 있어도 엉뚱한 창이 닫히지 않음.
DialogRoute<void>? _loadingRoute;

void showLoading(String status) {
  final context = Get.overlayContext;
  if (context == null || _loadingRoute != null) return;

  final route = DialogRoute<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black45,
    builder: (context) {
      final sc = DesignScale.fromContext(context);
      return PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: sc.d(28), vertical: sc.d(22)),
            decoration: BoxDecoration(
              color: mBackWhite,
              borderRadius: BorderRadius.circular(sc.d(16)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: sc.d(36),
                  height: sc.d(36),
                  child: CircularProgressIndicator(color: primaryColor, strokeWidth: sc.d(3.5)),
                ),
                Padding(
                  padding: EdgeInsets.only(top: sc.d(14)),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: mFontMain,
                      fontSize: sc.d(14),
                      decoration: TextDecoration.none,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
  _loadingRoute = route;
  Navigator.of(context, rootNavigator: true).push(route);
}

void hideLoading() {
  final route = _loadingRoute;
  _loadingRoute = null;
  if (route != null && route.isActive) {
    route.navigator?.removeRoute(route);
  }
}
