import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/constants.dart';
import 'package:hoho_hanja/_core/size.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/data/models/my_room_data.dart';
import 'package:hoho_hanja/main.dart';
import 'package:hoho_hanja/screens/home/home_screen.dart';
import 'package:hoho_hanja/screens/myroom/myroom_wigets/my_room_item.dart';
import 'package:hoho_hanja/screens/myroom/myroom_wigets/my_room_tab.dart';
import 'package:hoho_hanja/services/myroom/selected_item_service.dart';
import 'package:hoho_hanja/widgets/appbar/custom_appbar.dart';
import 'package:logger/logger.dart';

class MyRoomScreen extends StatefulWidget {
  final VoidCallback onPressed;

  const MyRoomScreen({super.key, required this.onPressed});

  @override
  State<MyRoomScreen> createState() => _MyRoomScreenState();
}

class _MyRoomScreenState extends State<MyRoomScreen> {
  final MyroomDataController myroomDataController = Get.put(MyroomDataController());
  final MyroomItemController itemController = Get.put(MyroomItemController());
  final LoginDataController loginDataController = Get.find<LoginDataController>();
  late String userId;

  @override
  void initState() {
    super.initState();
    userId = loginDataController.loginData.value!.id;
    loadSelectedItem();
  }

  void loadSelectedItem() {
    final index = characterList.indexWhere(
      (c) => c.assetName == itemController.characterImage.value.assetName,
    );
    itemController.applyCharacterSettings(index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final character = itemController.characterImage.value;
          final index = characterList.indexWhere((c) => c.assetName == character.assetName);
          return Stack(
            children: [
              Positioned(
                top: 0,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Obx(() {
                    return itemController.backgroundImage.value.isNotEmpty
                        ? Image.network(
                            itemController.backgroundImage.value,
                            fit: BoxFit.contain,
                          )
                        : Image.asset('assets/images/myroom/background/background_1.png');
                  }),
                ),
              ),
              // 캐릭터
              Obx(() {
                return Positioned(
                  top: screenHeight >= 1000 ? 200.h : 100.h,
                  left: itemController.characterLeft.value,
                  right: 0,
                  child: Image(
                    key: ValueKey(itemController.characterImage.value.assetName),
                    image: itemController.characterImage.value,
                    height: 200.h,
                  ),
                );
              }),
              // 모자
              Obx(() {
                double top = 0.0;
                if (screenHeight > 1000) {
                  top = itemController.hatTop.value + 100.h;
                } else {
                  top = itemController.hatTop.value;
                }
                final size = itemController.hatSize.value;
                int len = itemController.hatImage.value.length;
                String text = '';
                if (len >= 9) {
                  text = itemController.hatImage.value.substring(len - 9, len - 4);
                }
                return Positioned(
                  // top: top,
                  top: text != 'hat_8' ? top : top + 5.h,
                  left: text != 'hat_6' ? 0 : 20.w,
                  right: text != 'hat_9' ? 0 : 20.w,
                  child: SizedBox(
                    // height: size.height,
                    height: 40.h,
                    child: itemController.hatImage.isNotEmpty
                        ? Image.network(
                            itemController.hatImage.value,
                            fit: BoxFit.contain,
                          )
                        : Container(),
                  ),
                );
              }),
              // 옷
              Obx(() {
                final size = itemController.clothesSize.value;
                double top = 0.0;
                if (screenHeight > 1000) {
                  top = itemController.clothesTop.value + 100.h;
                } else {
                  top = itemController.clothesTop.value;
                }
                return Positioned(
                  top: top,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: size.height,
                    child: itemController.clothingImage.isNotEmpty
                        ? Image.network(itemController.clothingImage.value, fit: BoxFit.contain)
                        // ? Image.asset(
                        //     'assets/images/myroom/clothes/clothes_02.png',
                        //     fit: BoxFit.contain,
                        //   )
                        : Container(),
                  ),
                );
              }),
              // 캐릭터 변경 버튼
              Positioned(
                top: 85.h,
                right: 10.w,
                child: Padding(
                  padding: EdgeInsets.all(gapQuarter),
                  child: GestureDetector(
                    onTap: () {
                      itemController.nextCharacter();
                      final currentCharacter = itemController.characterImage.value;
                      final index = characterList.indexWhere(
                        (c) => c.assetName == currentCharacter.assetName,
                      );
                      itemController.applyCharacterSettings(index);
                    },
                    child: Container(
                      height: 55.h,
                      width: 55.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E7),
                        borderRadius: BorderRadius.circular(15.r),
                        border: Border.all(
                          width: 2.w,
                          color: const Color(0xFF8B6767),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.w, horizontal: 8.h),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Image.asset(
                                'assets/images/myroom/myroom_switch.png',
                                scale: 4,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '변경',
                                style: TextStyle(
                                  fontFamily: 'BMJUA',
                                  fontSize: 10.sp,
                                  color: const Color(0xFF8B6767),
                                ),
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
                      final selectedList = itemController.selectedItems.entries.map((entry) {
                        return {
                          "categoryId": entry.key,
                          "itemId": entry.value,
                        };
                      }).toList();
                      final characterIndex = characterList.indexWhere(
                        (c) => c.assetName == itemController.characterImage.value.assetName,
                      );
                      selectedItemService(selectedList, characterIndex.toString().padLeft(2, '0'));
                      widget.onPressed();
                    },
                  )
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
