import 'dart:io';

import 'package:app_version_update/app_version_update.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hoho_hanja/_core/http.dart';
import 'package:hoho_hanja/_core/style.dart';
import 'package:hoho_hanja/screens/auth/login/social_login_screen.dart';
import 'package:hoho_hanja/screens/home/home_screen.dart';
import 'package:hoho_hanja/services/auth/login/auto_login.dart';
import 'package:hoho_hanja/utils/check_app_version.dart';
import 'package:hoho_hanja/utils/coupon_screen.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:hoho_hanja/utils/sound.dart';
import 'package:hoho_hanja/widgets/dialog/version_dialog.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
final SoundEffects effect = SoundEffects();
final BackgroundMusicController music = Get.put(BackgroundMusicController());
final double screenWidth = MediaQuery.of(Get.context!).size.width;
final double screenHeight = MediaQuery.of(Get.context!).size.height;

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  //환경변수 파일 로드
  await dotenv.load(fileName: ".env");

  // 카카오 소셜 로그인
  KakaoSdk.init(nativeAppKey: dotenv.get('KAKAO_APP_KEY'));

  // 스토리지 초기화
  Get.put(const FlutterSecureStorage());

  // 구형 안드로이드 인증서(Sectigo Root R46) 신뢰 설정
  await setupDioCertificates();

  // 네트워크연결 초기화
  Get.put(ConnectivityController());
  await settingScreen();

  //화면 세로방향 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Hive 초기화
  var appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  await Hive.openBox('settingBox');

  Future.delayed(
    const Duration(seconds: 2),
    () {
      FlutterNativeSplash.remove();
    },
  );

  runApp(
    ScreenUtilInit(
      designSize: const Size(360, 720),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          initialBinding: BindingsBuilder(() {}),
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.light,
          navigatorObservers: [routeObserver],
          home: const MyApp(),
          builder: (context, child) {
            return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.noScaling,
                ),
                child: child!);
          },
        );
      },
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<bool> _versionFuture;

  @override
  void initState() {
    super.initState();
    _versionFuture = verifyVersion();
  }

  Future<bool> verifyVersion() async {
    String appleId = '6738404467';
    String playStoreId = 'com.hohoedu.hoglehogle';
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    final result = await AppVersionUpdate.checkForUpdates(
      appleId: appleId,
      playStoreId: playStoreId,
      country: 'kr',
    );

    if (result.canUpdate == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        versionDialog(Platform.isAndroid ? 'AOS' : 'IOS');
      });
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _versionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Expanded(child: Center(child: CircularProgressIndicator())),
                Expanded(child: Text('버전을 확인하고 있습니다.')),
              ],
            )),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('버전 확인 중 오류 발생: ${snapshot.error}'),
            ),
          );
        } else {
          bool versionOk = snapshot.data ?? false;
          if (versionOk) {
            return FutureBuilder(
                future: checkAndPerformAutoLogin(),
                builder: (context, snapshot) {
                  return const LoginScreen();
                });
          } else {
            return const LoginScreen();
          }
        }
      },
    );
  }
}
