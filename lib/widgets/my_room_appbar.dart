// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:hoho_hanja/_core/colors.dart';
// import 'package:hoho_hanja/_core/size.dart';
// import 'package:hoho_hanja/_core/style.dart';
// import 'package:hoho_hanja/data/models/goods_data.dart';
// import 'package:hoho_hanja/services/auth/my_goods_service.dart';
//
// class RankAppBar extends StatefulWidget implements PreferredSizeWidget {
//   final VoidCallback onPressed;
//   const RankAppBar({super.key, required this.onPressed});
//
//   @override
//   State<RankAppBar> createState() => _RankAppBarState();
//
//   @override
//   Size get preferredSize => Size.fromHeight(kToolbarHeight);
// }
//
// class _RankAppBarState extends State<RankAppBar> {
//   final goodsController = Get.put(GoodsDataController());
//
//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: primaryColor,
//         leading: IconButton(
//           icon: Container(
//             padding: EdgeInsets.all(4.sp),
//             decoration: BoxDecoration(
//               color: mBackWhite,
//               borderRadius: BorderRadius.circular(10.r),
//             ),
//             child: Icon(
//               CupertinoIcons.back,
//               color: primaryColor,
//             ),
//           ),
//           onPressed: () {
//             widget.onPressed();
//           },
//         ),
//         systemOverlayStyle: SystemUiOverlayStyle.dark,
//         actions: [
//           Padding(
//             padding: EdgeInsets.all(16.sp),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Image.asset(
//                   'assets/images/icon/coin.png',
//                 ),
//                 SizedBox(width: 4.w),
//                 Container(
//                   alignment: Alignment.center,
//                   child: Text(
//                     goodsController.formattedCoin,
//                     style: outlineTextStyle(14.sp),
//                   ),
//                 ),
//                 SizedBox(width: gapQuarter),
//                 Image.asset(
//                   'assets/images/icon/diamond.png',
//                 ),
//                 SizedBox(width: 4.w),
//                 Container(
//                     alignment: Alignment.center,
//                     child: Text(
//                       goodsController.formattedDia,
//                       style: outlineTextStyle(14.sp),
//                     )),
//               ],
//             ),
//           ),
//           CircleAvatar(
//             backgroundColor: Color(0xFFE5E5E5),
//           ),
//           SizedBox(width: 16.w),
//         ]);
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     myGoodsService();
//   }
// }
