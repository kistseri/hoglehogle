import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/size.dart';
import 'package:hoho_hanja/services/coupon/coupon_service.dart';

Future<void> showCouponDialog(BuildContext context) async {
  TextEditingController couponController = TextEditingController();
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Center(
          child: Text(
            '쿠폰 입력',
            style: TextStyle(
              color: primaryColor,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        content: TextField(
          controller: couponController,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: mTextField, width: 2.w),
              borderRadius: BorderRadius.all(Radius.circular(50.r)),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: primaryColor, width: 1.sp),
              borderRadius: BorderRadius.all(Radius.circular(50.r)),
            ),
            fillColor: mTextField,
          ),
          cursorColor: mFontMain,
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            LengthLimitingTextInputFormatter(9),
            FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  couponService(couponController.text);
                },
                child: Container(
                    decoration: BoxDecoration(
                        color: mBtnActive,
                        borderRadius: BorderRadius.circular(10.r)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: gapQuarter,
                        horizontal: gapMain,
                      ),
                      child: Text(
                        '등록',
                        style: TextStyle(color: mFontWhite, fontSize: 16.sp),
                      ),
                    )),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                    decoration: BoxDecoration(
                        color: mBtnBack,
                        borderRadius: BorderRadius.circular(10.r)),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: gapQuarter,
                        horizontal: gapMain,
                      ),
                      child: Text(
                        '취소',
                        style: TextStyle(color: mFontWhite, fontSize: 16.sp),
                      ),
                    )),
              ),
            ],
          ),
        ],
      );
    },
  );
}
