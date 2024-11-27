import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/constants.dart';
import 'package:hoho_hanja/_core/size.dart';
import 'package:hoho_hanja/_core/style.dart';
import 'package:hoho_hanja/data/models/goods_data.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/screens/myroom/myroom_wigets/my_room_item.dart';
import 'package:hoho_hanja/services/auth/my_goods_service.dart';
import 'package:hoho_hanja/utils/load_profile_image.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  final ValueChanged<String> onValueChanged;
  const HomeAppBar({super.key, required this.onValueChanged});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  final goodsController = Get.put(GoodsDataController());
  final itemController = Get.put(MyroomItemController());
  final loginController = Get.put(LoginDataController());
  int index = 80;

  @override
  void initState() {
    super.initState();
    myGoodsService();
  }

  @override
  Widget build(BuildContext context) {
    final ratio =
        MediaQuery.of(context).size.width / MediaQuery.of(context).size.height;
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: mBoxGreen,
      leadingWidth: MediaQuery.of(context).size.width * 0.35,
      leading: Padding(
        padding: EdgeInsets.only(left: 8.r),
        child: DropdownButton(
          value: index,
          onChanged: (int? value) {
            setState(() {
              index = value!;
              widget.onValueChanged(value.toString());
            });
          },
          underline: SizedBox.shrink(),
          icon: Icon(
            CupertinoIcons.chevron_down,
            color: mFontWhite,
            size: fontMedium,
          ),
          items: grades.entries.map((grades) {
            return DropdownMenuItem<int>(
              value: int.parse(grades.key),
              child: GradeDropdownItem(
                value: int.parse(grades.key),
                gradeLabel: grades.value,
              ),
            );
          }).toList(),
        ),
      ),
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

class GradeDropdownItem extends StatelessWidget {
  final int value;
  final String gradeLabel;

  const GradeDropdownItem({
    super.key,
    required this.value,
    required this.gradeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenuItem(
      value: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            alignment: Alignment.center,
            child: Text(
              '수재',
              style: TextStyle(
                color: mFontWhite,
                fontSize: 15.sp,
              ),
            ),
          ),
          SizedBox(width: 2.w),
          Padding(
            padding: EdgeInsets.only(right: 8.r),
            child: Container(
              height: 18.h,
              width: 35.w,
              decoration: BoxDecoration(
                color: mBackWhite,
                borderRadius: BorderRadius.circular(8.r),
              ),
              alignment: Alignment.center,
              child: FittedBox(
                child: Text(
                  gradeLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
