import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/size.dart';
import 'package:hoho_hanja/data/DTO/requestDTO/loginDTO.dart';
import 'package:hoho_hanja/screens/auth/find/email_find_screen.dart';
import 'package:hoho_hanja/screens/auth/find/password_find_screen.dart';
import 'package:hoho_hanja/screens/auth/join/join_screen.dart';
import 'package:hoho_hanja/services/auth/login/login_service.dart';
import 'package:hoho_hanja/utils/encryption.dart';

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
}

class KeyboardScroll extends GetxController {
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  RxBool isFocused = false.obs;

  void scrollToBottom() {
    Future.delayed(Duration(milliseconds: 300), () {
      if (scrollController.hasClients) {
        // final middlePosition = scrollController.position.maxScrollExtent / 3;
        scrollController.animateTo(
          // middlePosition,
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {}
    });
  }

  void scrollToTop() {
    Future.delayed(
      Duration.zero,
      () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.minScrollExtent,
            duration: Duration(milliseconds: 100),
            curve: Curves.easeInOut,
          );
        } else {}
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
          scrollToBottom();
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
    bool? selectValue = false;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          scroll.scrollToTop();
          scroll.focusNode.unfocus();
        },
        child: Stack(
          children: [
            Image.asset(
              'assets/images/login_bg.png',
              fit: BoxFit.cover,
            ),
            Column(
              children: [
                Expanded(
                  flex: 30,
                  child: Container(
                    width: double.infinity,
                    height: 200.h,
                    color: Colors.transparent,
                  ),
                ),
                Expanded(
                  flex: 75,
                  child: Container(
                    decoration: BoxDecoration(
                        color: mBackWhite,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30.r),
                          topRight: Radius.circular(30.r),
                        )),
                    child: SingleChildScrollView(
                      controller: scroll.scrollController,
                      physics: scroll.isFocused.value
                          ? BouncingScrollPhysics()
                          : NeverScrollableScrollPhysics(),
                      child: IntrinsicHeight(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.sp),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 40.h),
                                // 이메일 TextField
                                SizedBox(
                                  height: 50.h,
                                  child: TextField(
                                    controller: loginController.emailController,
                                    decoration: InputDecoration(
                                      hintText: '이메일',
                                      hintStyle:
                                          const TextStyle(color: mFontSub),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: mTextField, width: 2),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(50.r)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: mBoxYellow, width: 2.sp),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(50.r)),
                                      ),
                                      fillColor: mBackWhite,
                                      prefixIcon: Padding(
                                        padding: EdgeInsets.all(gapSmall),
                                        child: Image.asset(
                                            'assets/images/icon/login_id.png'),
                                      ),
                                    ),
                                    cursorColor: mFontMain,
                                  ),
                                ),
                                // 여백
                                SizedBox(height: 20.h),
                                // 비밀번호 TextField
                                Obx(() {
                                  return SizedBox(
                                    height: 50.h,
                                    child: TextField(
                                      focusNode: scroll.focusNode,
                                      controller:
                                          loginController.passwordController,
                                      obscureText: !passwordVisibleController
                                          .passwordVisible.value,
                                      decoration: InputDecoration(
                                        hintText: '비밀번호',
                                        hintStyle:
                                            const TextStyle(color: mFontSub),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: mTextField, width: 2.w),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(50.r)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: mFontYellow, width: 2.w),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(50.r)),
                                        ),
                                        fillColor: mBackWhite,
                                        prefixIcon: Padding(
                                          padding: EdgeInsets.all(gapSmall),
                                          child: Image.asset(
                                              'assets/images/icon/login_pw.png'),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            passwordVisibleController
                                                    .passwordVisible.value
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                          ),
                                          onPressed: () {
                                            passwordVisibleController
                                                .switchPasswordVisibility();
                                          },
                                        ),
                                      ),
                                      cursorColor: mFontMain,
                                    ),
                                  );
                                }),
                                Obx(
                                  () {
                                    return SwitchListTile(
                                      title: Text(
                                        '자동로그인 켜기',
                                        style: TextStyle(
                                            color: mFontSub, fontSize: 12.sp),
                                      ),
                                      activeColor: Colors.green,
                                      value: autoLoginCheckController
                                          .isChecked.value,
                                      onChanged: (value) {
                                        setState(() {
                                          autoLoginCheckController
                                              .updateCheck(value);
                                        });
                                      },
                                    );
                                  },
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (loginController
                                        .emailController.text.isEmpty) {
                                      Get.defaultDialog(
                                        title: '로그인 실패',
                                        middleText: '이메일을 입력해주세요.',
                                        textConfirm: '확인',
                                        buttonColor: primaryColor,
                                        onConfirm: () {
                                          Get.back();
                                        },
                                      );
                                    } else if (loginController
                                        .passwordController.text.isEmpty) {
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
                                        autoLoginCheckController
                                            .isChecked.value,
                                      );
                                    }
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: 50.0.h,
                                    decoration: BoxDecoration(
                                        color: Color(0xFF3D925C),
                                        borderRadius:
                                            BorderRadius.circular(50.sp)),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.w),
                                      child: Center(
                                        child: Text(
                                          '로그인',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10.0.h),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      GestureDetector(
                                          onTap: () {
                                            Get.to(
                                                () => const EmailFindScreen());
                                          },
                                          child: const Text('아이디 찾기')),
                                      VerticalDivider(
                                        color: Colors.black,
                                        thickness: 1.w,
                                        width: 20.w,
                                      ),
                                      GestureDetector(
                                          onTap: () {
                                            Get.to(() =>
                                                const PasswordFindScreen());
                                          },
                                          child: const Text('비밀번호 찾기')),
                                      VerticalDivider(
                                        color: Colors.black,
                                        thickness: 1.w,
                                        width: 20.w,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Get.to(() => JoinScreen(
                                                method: "0",
                                              ));
                                        },
                                        child: Text('회원가입'),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 125.h),
                                GestureDetector(
                                  onTap: Get.back,
                                  child: const Center(
                                    child: Text('다른 방법으로 로그인 하기'),
                                  ),
                                ),
                                SizedBox(height: 80.h),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
