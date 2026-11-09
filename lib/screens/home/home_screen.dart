import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/main.dart';
import 'package:hoho_hanja/screens/home/home_widgets/home_body.dart';
import 'package:hoho_hanja/screens/myroom/my_room_screen.dart';
import 'package:hoho_hanja/screens/rank/rank_screen.dart';
import 'package:hoho_hanja/screens/setting/setting_screen.dart';
import 'package:hoho_hanja/services/myroom/my_room_service.dart';
import 'package:hoho_hanja/services/purchase/product_service.dart';
import 'package:hoho_hanja/services/rank/rank_service.dart';
import 'package:hoho_hanja/utils/design_scale.dart';
import 'package:hoho_hanja/utils/get_main_notice.dart';
import 'package:hoho_hanja/widgets/appbar/design_app_bar.dart';

import '../../services/myroom/load_item_service.dart';
import '../../utils/contents_lock.dart';

class HomeController extends GetxController {
  final homeValue = "80".obs;

  void homeValueUpdate(String value) {
    homeValue.value = value;
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver, RouteAware {
  int _selectedIndex = 2;
  final HomeController homeController = Get.put(HomeController(), permanent: true);

  @override
  void initState() {
    super.initState();
    mainNotice();

    WidgetsBinding.instance.addObserver(this);
    music.playBackgroundMusic('main');
    contentsLock(homeController.homeValue.value);
    rankService();
    myroomService();
    loadItemService();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context)!;
    if (route is PageRoute<dynamic>) {
      routeObserver.subscribe(this, route);
    }
  }

  void _onTabChanged(int index) {
    setState(() {
      _selectedIndex = index;
      if (_selectedIndex == 2) {
        music.playBackgroundMusic('main');
      } else {
        music.stopBackgroundMusic();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 홈 위에 게임이 떠 있어도 이 화면이 받으므로, 홈 음악을 새로 틀지 않고 지금 음악을 멈췄다 이어서 틂
    // (예전에는 게임 중에 앱을 내렸다 오면 게임 음악 대신 홈 음악이 나왔음)
    if (state == AppLifecycleState.paused) {
      music.pauseForBackground();
    } else if (state == AppLifecycleState.resumed) {
      music.resumeFromBackground();
    }
    super.didChangeAppLifecycleState(state);
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 2) {
      setState(() {
        _selectedIndex = 2;
      });
      return false;
    }
    return false;
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    music.stopBackgroundMusic();
    super.dispose();
  }

  @override
  void didPushNext() {
    music.stopBackgroundMusic();
  }

  @override
  void didPopNext() {
    music.playBackgroundMusic('main');
  }

  void _onHomeAppBarValueChanged(String value) async {
    await contentsLock(value);
    homeController.homeValueUpdate(value);
  }

  PreferredSizeWidget? _buildAppBar() {
    if (_selectedIndex == 2) {
      // 홈은 앱바·하단 탭까지 HomeBody가 시안 비율대로 직접 그림
      return null;
    } else if (_selectedIndex == 1) {
      return null;
    }
    // 랭킹(초록 배경)·설정(흰 배경): 홈과 같은 시안 좌표·크기 앱바 (탭을 오가도 코인·다이아·프로필 위치가 그대로)
    final onGreen = _selectedIndex == 0;
    final mq = MediaQuery.of(context);
    final sc = DesignScale.of(mq.size, mq.padding);
    return PreferredSize(
      preferredSize: Size.fromHeight(sc.d(DesignAppBar.height)),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: onGreen ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: ColoredBox(
          color: onGreen ? primaryColor : Colors.white,
          child: DesignAppBar(
            scale: sc,
            onGreen: onGreen,
            onPressed: () => _onTabChanged(2),
            onAvatarPressed: () => _onTabChanged(1),
            onDiamondPressed: () async => await productService(),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const RankScreen();
      case 1:
        return MyRoomScreen(onPressed: () => _onTabChanged(2));
      case 3:
        return const SettingScreen();
      default:
        return Obx(
          () => HomeBody(
            grade: homeController.homeValue.value,
            onGradeChanged: (value) {
              homeController.homeValueUpdate(value);
              _onHomeAppBarValueChanged(value);
            },
            onTabChanged: _onTabChanged,
            onAvatarPressed: () => _onTabChanged(1),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedIndex != 2 ? false : true,
      onPopInvokedWithResult: (didPop, result) {
        _onWillPop();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }
}
