import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/data/models/goods_data.dart';
import 'package:hoho_hanja/main.dart';
import 'package:hoho_hanja/screens/myroom/myroom_wigets/my_room_circle.dart';
import 'package:hoho_hanja/services/auth/my_goods_service.dart';
import 'package:hoho_hanja/utils/design_scale.dart';

/// 시안 비율 화면용 앱바 (뒤로가기 + 코인·다이아 + 프로필)
///
/// 코인·다이아·프로필은 홈 앱바와 같은 시안 좌표·크기 (화면을 오가도 같은 크기로 보이도록).
/// 화면 맨 위(상태바 포함)부터 시안 y [height]까지 차지하므로 Stack 맨 위에 그대로 놓으면 됨.
class DesignAppBar extends StatefulWidget {
  static const double height = 53; // 시안 단위

  final DesignScale scale;
  final double inset; // 시안보다 늘어난 양옆 여백 (시안 단위)
  final VoidCallback? onPressed;
  final VoidCallback? onAvatarPressed;

  const DesignAppBar({
    super.key,
    required this.scale,
    this.inset = 0,
    this.onPressed,
    this.onAvatarPressed,
  });

  @override
  State<DesignAppBar> createState() => _DesignAppBarState();
}

class _DesignAppBarState extends State<DesignAppBar> {
  final goodsController = Get.put(GoodsDataController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      myGoodsService();
    });
  }

  void _onBack() {
    effect.tapSound();
    if (widget.onPressed != null) {
      widget.onPressed!();
    } else {
      Get.back();
    }
  }

  // 코인·다이아 숫자 (흰 글자 + 회색 테두리)
  TextStyle _outlineStyle(num size) {
    final sc = widget.scale;
    final o = sc.d(1);
    return TextStyle(
      fontFamily: 'BMJUA',
      fontSize: sc.d(size),
      color: Colors.white,
      shadows: [
        for (final offset in [Offset(0, -o), Offset(o, 0), Offset(0, o), Offset(-o, 0)])
          Shadow(offset: offset, color: Colors.grey, blurRadius: o),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final sc = widget.scale;
    final inset = widget.inset;

    return SizedBox(
      height: sc.y(DesignAppBar.height),
      child: Stack(
        children: [
          // 뒤로가기 (누르는 영역은 버튼보다 넓게)
          sc.box(
            14 + inset,
            15,
            24,
            24,
            DecoratedBox(
              decoration: BoxDecoration(
                color: mBoxGreen,
                borderRadius: BorderRadius.circular(sc.d(6)),
              ),
              child: Icon(CupertinoIcons.back, color: mFontWhite, size: sc.d(15)),
            ),
          ),
          sc.box(4 + inset, 5, 44, 44, GestureDetector(behavior: HitTestBehavior.opaque, onTap: _onBack)),
          // 코인
          sc.box(sc.r(207.7, inset), 18.9, 16, 16, Image.asset('assets/images/icon/coin.png')),
          sc.place(
            left: sc.r(225, inset),
            cy: 27,
            size: 15,
            child: Obx(() => Text(goodsController.formattedCoin.value, style: _outlineStyle(15))),
          ),
          // 다이아
          sc.box(sc.r(273.5, inset), 18.3, 17, 17, Image.asset('assets/images/icon/diamond.png')),
          sc.place(
            left: sc.r(293, inset),
            cy: 27,
            size: 15,
            child: Obx(() => Text(goodsController.formattedDia.value, style: _outlineStyle(15))),
          ),
          // 프로필
          sc.box(
            sc.r(324.5, inset),
            14.5,
            24,
            24,
            GestureDetector(
              onTap: widget.onAvatarPressed,
              child: MyRoomCircleAvatar(size: sc.d(24)),
            ),
          ),
        ],
      ),
    );
  }
}
