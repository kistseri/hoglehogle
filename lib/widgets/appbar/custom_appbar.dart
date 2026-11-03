import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/size.dart';
import 'package:hoho_hanja/_core/style.dart';
import 'package:hoho_hanja/data/models/goods_data.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/main.dart';
import 'package:hoho_hanja/screens/myroom/myroom_wigets/my_room_circle.dart';
import 'package:hoho_hanja/screens/myroom/myroom_wigets/my_room_item.dart';
import 'package:hoho_hanja/services/auth/my_goods_service.dart';
import 'package:logger/logger.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback? onPressed;
  final VoidCallback? onAvatarPressed;

  const CustomAppBar({super.key, this.onPressed, this.onAvatarPressed});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  final goodsController = Get.put(GoodsDataController());
  final loginController = Get.put(LoginDataController());
  final myRoomController = Get.find<MyroomItemController>();

  @override
  void initState() {
    super.initState();
    myGoodsService();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(4.sp),
          decoration: BoxDecoration(
            color: mBoxGreen,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            CupertinoIcons.back,
            color: mFontWhite,
          ),
        ),
        onPressed: () {
          effect.tapSound();
          if (widget.onPressed != null) {
            widget.onPressed!();
          } else {
            Get.back();
          }
        },
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      actions: [
        Padding(
          padding: MediaQuery.of(context).size.width >= 500 ? EdgeInsets.all(8.r) : EdgeInsets.all(16.r),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/icon/coin.png',
              ),
              SizedBox(width: 4.w),
              Container(
                alignment: Alignment.center,
                child: Obx(
                  () => Text(
                    goodsController.formattedCoin.value,
                    style: outlineTextStyle(14.sp),
                  ),
                ),
              ),
              SizedBox(width: gapQuarter),
              Image.asset(
                'assets/images/icon/diamond.png',
              ),
              SizedBox(width: 4.w),
              Container(
                alignment: Alignment.center,
                child: Obx(
                  () => Text(
                    goodsController.formattedDia.value,
                    style: outlineTextStyle(14.sp),
                  ),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
            onTap: widget.onAvatarPressed,
            child: MyRoomCircleAvatar(
              size: 40,
            )),
        SizedBox(width: 16.w),
      ],
    );
  }
}
