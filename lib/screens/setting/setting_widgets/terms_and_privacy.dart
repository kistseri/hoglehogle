import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/size.dart';

class TermsAndPrivacy extends StatelessWidget {
  const TermsAndPrivacy({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: gapQuarter),
      child: SizedBox(
        height: 16.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                _showdialog(context, '호글호글 이용약관', 'hogulhogul_terms.txt');
              },
              child: Text(
                '호글호글 이용약관',
                style: TextStyle(color: mFontLightGray),
              ),
            ),
            VerticalDivider(
              color: mFontLightGray,
              thickness: 1.w,
              width: 10.w,
            ),
            GestureDetector(
              onTap: () {
                _showdialog(context, '개인정보 처리방침', 'hogulhogul_privacy.txt');
              },
              child: Text(
                '개인정보 처리방침',
                style: TextStyle(color: mFontLightGray),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showdialog(BuildContext context, String title, String fileUrl) async {
    Future<String> loadTerms() async {
      return await rootBundle.loadString('assets/text/$fileUrl');
    }

    final String termsContent = await loadTerms();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black.withOpacity(0.5),
      pageBuilder: (BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.all(gapMain),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: BoxDecoration(
                  color: mBackWhite,
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(gapHalf),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: mFontMain,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          termsContent,
                          style: TextStyle(color: mFontSub),
                        ),
                        SizedBox(height: 20.h),
                        Align(
                          alignment: Alignment.center,
                          child: GestureDetector(
                              onTap: () {
                                Get.back();
                              },
                              child: Text('닫기')),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}
