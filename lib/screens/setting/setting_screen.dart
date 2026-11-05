import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/main.dart';
import 'package:hoho_hanja/screens/setting/setting_widgets/coupon_button.dart';
import 'package:hoho_hanja/screens/setting/setting_widgets/logout_button.dart';
import 'package:hoho_hanja/screens/setting/setting_widgets/terms_and_privacy.dart';
import 'package:hoho_hanja/screens/setting/setting_widgets/withdraw_button.dart';
import 'package:hoho_hanja/services/auth/update/nickname_check_service.dart';
import 'package:hoho_hanja/utils/design_scale.dart';
import 'package:hoho_hanja/widgets/dialog/dialog.dart';

/// 설정 (홈의 설정 탭 본문, 앱바 아래)
///
/// 크기·글자·여백은 시안(360 폭) 단위로 정하고 앱바와 같은 배율로 키우거나 줄임.
/// 태블릿처럼 옆으로 넓으면 시안 폭을 화면 가운데에 놓음.
class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final loginController = Get.put(LoginDataController());
  final nicknameController = TextEditingController();
  bool isNickNameEditing = false;
  bool _savingNickname = false;

  // 소리 크기는 앱 시작 때 main.dart의 restoreVolumes가 플레이어에 넣어 둠
  String get _nickName => loginController.loginData.value?.nickName ?? '';

  Future<void> _saveVolume(String key, double value) async {
    await Hive.box('settingBox').put(key, value);
  }

  void _startEditing() {
    nicknameController.text = _nickName;
    setState(() => isNickNameEditing = true);
  }

  Future<void> _submitNickname() async {
    if (_savingNickname) return;
    final name = nicknameController.text.trim();
    if (name.isEmpty) {
      failDialog('변경 실패', '닉네임을 입력해주세요.');
      return;
    }
    if (name == _nickName) {
      setState(() => isNickNameEditing = false); // 그대로면 서버에 보내지 않고 닫기
      return;
    }
    setState(() => _savingNickname = true);
    final status = await nicknameCheckService('update', name);
    if (!mounted) return;
    setState(() {
      _savingNickname = false;
      // 실패하면 고칠 수 있도록 입력칸을 그대로 둠
      if (status == 'available') isNickNameEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sc = DesignScale.ofScreen(context); // 앱바와 같은 배율
    double d(num v) => sc.d(v);
    final bottom = MediaQuery.paddingOf(context).bottom;

    TextStyle label() => TextStyle(color: mFontSub, fontSize: d(14));
    TextStyle value() => TextStyle(color: mFontMain, fontSize: d(17), fontWeight: FontWeight.bold);

    // 한 줄: 왼쪽 이름(고정 폭) + 내용 + 오른쪽 버튼
    Widget row(String name, Widget child, {Widget? trailing}) {
      return SizedBox(
        height: d(56),
        child: Row(
          children: [
            SizedBox(width: d(64), child: Text(name, style: label())),
            Expanded(child: child),
            if (trailing != null) Padding(padding: EdgeInsets.only(left: d(8)), child: trailing),
          ],
        ),
      );
    }

    Widget squareButton(IconData icon, VoidCallback? onTap) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: d(36),
          height: d(36),
          decoration: BoxDecoration(color: mBoxYellow, borderRadius: BorderRadius.circular(d(10))),
          child: _savingNickname
              ? Padding(
                  padding: EdgeInsets.all(d(10)),
                  child: CircularProgressIndicator(strokeWidth: d(2), color: mFontMain),
                )
              : Icon(icon, color: mFontMain, size: d(20)),
        ),
      );
    }

    Widget slider(double v, ValueChanged<double> onChanged) {
      return SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: d(4),
          thumbShape: RoundSliderThumbShape(enabledThumbRadius: d(9)),
          overlayShape: RoundSliderOverlayShape(overlayRadius: d(18)),
        ),
        child: Slider(
          value: v.clamp(0.0, 1.0),
          min: 0.0,
          max: 1.0,
          inactiveColor: Colors.yellow,
          activeColor: Colors.green,
          onChanged: onChanged,
        ),
      );
    }

    final nicknameRow = isNickNameEditing
        ? row(
            '닉네임',
            SizedBox(
              height: d(40),
              child: TextField(
                controller: nicknameController,
                autofocus: true,
                enabled: !_savingNickname,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submitNickname(),
                style: TextStyle(color: mFontMain, fontSize: d(15)),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: mTextField,
                  contentPadding: EdgeInsets.symmetric(horizontal: d(14), vertical: d(10)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: mTextField, width: d(2)),
                    borderRadius: BorderRadius.circular(d(20)),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: mTextField, width: d(2)),
                    borderRadius: BorderRadius.circular(d(20)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: primaryColor, width: d(1.5)),
                    borderRadius: BorderRadius.circular(d(20)),
                  ),
                ),
              ),
            ),
            trailing: squareButton(Icons.check_rounded, _submitNickname),
          )
        : row(
            '닉네임',
            Obx(() => Text(
                  loginController.loginData.value?.nickName ?? '',
                  style: value(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )),
            trailing: squareButton(CupertinoIcons.pencil, _startEditing),
          );

    // 내용이 짧아도 화면 끝까지 흰 바탕
    return SizedBox.expand(
      child: ColoredBox(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: bottom + d(16)),
          child: Center(
            child: SizedBox(
              width: d(DesignScale.designWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: d(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 제목 (앱바는 홈 화면이 다른 탭과 같은 시안 앱바로 그림)
                    Padding(
                      padding: EdgeInsets.only(top: d(4), bottom: d(8)),
                      child: Center(
                        child: Text('SETTING',
                            style: TextStyle(color: primaryColor, fontSize: d(30), fontFamily: 'BMJUA')),
                      ),
                    ),
                    nicknameRow,
                    // 계정 id (소셜 ID처럼 길면 두 줄까지, 그보다 길면 ...)
                    row(
                      '계정ID',
                      Obx(() => Text(
                            loginController.loginData.value?.id ?? '',
                            style: value().copyWith(fontSize: d(15)),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )),
                    ),
                    // 배경음
                    row(
                        '배경음',
                        slider(music.getVolume(), (v) {
                          setState(() => music.setVolume(v));
                          _saveVolume('bgmVolume', v);
                        })),
                    // 효과음
                    row(
                        '효과음',
                        slider(effect.getVolume(), (v) {
                          setState(() => effect.setVolume(v));
                          _saveVolume('effectVolume', v);
                        })),
                    // 쿠폰 등록
                    Padding(padding: EdgeInsets.only(top: d(20)), child: CouponButton(scale: sc)),
                    // 로그 아웃
                    Padding(padding: EdgeInsets.only(top: d(14)), child: LogoutButton(scale: sc)),
                    // 회원 탈퇴
                    Padding(padding: EdgeInsets.only(top: d(14)), child: WithdrawButton(scale: sc)),
                    // 서비스 약관 및 이용 동의
                    Padding(padding: EdgeInsets.only(top: d(24)), child: TermsAndPrivacy(scale: sc)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nicknameController.dispose();
    super.dispose();
  }
}
