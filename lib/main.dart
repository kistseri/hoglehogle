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
import 'package:hoho_hanja/services/auth/login/auto_login.dart';
import 'package:hoho_hanja/utils/coupon_screen.dart';
import 'package:hoho_hanja/utils/network_check.dart';
import 'package:hoho_hanja/utils/sound.dart';
import 'package:hoho_hanja/utils/splash_screen.dart';
import 'package:hoho_hanja/widgets/dialog/version_dialog.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
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
  // kakao_flutter_sdk 2.x 부터 init 은 Future 이므로 await 필요
  await KakaoSdk.init(nativeAppKey: dotenv.get('KAKAO_APP_KEY'));

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
  final settingBox = await Hive.openBox('settingBox');
  // 저장해 둔 소리 크기 복원
  restoreVolumes(settingBox);

  // Android 는 시스템 스플래시를 바로 내리고 Flutter SplashScreen 으로 큰 로고를 보여줌
  // (Android 12+ 시스템 스플래시는 로고가 작은 원 안에만 그려짐)
  if (Platform.isAndroid) {
    FlutterNativeSplash.remove();
  } else {
    Future.delayed(
      const Duration(seconds: 2),
      () {
        FlutterNativeSplash.remove();
      },
    );
  }

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
                // 스플래시를 Navigator 위에 덮어서 그 사이 뜨는 다이얼로그도 가림
                child: Platform.isAndroid ? SplashScreen(child: child!) : child!);
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
  // 자동 로그인은 한 번만 실행되어야 한다. build가 다시 호출돼도 재실행되지 않도록
  // Future를 필드에 보관한다. (버전 확인 통과 후 최초 1회만 생성)
  Future<Widget>? _autoLoginFuture;

  @override
  void initState() {
    super.initState();
    _versionFuture = verifyVersion();
  }

  Future<bool> verifyVersion() async {
    String appleId = '6738404467';
    String playStoreId = 'com.hohoedu.hoglehogle';

    try {
      final result = await AppVersionUpdate.checkForUpdates(
        appleId: appleId,
        playStoreId: playStoreId,
        country: 'kr',
      ).timeout(const Duration(seconds: 5));

      if (result.canUpdate == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          versionDialog(Platform.isAndroid ? 'AOS' : 'IOS');
        });
        return false;
      }

      return true;
    } catch (e) {
      // 인터넷 연결 없음·타임아웃·스토어 응답 구조 변경 등으로 버전 확인에 실패하면
      // 오류 화면에 가두지 않고 그대로 앱에 진입시킨다 (업데이트 안내는 생략).
      return true;
    }
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
            _autoLoginFuture ??= checkAndPerformAutoLogin();
            return FutureBuilder(
                future: _autoLoginFuture,
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

/// 저장해 둔 배경음·효과음 크기를 플레이어에 넣음 (0~1)
/// 예전 버전은 효과음을 0~10으로 저장했으므로 1보다 크면 10으로 나눠서 바꿔 저장.
void restoreVolumes(Box box) {
  double read(String key) {
    final v = box.get(key, defaultValue: 0.0);
    return v is num ? v.toDouble() : 0.0;
  }

  final bgm = read('bgmVolume').clamp(0.0, 1.0);
  var fx = read('effectVolume');
  if (fx > 1) {
    fx = (fx / 10).clamp(0.0, 1.0);
    box.put('effectVolume', fx);
  }
  music.setVolume(bgm);
  effect.setVolume(fx.clamp(0.0, 1.0));
}
