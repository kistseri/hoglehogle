import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/constants.dart';
import 'package:hoho_hanja/_core/size.dart';

class CustomTabBarWidget extends StatefulWidget {
  final List<String> categories;
  final Function(String) onTabSelected;
  const CustomTabBarWidget({
    super.key,
    required this.categories,
    required this.onTabSelected,
  });

  @override
  State<CustomTabBarWidget> createState() => _CustomTabBarWidgetState();
}

class _CustomTabBarWidgetState extends State<CustomTabBarWidget> {
  final RxInt selectedTabIndex = 0.obs;

  @override
  void initState() {
    super.initState();
    selectedTabIndex.value = 0;
    if (widget.categories.isNotEmpty) {
      widget.onTabSelected(widget.categories[0]);
    }
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width;
    int tabCount = 4;

    return Stack(
      alignment: Alignment.topLeft,
      children: [
        Container(height: 40.h, color: Colors.transparent),
        Positioned(
          top: 0,
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                color: Colors.transparent),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                tabCount,
                (index) => _buildTabButton(index, size),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(int index, double size) {
    return Obx(
      () {
        bool isSelected = selectedTabIndex.value == index;
        bool isEmptyTab = index >= widget.categories.length;
        return GestureDetector(
          onTap: () {
            selectedTabIndex.value = index;
            if (!isEmptyTab) {
              widget.onTabSelected(widget.categories[index]);
            } else {
              widget.onTabSelected('');
            }
          },
          child: Container(
            height: 40.h,
            width: size / 4,
            decoration: BoxDecoration(
              color: isSelected ? Color(0xFFFFF8E7) : Color(0xFFF99D9D),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.r),
                topRight: Radius.circular(15.r),
              ),
              border: isSelected
                  ? Border(
                      top: BorderSide(color: Colors.brown, width: 2.w),
                      left: BorderSide(color: Colors.brown, width: 2.w),
                      right: BorderSide(color: Colors.brown, width: 2.w),
                    )
                  : Border.all(color: Colors.brown, width: 2.0),
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(gapQuarter),
                child: Image.asset(myroomTab[index]),
              ),
            ),
          ),
        );
      },
    );
  }
}
