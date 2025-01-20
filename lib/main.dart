import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hoho_hanja/_core/style.dart';
import 'package:hoho_hanja/screens/auth/login/social_login_screen.dart';
import 'package:hoho_hanja/screens/home/home_screen.dart';
import 'package:hoho_hanja/services/auth/login/auto_login.dart';
import 'package:hoho_hanja/utils/check_app_version.dart';
import 'package:hoho_hanja/utils/coupon_screen.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:hoho_hanja/utils/sound.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:path_provider/path_provider.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
final SoundEffects effect = SoundEffects();
final BackgroundMusicController music = Get.put(BackgroundMusicController());

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  //환경변수 파일 로드
  await dotenv.load(fileName: ".env");

  // 카카오 소셜 로그인
  KakaoSdk.init(nativeAppKey: dotenv.get('KAKAO_APP_KEY'));

  // 스토리지 초기화
  Get.put(const FlutterSecureStorage());

  // 네트워크연결 초기화
  Get.put(ConnectivityController());

  await versionCheck();
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
          // initialBinding: BindingsBuilder(() async {}),
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
  late Future<Widget> autoLogin;

  @override
  void initState() {
    super.initState();
    autoLogin = checkAndPerformAutoLogin();
    versionCheck();
  }

  @override
  Widget build(BuildContext context) {
    return const LoginScreen();
  }
}
