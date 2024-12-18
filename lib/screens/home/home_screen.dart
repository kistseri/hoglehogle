import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/main.dart';
import 'package:hoho_hanja/screens/home/home_widgets/home_body.dart';
import 'package:hoho_hanja/screens/myroom/my_room_screen.dart';
import 'package:hoho_hanja/screens/rank/rank_screen.dart';
import 'package:hoho_hanja/screens/setting/setting_screen.dart';
import 'package:hoho_hanja/services/myroom/my_room_service.dart';
import 'package:hoho_hanja/services/rank/rank_service.dart';
import 'package:hoho_hanja/widgets/appbar/custom_appbar.dart';
import 'package:hoho_hanja/widgets/appbar/home_app_bar.dart';
import 'package:hoho_hanja/widgets/appbar/rank_appbar.dart';
import 'package:hoho_hanja/widgets/custom_bottom.dart';
import 'package:logger/logger.dart';

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

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, RouteAware {
  int _selectedIndex = 2;
  final HomeController homeController =
      Get.put(HomeController(), permanent: true);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    music.playBackgroundMusic('main');
    contentsLock(homeController.homeValue.value);
    rankService();
    myroomService();
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
    if (state == AppLifecycleState.paused) {
      music.stopBackgroundMusic();
    } else if (state == AppLifecycleState.resumed && _selectedIndex == 2) {
      music.playBackgroundMusic('main');
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
      return HomeAppBar(onValueChanged: _onHomeAppBarValueChanged);
    } else if (_selectedIndex == 0) {
      return RankAppBar(onPressed: () => _onTabChanged(2));
    } else if (_selectedIndex == 1) {
      return null;
    } else {
      return CustomAppBar(onPressed: () => _onTabChanged(2));
    }
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const RankScreen();
      case 1:
        return const MyRoomScreen();
      case 3:
        return const SettingScreen();
      default:
        return Obx(
          () => HomeBody(
            grade: homeController.homeValue.value,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedIndex != 2 ? false : true,
      onPopInvoked: (didPop) {
        _onWillPop();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: _buildBody(),
        bottomNavigationBar: _selectedIndex == 2
            ? CustomBottom(
                onTabChanged: _onTabChanged,
                selectedIndex: _selectedIndex,
              )
            : null,
      ),
    );
  }
}
