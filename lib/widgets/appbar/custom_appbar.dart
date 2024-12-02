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
import 'package:hoho_hanja/services/auth/my_goods_service.dart';
import 'package:hoho_hanja/utils/load_profile_image.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback? onPressed;

  const CustomAppBar({super.key, this.onPressed});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  final goodsController = Get.put(GoodsDataController());
  final loginController = Get.put(LoginDataController());

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
            borderRadius: BorderRadius.circular(10.r),
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
          padding: MediaQuery.of(context).size.width >= 500
              ? EdgeInsets.all(8.r)
              : EdgeInsets.all(16.r),
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
        ValueListenableBuilder(
          valueListenable: Hive.box('selectedItemBox').listenable(),
          builder: (context, Box box, _) {
            final imageProvidrs = loadProfileImageFromBox(
                box, loginController.loginData.value!.id);
            return FutureBuilder(
              future: loadProfileImage(loginController.loginData.value!.id)
                  .then((imageProviders) =>
                      getProfileImageProvider(imageProviders)),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return CircleAvatar(backgroundImage: snapshot.data!);
                } else {
                  return const CircleAvatar(
                    backgroundColor: mBackWhite,
                  );
                }
              },
            );
          },
        ),
        SizedBox(width: 16.w),
      ],
    );
  }

  Map<String, ImageProvider?> loadProfileImageFromBox(Box box, String userId) {
    ImageProvider? getImageProvider(String? url, {bool isAsset = false}) {
      if (url == null || url.isEmpty) return null;
      return isAsset ? AssetImage(url) : NetworkImage(url);
    }

    return {
      'character':
          getImageProvider(box.get('${userId}_character'), isAsset: true),
      'hatImage': getImageProvider(box.get('${userId}_hatImage')),
      'clothingImage': getImageProvider(box.get('${userId}_clothingImage')),
      'accessoriesImage':
          getImageProvider(box.get('${userId}_accessoriesImage')),
      'backgroundImage': getImageProvider(box.get('${userId}_backgroundImage')),
    };
  }
}
