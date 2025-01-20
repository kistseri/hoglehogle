import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/size.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/main.dart';
import 'package:hoho_hanja/screens/auth/login/social_login_screen.dart';
import 'package:hoho_hanja/screens/setting/setting_widgets/coupon_button.dart';
import 'package:hoho_hanja/screens/setting/setting_widgets/logout_button.dart';
import 'package:hoho_hanja/screens/setting/setting_widgets/terms_and_privacy.dart';
import 'package:hoho_hanja/screens/setting/setting_widgets/withdraw_button.dart';
import 'package:hoho_hanja/services/auth/update/nickname_check_service.dart';
import 'package:hoho_hanja/utils/logout.dart';
import 'package:hoho_hanja/utils/sound.dart';
import 'package:hoho_hanja/widgets/dialog/coupon_dialog.dart';
import 'package:hoho_hanja/widgets/dialog/withdraw_dialog.dart';
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final loginController = Get.put(LoginDataController());
  final bgmController = BackgroundMusicController();
  double effectVolume = 0.0;
  double bgmVolume = 0.0;
  bool notificationsEnabled = true;
  bool isNickNameEditing = false;
  TextEditingController nicknameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nicknameController.text = loginController.loginData.value!.nickName;
    _loadVolume();
  }

  Future<void> _loadVolume() async {
    final box = Hive.box('settingBox');
    setState(() {
      effectVolume = box.get('effectVolume', defaultValue: 0.0);
      bgmVolume = box.get('bgmVolume', defaultValue: 0.0);
    });
  }

  Future<void> _saveVolume(String key, double value) async {
    final box = Hive.box('settingBox');
    await box.put(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'SETTING',
          style: TextStyle(
            color: primaryColor,
            fontSize: 32.sp,
            fontFamily: 'BMJUA',
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(gapHalf),
        child: SingleChildScrollView(
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            children: [
              // Nickname edit
              isNickNameEditing
                  ? ListTile(
                      title: TextField(
                        controller: nicknameController,
                        autofocus: true,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: mTextField, width: 2.w),
                            borderRadius:
                                BorderRadius.all(Radius.circular(50.r)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: primaryColor, width: 1.sp),
                            borderRadius:
                                BorderRadius.all(Radius.circular(50.r)),
                          ),
                          fillColor: mTextField,
                        ),
                      ),
                      leading: Text(
                        '닉네임',
                        style: TextStyle(color: mFontSub, fontSize: 16.sp),
                      ),
                      trailing: GestureDetector(
                        onTap: () {
                          setState(() {
                            nicknameCheckService(
                                'update', nicknameController.text);
                            isNickNameEditing = false;
                          });
                        },
                        child: Container(
                            decoration: BoxDecoration(
                              color: mBoxYellow,
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(gapQuarter),
                              child: Icon(
                                Icons.edit_outlined,
                                color: mFontMain,
                              ),
                            )),
                      ),
                    )
                  : Obx(
                      () => ListTile(
                        title: Text(
                          loginController.loginData.value?.nickName ?? '',
                          style: TextStyle(
                            color: mFontMain,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        leading: Text(
                          '닉네임',
                          style: TextStyle(color: mFontSub, fontSize: 16.sp),
                        ),
                        trailing: GestureDetector(
                          onTap: () {
                            setState(() {
                              isNickNameEditing = true;
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: mBoxYellow,
                              borderRadius: BorderRadius.circular(15.r),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(gapQuarter),
                              child: Icon(CupertinoIcons.pencil),
                            ),
                          ),
                        ),
                      ),
                    ),
              // 계정 id
              ListTile(
                title: Text(
                  loginController.loginData.value!.id,
                  style: TextStyle(
                    color: mFontMain,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  softWrap: false,
                  overflow: TextOverflow.visible,
                ),
                leading: Text(
                  '계정ID',
                  style: TextStyle(color: mFontSub, fontSize: 16.sp),
                ),
              ),
              // 배경음 조절
              ListTile(
                leading: Text(
                  '배경음',
                  style: TextStyle(color: mFontSub, fontSize: 16.sp),
                ),
                title: Slider(
                  value: music.getVolume(),
                  min: 0.0,
                  max: 1.0,
                  inactiveColor: Colors.yellow,
                  activeColor: Colors.green,
                  onChanged: (value) {
                    setState(() {
                      music.setVolume(value);
                      _saveVolume('bgmVolume', value);
                    });
                  },
                ),
              ),
              // 효과음 조절
              ListTile(
                leading: Text(
                  '효과음',
                  style: TextStyle(color: mFontSub, fontSize: 16.sp),
                ),
                title: Slider(
                  value: effect.getVolume(),
                  min: 0.0,
                  max: 10.0,
                  inactiveColor: Colors.yellow,
                  activeColor: Colors.green,
                  onChanged: (value) {
                    setState(() {
                      // effectVolume = value < 0.5 ? 0.0 : 1.0;
                      effect.setVolume(value);
                      _saveVolume('effectVolume', value);
                    });
                  },
                ),
              ),
              SizedBox(height: 20.h),
              // 쿠폰 등록
              const CouponButton(),
              SizedBox(height: 20.h),
              // 로그 아웃
              const LogoutButton(),
              SizedBox(height: 20.h),
              // 회원 탈퇴
              const WithdrawButton(),
              SizedBox(height: 20.h),
              // 서비스 약관 및 이용 동의
              const TermsAndPrivacy(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    bgmController.dispose();
    nicknameController.dispose();
    super.dispose();
  }
}
