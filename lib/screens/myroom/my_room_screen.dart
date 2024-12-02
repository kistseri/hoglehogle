import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hoho_hanja/_core/constants.dart';
import 'package:hoho_hanja/_core/size.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/data/models/my_room_data.dart';
import 'package:hoho_hanja/screens/home/home_screen.dart';
import 'package:hoho_hanja/screens/myroom/myroom_wigets/my_room_item.dart';
import 'package:hoho_hanja/screens/myroom/myroom_wigets/my_room_tab.dart';
import 'package:hoho_hanja/widgets/appbar/custom_appbar.dart';

class MyRoomScreen extends StatefulWidget {
  const MyRoomScreen({super.key});

  @override
  State<MyRoomScreen> createState() => _MyRoomScreenState();
}

class _MyRoomScreenState extends State<MyRoomScreen> {
  final MyroomDataController myroomDataController =
      Get.put(MyroomDataController());
  final MyroomItemController itemController = Get.put(MyroomItemController());
  final LoginDataController loginDataController =
      Get.find<LoginDataController>();
  late String userId;

  @override
  void initState() {
    super.initState();
    userId = loginDataController.loginData.value!.id;
    loadSelectedItem();
  }

  void loadSelectedItem() {
    var box = Hive.box('selectedItemBox');
    itemController.clothingImage.value =
        box.get('${userId}_clothingImage', defaultValue: '');
    itemController.hatImage.value =
        box.get('${userId}_hatImage', defaultValue: '');
    itemController.characterImage.value =
        AssetImage(box.get('${userId}_character', defaultValue: ''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Image.asset(
                'assets/images/myroom/myroom_background.png',
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          // 캐릭터
          Positioned(
            top: 100.h,
            left: 0,
            right: 0,
            child: Obx(
              () {
                return itemController.characterImage.value.assetName.isNotEmpty
                    ? Image(
                        image: itemController.characterImage.value,
                        height: 200.h,
                      )
                    : Image.asset(
                        charcater[0].assetName,
                        height: 200.h,
                      );
              },
            ),
          ),
          // 모자
          Positioned(
            top: 85.h,
            left: 140.w,
            child: SizedBox(
              height: 35.h,
              width: 85.w,
              child: Obx(
                () {
                  return itemController.hatImage.isNotEmpty
                      ? Image.network(
                          itemController.hatImage.value,
                          fit: BoxFit.fill,
                        )
                      : Container();
                },
              ),
            ),
          ),
          // 옷
          Positioned(
            top: 210.h,
            left: 110.w,
            child: SizedBox(
              height: 70.h,
              width: 140.w,
              child: Obx(
                () {
                  return itemController.clothingImage.isNotEmpty
                      ? Image.network(
                          itemController.clothingImage.value,
                          fit: BoxFit.fill,
                        )
                      : Container();
                },
              ),
            ),
          ),
          // 캐릭터 변경 버튼
          Positioned(
            top: 80.h,
            right: 10.w,
            child: Padding(
              padding: EdgeInsets.all(gapQuarter),
              child: GestureDetector(
                onTap: () {
                  itemController.nextCharacter();
                },
                child: Container(
                  height: 55.h,
                  width: 55.w,
                  decoration: BoxDecoration(
                    color: Color(0xFFFFF8E7),
                    borderRadius: BorderRadius.circular(15.r),
                    border: Border.all(
                      width: 2.w,
                      color: Color(0xFF8B6767),
                    ),
                  ),
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 4.w, horizontal: 8.h),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/myroom/myroom_switch.png',
                          scale: 3,
                        ),
                        Text(
                          'Switch',
                          style: TextStyle(
                            fontFamily: 'BMJUA',
                            fontSize: 10.sp,
                            color: Color(0xFF8B6767),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 하단 아이템 선택 영역
          MyroomTab(
            itemController: itemController,
          ),
          Column(
            children: [
              CustomAppBar(
                onPressed: () {
                  Get.offAll(() => const HomeScreen());
                },
              )
            ],
          ),
        ],
      ),
    );
  }
}
