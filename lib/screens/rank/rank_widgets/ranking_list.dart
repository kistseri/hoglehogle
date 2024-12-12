import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/size.dart';
import 'package:hoho_hanja/data/models/rank_data.dart';
import 'package:hoho_hanja/widgets/dashed_divider.dart';
import 'package:logger/logger.dart';

class RankingList extends StatelessWidget {
  final RankDataController rankDataController;
  const RankingList({
    super.key,
    required this.rankDataController,
  });

  @override
  Widget build(BuildContext context) {
    Logger().d('MediaQuery = ${MediaQuery.of(context).size.height * 0.7}');
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(50.r)),
        child: Container(
          color: mBackWhite,
          height: 450.h,
          child: Padding(
            padding:
                EdgeInsets.only(top: gapHuge, right: gapHalf, left: gapHalf),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                      width: 30.w,
                      child: Center(
                        child: Text(
                          '순위',
                          style: TextStyle(
                              color: mFontLightGray,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListTile(
                        title: Text(
                          '닉네임',
                          style: TextStyle(
                              color: mFontLightGray,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold),
                        ),
                        trailing: Text(
                          '점수',
                          style: TextStyle(
                              color: mFontLightGray,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: rankDataController.rankDataList!.length - 3,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: gapHalf),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Center(
                                  child: SizedBox(
                                    width: 30.w,
                                    child: Text(
                                      '${index + 4}',
                                      style: TextStyle(
                                          color: mFontLightGray,
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: ListTile(
                                    title: Row(
                                      children: [
                                        SizedBox(width: 8.w),
                                        Text(
                                          rankDataController
                                              .rankDataList![index + 3]
                                              .nickName,
                                          style: TextStyle(fontSize: 15.sp),
                                        ),
                                      ],
                                    ),
                                    trailing: Text(
                                      '${rankDataController.rankDataList![index + 3].totalPoints}',
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const DashedHorizontalDivider(),
                        ],
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
