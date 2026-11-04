import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/_core/constants.dart';
import 'package:hoho_hanja/data/models/login_data.dart';
import 'package:hoho_hanja/data/models/rank_data.dart';
import 'package:hoho_hanja/screens/myroom/myroom_wigets/my_room_item.dart';
import 'package:hoho_hanja/screens/rank/rank_widgets/rank_card.dart';
import 'package:hoho_hanja/screens/rank/rank_widgets/ranking_list.dart';
import 'package:hoho_hanja/services/rank/rank_service.dart';
import 'package:hoho_hanja/utils/design_scale.dart';
import 'package:hoho_hanja/widgets/dialog/rank_dialog.dart';

/// 월간 랭킹 (홈의 랭킹 탭 본문, 앱바 아래)
///
/// 배치는 시안(360 폭) 좌표 그대로, 앱바와 같은 배율이라 기기마다 비율이 같음.
/// 태블릿처럼 옆으로 넓으면 시안 폭을 화면 가운데에 놓음.
class RankScreen extends StatefulWidget {
  const RankScreen({super.key});

  @override
  State<RankScreen> createState() => _RankScreenState();
}

class _RankScreenState extends State<RankScreen> {
  final rankController = Get.put(RankDataController());

  // [디버그 빌드 전용] 1·2·3위 자리에 지금 로그인한(테스트) 계정의 캐릭터를 대신 넣어 보기
  // 마이룸에서 옷을 바꾸면 바로 반영됨. 릴리스 빌드에서는 버튼이 안 보이고 동작하지 않음.
  final Set<int> _previewMine = {};

  // 지금 로그인한 계정의 캐릭터·옷 (마이룸 상태)을 랭킹 데이터 모양으로
  RankData? _myRankData() {
    if (!Get.isRegistered<MyroomItemController>()) return null;
    final item = Get.find<MyroomItemController>();
    final login = Get.isRegistered<LoginDataController>() ? Get.find<LoginDataController>().loginData.value : null;
    final mine = rankController.rankDataList.firstWhereOrNull((r) => r.id == login?.id);
    final charIndex = characterList.indexWhere((c) => c.assetName == item.characterImage.value.assetName);
    return RankData(
      result: '0000',
      id: login?.id ?? '',
      totalPoints: mine?.totalPoints ?? 0,
      nickName: login?.nickName ?? '내 캐릭터',
      characterImage: '${charIndex < 0 ? 0 : charIndex}',
      hatImage: item.hatImage.value,
      clothesImage: item.clothingImage.value,
      eyeImage: item.accessoriesImage.value,
      backgroundImage: item.backgroundImage.value,
    );
  }

  // ── 시안 단위 배치 (앱바 아래 = 0, 가로는 시안 폭 360 기준) ──
  static const double _titleCenter = 20; // '월간 랭킹' 가운데
  static const double _firstTop = 53; // 1위 카드 위쪽
  static const double _sideTop = 75.5; // 2·3위 카드 위쪽
  static const List<double> _cardCenterX = [180, 74, 286]; // 1·2·3위 카드 가운데
  static const double _panelTop = 163.3; // 흰 판 위쪽 (2·3위 카드 아래쪽이 판에 걸침)

  @override
  void initState() {
    super.initState();
    // 탭에 들어올 때마다 새로 불러옴 (홈 시작 때 받은 랭킹이 있으면 받는 동안 그대로 보여줌)
    rankService();
  }

  // 랭킹 기준 안내 (제목 옆 ? 버튼)
  void _showInfo() {
    showRankDialog(
        '랭킹 시스템 기준 안내',
        '랭킹 시스템은 매월 1일부터 말일까지를\n기준으로 등록되며 매월 1일 초기화됩니다.\n\n'
            '콘텐츠 사용 시 획득하는 코인의 개수에\n따라 순위가 집계되며 상점내 캐릭터\n꾸미기 아이템을 구매하시더라도'
            '\n이미 획득한 랭킹 점수는 별도로 차감되지\n않습니다.');
  }

  Widget _helpButton(double Function(num) d) {
    return Container(
      width: d(20),
      height: d(20),
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: Text('?', style: TextStyle(color: mFontMain, fontSize: d(12), fontWeight: FontWeight.bold, height: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    // 앱바와 같은 배율
    final s = DesignScale.of(mq.size, mq.padding).s;
    double d(num v) => v * s;

    return ColoredBox(
      color: primaryColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 시안 폭(360)을 화면 가운데에 (태블릿처럼 넓으면 양옆이 남음)
          final left = (constraints.maxWidth - d(DesignScale.designWidth)) / 2;

          Widget card(int index) {
            return Positioned(
              left: left + d(_cardCenterX[index] - RankCard.width / 2),
              top: d(index == 0 ? _firstTop : _sideTop),
              width: d(RankCard.width),
              height: d(RankCard.height),
              child: Obx(() {
                final list = rankController.rankDataList;
                if (kDebugMode && _previewMine.contains(index)) {
                  final mine = _myRankData();
                  if (mine != null) return RankCard(rank: index + 1, place: index + 1, data: mine, s: s);
                }
                // 이 자리에 해당하는 사람이 없으면 (3명 미만·불러오기 전) 그리지 않음
                if (list.length <= index) return const SizedBox.shrink();
                return RankCard(rank: rankController.ranks[index], place: index + 1, data: list[index], s: s);
              }),
            );
          }

          return Stack(
            children: [
              // 제목
              Positioned(
                left: 0,
                right: 0,
                top: d(_titleCenter - 15),
                height: d(30),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 제목이 가운데 오도록 왼쪽에 같은 폭의 빈 자리
                      Visibility(
                        visible: false,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: _helpButton(d),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: d(6)),
                        child: Text(
                          '월간 랭킹',
                          style: TextStyle(color: mFontWhite, fontSize: d(20), fontWeight: FontWeight.bold),
                        ),
                      ),
                      // 랭킹 기준 안내
                      GestureDetector(onTap: _showInfo, child: _helpButton(d)),
                    ],
                  ),
                ),
              ),
              // [디버그 빌드 전용] 1·2·3위 자리에 내 캐릭터 넣기 버튼
              if (kDebugMode)
                Positioned(
                  left: d(8),
                  top: d(6),
                  child: Row(
                    children: [
                      for (var i = 0; i < 3; i++)
                        Padding(
                          padding: EdgeInsets.only(right: d(4)),
                          child: GestureDetector(
                            onTap: () => setState(() {
                              if (!_previewMine.remove(i)) _previewMine.add(i);
                            }),
                            child: Container(
                              width: d(26),
                              height: d(26),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _previewMine.contains(i) ? Colors.orange : Colors.white24,
                                borderRadius: BorderRadius.circular(d(6)),
                                border: Border.all(color: Colors.white70),
                              ),
                              child: Text(
                                '${i + 1}',
                                style: TextStyle(color: mFontWhite, fontSize: d(12), fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              // 흰 판 (머리글 + 4위부터)
              Positioned(
                left: 0,
                right: 0,
                top: d(_panelTop),
                bottom: 0,
                child: RankingList(
                  rankDataController: rankController,
                  s: s,
                  left: left,
                  bottomPadding: mq.padding.bottom,
                ),
              ),
              // 1~3위 (판 위에 겹쳐 그림)
              card(1),
              card(2),
              card(0),
            ],
          );
        },
      ),
    );
  }
}
