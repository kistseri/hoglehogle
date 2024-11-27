import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/size.dart';
import 'package:hoho_hanja/data/models/my_room_data.dart';
import 'package:hoho_hanja/screens/myroom/myroom_wigets/my_room_item.dart';
import 'package:hoho_hanja/screens/myroom/myroom_wigets/my_room_tab_bar.dart';
import 'package:hoho_hanja/services/myroom/selected_item_service.dart';

class MyroomTab extends StatelessWidget {
  final MyroomItemController itemController;

  const MyroomTab({
    super.key,
    required this.itemController,
  });

  @override
  Widget build(BuildContext context) {
    final myroomDataController = Get.find<MyroomDataController>();

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: MediaQuery.of(context).size.height / 1.75,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        child: Column(
          children: [
            // Tab bar
            Obx(
              () {
                final categories =
                    myroomDataController.myroomDataByCategory.keys.toList();
                return CustomTabBarWidget(
                  categories: categories,
                  onTabSelected: (categoryId) {
                    itemController.selectedCategory(categoryId);
                  },
                );
              },
            ),
            // Item Grid
            Expanded(
              child: Obx(
                () {
                  final items = myroomDataController
                      .getDataByCategory(itemController.selectedCategory.value);
                  return Container(
                    padding: EdgeInsets.only(
                        top: gapHalf, left: gapHalf, right: gapHalf),
                    decoration: BoxDecoration(color: Color(0xFFFFF8E7)),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: gapHalf,
                        crossAxisSpacing: gapHalf,
                      ),
                      itemCount: (items.length / 3).ceil() * 3,
                      itemBuilder: (context, index) {
                        if (index >= items.length) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Color(0xFFF4E9D0),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          );
                        }

                        return GestureDetector(
                          onTap: () {
                            itemController.selectItem(index);
                            if (items[index].useyn == 'Y') {
                              selectedItemService(
                                itemController.selectedCategory,
                                itemController.selectedItem,
                              );
                            }
                          },
                          child: Obx(() {
                            bool isSelected =
                                itemController.selectedItem.value == index;
                            return MyroomItem(
                              itemName: items[index].item,
                              price: items[index].coin,
                              isSelected: isSelected,
                              isOwn: items[index].useyn == 'Y',
                            );
                          }),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
