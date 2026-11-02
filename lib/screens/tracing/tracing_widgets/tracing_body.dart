import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/constants.dart';
import 'package:hoho_hanja/data/models/tracing_menu_data.dart';
import 'package:hoho_hanja/services/tracing/tracing_service.dart';

class TracingBody extends StatelessWidget {
  final String phase;
  final String code;
  final int openPage;
  final bool isLocked;
  final tracingBodyData = Get.put(TracingMenuDataController());

  TracingBody({
    super.key,
    required this.phase,
    required this.code,
    required this.openPage,
    required this.isLocked,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Text(
                '획순 따라쓰기',
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              flex: 11,
              child: GridView.builder(
                itemCount: tracingBodyData.tracingMenuDataList!.length,
                physics: tracingBodyData.tracingMenuDataList!.length <= 8
                    ? NeverScrollableScrollPhysics()
                    : AlwaysScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 4 / 3,
                  mainAxisSpacing: 10.h,
                  crossAxisSpacing: 10.w,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      await tracingService(phase, index, code, openPage, isLocked);
                    },
                    child: tracingElements(index),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tracingElements(int index) {
    final String hanja = tracingBodyData.tracingMenuDataList![index].hanja;
    int lineCount = addLineBreaks(hanja).split('\n').length;
    final tracingItem = tracingBodyData.tracingMenuDataList![index];
    final isSubjectEmpty = tracingItem.subject.isEmpty;

    return Container(
      decoration: BoxDecoration(
        color: gridColors[index],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isSubjectEmpty ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          if (isSubjectEmpty)
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(bottom: 8.sp, left: 10.w, right: 10.w),
                child: Container(
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(color: gridInsideColors[index], shape: BoxShape.circle),
                  child: Center(
                    child: Text(
                      tracingItem.gubun,
                      style: TextStyle(color: mFontWhite, fontSize: 14.sp),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            )
          else ...[
            Padding(
              padding: EdgeInsets.only(top: 10.h, left: 10.w),
              child: Container(
                decoration: BoxDecoration(
                  color: gridInsideColors[index],
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: SizedBox(
                  height: 25.h,
                  width: 25.w,
                  child: Center(
                    child: Text(
                      tracingItem.gubun,
                      style: TextStyle(color: mFontWhite),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 8.sp),
              child: Center(
                child: Text(
                  tracingItem.subject,
                  style: TextStyle(
                    color: gridElement[index],
                    fontSize: 18.sp,
                    fontFamily: 'BMJUA',
                  ),
                ),
              ),
            ),
          ],
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sp),
              child: Container(
                height: 25.h + (lineCount - 1) * 15.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: gridInsideColors[index],
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Center(
                  child: Text(
                    addLineBreaks(hanja),
                    style: TextStyle(
                      color: mFontWhite,
                      fontSize: 12.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String addLineBreaks(String input) {
    int length = input.length;

    if (length >= 15) {
      int breakPoint = (length / 2).ceil();

      String top = input.substring(0, breakPoint - 1); // 위쪽 줄
      String bottom = input.substring(breakPoint - 1); // 아래쪽 줄

      input = top + '\n' + bottom; // 줄바꿈 추가
    }

    return input;
  }
}
