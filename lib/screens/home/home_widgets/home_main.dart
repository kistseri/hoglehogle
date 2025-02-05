import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/constants.dart';
import 'package:hoho_hanja/_core/size.dart';
import 'package:hoho_hanja/data/models/contents_data.dart';
import 'package:hoho_hanja/services/bake/bake_service.dart';
import 'package:hoho_hanja/services/cookie/cookie_service.dart';
import 'package:hoho_hanja/services/define/define_service.dart';
import 'package:hoho_hanja/services/idiom/idiom_service.dart';
import 'package:hoho_hanja/services/matching/matching_service.dart';
import 'package:hoho_hanja/services/tracing/tracing_body_service.dart';
import 'package:hoho_hanja/utils/connect_info.dart';
import 'package:hoho_hanja/widgets/dialog/unlock_dilog.dart';
import 'package:logger/logger.dart';

class HomeMain extends StatelessWidget {
  final String grade;
  final contentsData = Get.put(ContentsDataController());
  final wordCount = 0;

  HomeMain({
    super.key,
    required this.grade,
  });

  bool isContentLocked(String grade) {
    return contentsData.contentsDataList
        .any((content) => content.phase == grade && content.lock);
  }

  int getOpenPage(String? code) {
    final content = contentsData.contentsDataList
        .firstWhere((content) => content.code == code);
    return content.openPage;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 130.h,
      child: Container(
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40.r),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.sp),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '한자의 의미를 익혀요',
                style: TextStyle(
                    color: mFontMain,
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //한자 따라쓰기
                  GestureDetector(
                    onTap: () async {
                      await connectInfo(contentsCodes['tracing']);
                      await tracingBodyService(
                        grade,
                        getOpenPage(contentsCodes['tracing']),
                        isContentLocked(grade),
                      );
                    },
                    child: Container(
                      height: 110.h,
                      width: 160.w,
                      decoration: BoxDecoration(
                        image: const DecorationImage(
                            image: AssetImage('assets/images/main_tracing.png'),
                            fit: BoxFit.contain,
                            alignment: Alignment.topCenter),
                        color: Color(0xFFFFF196),
                        borderRadius: BorderRadius.all(
                          Radius.circular(35.r),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(gapQuarter),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '의미 시각화',
                              style: TextStyle(fontSize: 12.sp, height: 1),
                            ),
                            Text(
                              '획순 따라쓰기',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  //한자 맞추기
                  GestureDetector(
                    onTap: () async {
                      if (isContentLocked(grade)) {
                        await connectInfo(contentsCodes['matching']);
                        await matchingService(grade, null);
                      } else {
                        int openPage = getOpenPage(contentsCodes['matching']);
                        await connectInfo(contentsCodes['matching']);
                        await matchingService(grade, openPage);
                      }
                    },
                    child: Container(
                      height: 110.h,
                      width: 160.w,
                      decoration: BoxDecoration(
                          image: const DecorationImage(
                              image:
                                  AssetImage('assets/images/main_matching.png'),
                              fit: BoxFit.contain,
                              alignment: Alignment.topCenter),
                          color: Color(0xFFE4F2A0),
                          borderRadius:
                              BorderRadius.all(Radius.circular(35.r))),
                      child: Padding(
                        padding: EdgeInsets.all(gapQuarter),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '한자 외우기',
                              style: TextStyle(fontSize: 12.sp, height: 1),
                            ),
                            Text(
                              '한자 맞추기',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 20.h),
              Text(
                '한자의 의미를 확장시켜요',
                style: TextStyle(
                    color: mFontMain,
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //단어의 뜻 찾기
                  GestureDetector(
                    onTap: () async {
                      if (isContentLocked(grade)) {
                        await connectInfo(contentsCodes['define']);
                        await defineService(grade, contentsCodes['define']);
                      } else {
                        showUnlockDialog(grade);
                      }
                    },
                    child: Container(
                      height: 160.h,
                      width: 100.w,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/main_define.png'),
                          ),
                          color: Colors.transparent),
                      child: Padding(
                        padding: EdgeInsets.all(gapHalf),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '단어의\n뜻 찾기',
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  //단어의 의미 찾기
                  GestureDetector(
                    onTap: () async {
                      if (isContentLocked(grade)) {
                        await connectInfo(contentsCodes['bake']);
                        await bakeService(grade, contentsCodes['bake']);
                      } else {
                        showUnlockDialog(grade);
                      }
                    },
                    child: Container(
                      height: 160.h,
                      width: 100.w,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/images/main_bake.png')),
                          color: Colors.transparent),
                      child: Padding(
                        padding: EdgeInsets.all(gapHalf),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '단어의\n의미 찾기',
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (isContentLocked(grade)) {
                        await connectInfo(contentsCodes['cookie']);
                        await cookieService(grade, contentsCodes['cookie']);
                      } else {
                        showUnlockDialog(grade);
                      }
                    },
                    child: Container(
                      height: 160.h,
                      width: 100.w,
                      decoration: const BoxDecoration(
                          image: DecorationImage(
                              image:
                                  AssetImage('assets/images/main_cookie.png')),
                          color: Colors.transparent),
                      child: Padding(
                        padding: EdgeInsets.all(gapHalf),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '한자의\n뜻 맞추기',
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 10.h),
              GestureDetector(
                onTap: () async {
                  if (isContentLocked(grade)) {
                    await connectInfo(contentsCodes['idiom']);
                    await idiomService(grade, contentsCodes['idiom']);
                  } else {
                    showUnlockDialog(grade);
                  }
                },
                child: Visibility(
                  visible: grade != '80' && grade != '70',
                  child: SizedBox(
                    height: 75.h,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 50.h,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE3D3F8),
                            ),
                            child: Center(
                              child: Text(
                                '한자성어 문제',
                                style: TextStyle(
                                  color: mFontMain,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Image.asset(
                            'assets/images/icon/main_idioms.png',
                            fit: BoxFit.fill,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Image.asset(
                            'assets/images/icon/main_idioms.png',
                            fit: BoxFit.fill,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
