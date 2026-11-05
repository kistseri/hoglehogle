import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/data/DTO/requestDTO/loginDTO.dart';
import 'package:hoho_hanja/screens/auth/auth_widgets/auth_layout.dart';
import 'package:hoho_hanja/screens/auth/find/email_find_screen.dart';
import 'package:hoho_hanja/screens/auth/find/password_find_screen.dart';
import 'package:hoho_hanja/screens/auth/join/join_screen.dart';
import 'package:hoho_hanja/services/auth/login/login_service.dart';
import 'package:hoho_hanja/utils/design_scale.dart';
import 'package:hoho_hanja/utils/encryption.dart';

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
}

class KeyboardScroll extends GetxController {
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  final GlobalKey loginButtonKey = GlobalKey(); // 키보드 위로 보이게 할 로그인 버튼
  RxBool isFocused = false.obs;

  // 비밀번호 입력 중 로그인 버튼이 키보드에 가리면 그만큼만 올림 (화면 크기와 상관없이)
  void scrollToLoginButton() {
    Future.delayed(const Duration(milliseconds: 300), () {
      final ctx = loginButtonKey.currentContext;
      if (!scrollController.hasClients || ctx == null || !ctx.mounted) return;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null || !box.attached) return;
      final mq = MediaQuery.of(ctx);
      final buttonBottom = box.localToGlobal(Offset(0, box.size.height)).dy;
      final visibleBottom = mq.size.height - mq.viewInsets.bottom - box.size.height * 0.3;
      final diff = buttonBottom - visibleBottom;
      if (diff <= 0) return;
      final position = scrollController.position;
      scrollController.animateTo(
        (scrollController.offset + diff).clamp(position.minScrollExtent, position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  void scrollToTop() {
    Future.delayed(
      Duration.zero,
      () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut,
          );
        }
      },
    );
  }

  @override
  void onInit() {
    super.onInit();
    focusNode.addListener(() {
      isFocused.value = focusNode.hasFocus;
      if (focusNode.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          scrollToLoginButton();
        });
      }
    });
  }

  @override
  void onClose() {
    focusNode.dispose();
    scrollController.dispose();
    super.onClose();
  }
}

class PasswordVisibleController extends GetxController {
  var passwordVisible = false.obs;

  void switchPasswordVisibility() {
    passwordVisible.value = !passwordVisible.value;
  }
}

class AutoLoginCheckController extends GetxController {
  var isChecked = false.obs;

  void updateCheck(bool newValue) {
    isChecked.value = newValue;
  }
}

class LocalLoginScreen extends StatefulWidget {
  const LocalLoginScreen({super.key});

  @override
  State<LocalLoginScreen> createState() => _LocalLoginScreenState();
}

class _LocalLoginScreenState extends State<LocalLoginScreen> {
  final loginController = Get.put(LoginController());
  final passwordVisibleController = Get.put(PasswordVisibleController());
  final autoLoginCheckController = Get.put(AutoLoginCheckController());
  final scroll = Get.put(KeyboardScroll());

  LoginDTO setLoginDTO() {
    String id = loginController.emailController.text;
    String pwd = sha256_convertHash(loginController.passwordController.text);
    return LoginDTO(email: id, shaPassword: pwd);
  }

  @override
  Widget build(BuildContext context) {
    final sc = DesignScale.fromContext(context);

    // 아이디 찾기 | 비밀번호 찾기 | 회원가입
    Widget link(String text, VoidCallback onTap) {
      return GestureDetector(
        onTap: onTap,
        child: Text(text, style: TextStyle(fontSize: sc.d(14))),
      );
    }

    Widget divider() {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: sc.d(10)),
        child: Container(width: sc.d(1), height: sc.d(14), color: Colors.black),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          scroll.scrollToTop();
          FocusScope.of(context).unfocus();
        },
        child: AuthSheetLayout(
          scale: sc,
          controller: scroll.scrollController,
          child: Padding(
            padding: EdgeInsets.fromLTRB(sc.d(32), sc.d(56), sc.d(32), sc.d(32)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 이메일
                SizedBox(
                  height: sc.d(50),
                  child: TextField(
                    controller: loginController.emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: authInputStyle(sc),
                    decoration: authInputDecoration(
                      sc,
                      hintText: '이메일',
                      icon: 'assets/images/icon/login_id.png',
                    ),
                    cursorColor: mFontMain,
                  ),
                ),
                // 비밀번호
                Padding(
                  padding: EdgeInsets.only(top: sc.d(20)),
                  child: Obx(() {
                    final visible = passwordVisibleController.passwordVisible.value;
                    return SizedBox(
                      height: sc.d(50),
                      child: TextField(
                        focusNode: scroll.focusNode,
                        controller: loginController.passwordController,
                        obscureText: !visible,
                        style: authInputStyle(sc),
                        decoration: authInputDecoration(
                          sc,
                          hintText: '비밀번호',
                          icon: 'assets/images/icon/login_pw.png',
                          focusColor: mFontYellow,
                          suffixIcon: IconButton(
                            iconSize: sc.d(24),
                            padding: EdgeInsets.symmetric(horizontal: sc.d(12)),
                            constraints: const BoxConstraints(),
                            style: IconButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                            icon: Icon(visible ? Icons.visibility : Icons.visibility_off),
                            onPressed: passwordVisibleController.switchPasswordVisibility,
                          ),
                        ),
                        cursorColor: mFontMain,
                      ),
                    );
                  }),
                ),
                // 자동로그인
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: sc.d(16), vertical: sc.d(4)),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '자동로그인 켜기',
                          style: TextStyle(color: mFontSub, fontSize: sc.d(12)),
                        ),
                      ),
                      SizedBox(
                        height: sc.d(40),
                        child: FittedBox(
                          child: Obx(
                            () => Switch(
                              activeThumbColor: Colors.green,
                              value: autoLoginCheckController.isChecked.value,
                              onChanged: autoLoginCheckController.updateCheck,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 로그인 버튼
                AuthButton(
                  key: scroll.loginButtonKey,
                  text: '로그인',
                  color: const Color(0xFF3D925C),
                  fontSize: 20,
                  onTap: _onLogin,
                ),
                Padding(
                  padding: EdgeInsets.only(top: sc.d(16)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      link('아이디 찾기', () => Get.to(() => const EmailFindScreen())),
                      divider(),
                      link('비밀번호 찾기', () => Get.to(() => const PasswordFindScreen())),
                      divider(),
                      link('회원가입', () => Get.to(() => JoinScreen(method: "0"))),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: sc.d(60)),
                  child: GestureDetector(
                    onTap: Get.back,
                    child: Text('다른 방법으로 로그인 하기', style: TextStyle(fontSize: sc.d(14))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 키패드를 내리고, 완전히 내려갈 때까지 기다림 (외부 키보드처럼 안 떠 있으면 바로 끝남)
  Future<void> _hideKeyboard() async {
    FocusManager.instance.primaryFocus?.unfocus();
    scroll.scrollToTop();
    final view = View.of(context);
    final deadline = DateTime.now().add(const Duration(milliseconds: 800)); // 혹시 못 받아도 무한 대기 방지
    while (view.viewInsets.bottom > 0 && DateTime.now().isBefore(deadline)) {
      await Future.delayed(const Duration(milliseconds: 16));
    }
  }

  Future<void> _onLogin() async {
    await _hideKeyboard();
    if (!mounted) return;

    if (loginController.emailController.text.isEmpty) {
      Get.defaultDialog(
        title: '로그인 실패',
        middleText: '이메일을 입력해주세요.',
        textConfirm: '확인',
        buttonColor: primaryColor,
        onConfirm: () {
          Get.back();
        },
      );
    } else if (loginController.passwordController.text.isEmpty) {
      Get.defaultDialog(
        title: '로그인 실패',
        middleText: '비밀번호를 입력해주세요.',
        textConfirm: '확인',
        buttonColor: primaryColor,
        onConfirm: () {
          Get.back();
        },
      );
    } else {
      loginService(
        setLoginDTO(),
        autoLoginCheckController.isChecked.value,
      );
    }
  }
}
