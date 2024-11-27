import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hoho_hanja/_core/icon.dart';

class CustomBottom extends StatefulWidget {
  final Function(int) onTabChanged;
  final int selectedIndex;
  // final VoidCallback onSettingPressed;

  const CustomBottom({
    super.key,
    required this.onTabChanged,
    required this.selectedIndex,
    // required this.onSettingPressed,
  });

  @override
  State<CustomBottom> createState() => _CustomBottomState();
}

class _CustomBottomState extends State<CustomBottom>
    with SingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.selectedIndex,
    );
    tabController.addListener(() => setState(
          () {
            if (tabController.index != 4) {
              widget.onTabChanged(tabController.index);
            } else {
              // widget.onSettingPressed();
              tabController.index = widget.selectedIndex;
            }
          },
        ));
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 53.0.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0.r),
          topRight: Radius.circular(25.0.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0.r),
          topRight: Radius.circular(25.0.r),
        ),
        child: TabBar(
          indicator: BoxDecoration(),
          controller: tabController,
          tabs: [
            Tab(
                icon: widget.selectedIndex == 0
                    ? ativeRank(28.0.w, 28.0.h)
                    : rank(28.0.w, 28.0.h)),
            Tab(
                icon: widget.selectedIndex == 1
                    ? ativeMyRoom(28.0.w, 28.0.h)
                    : myRoom(28.0.w, 28.0.h)),
            Tab(
                icon: widget.selectedIndex == 2
                    ? ativeHome(28.0.w, 28.0.h)
                    : home(28.0.w, 28.0.h)),
            Tab(
                icon: widget.selectedIndex == 3
                    ? activeSetting(28.0.w, 28.0.h)
                    : setting(28.0.w, 28.0.h)),
          ],
        ),
      ),
    );
  }
}
