import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/data/models/rank_data.dart';
import 'package:hoho_hanja/services/rank/rank_service.dart';
import 'package:hoho_hanja/utils/formatter.dart';
import 'package:hoho_hanja/widgets/dashed_divider.dart';

/// 흰 판: 머리글 + 4위부터 목록 (닉네임만). 불러오는 중·실패·빈 랭킹 안내도 여기서 보여줌
///
/// 좌표는 시안 단위, 판 위쪽 = 0. [left]는 시안 360 폭의 왼쪽 끝 (태블릿에서 가운데 정렬용, 화면 px)
class RankingList extends StatelessWidget {
  final RankDataController rankDataController;
  final double s; // 시안 → 화면 배율
  final double left; // 시안 영역 왼쪽 끝 (화면 px)
  final double bottomPadding; // 아래 여백 (홈 바, 화면 px)

  const RankingList({
    super.key,
    required this.rankDataController,
    required this.s,
    required this.left,
    required this.bottomPadding,
  });

  // ── 시안 단위 ──
  static const double radius = 40;
  static const double headerCenter = 86.5; // 판 위쪽에서 머리글 가운데까지
  static const double listTop = 102; // 판 위쪽에서 4위 줄 위쪽까지
  static const double rowHeight = 62.6;
  static const double rankCenterX = 32.5; // 순위 가운데
  static const double nickLeft = 63; // 닉네임 왼쪽
  static const double pointsRight = 333; // 점수 오른쪽 끝
  static const double dividerLeft = 24;
  static const double dividerRight = 336;

  double d(num v) => v * s;

  @override
  Widget build(BuildContext context) {
    final head = TextStyle(color: mFontLightGray, fontSize: d(12), fontWeight: FontWeight.w500);

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(d(radius))),
      child: ColoredBox(
        color: mBackWhite,
        child: Obx(() {
          final status = rankDataController.status.value;
          final list = rankDataController.rankDataList;
          final ranks = rankDataController.ranks;

          return Stack(
            children: [
              // 머리글
              _cells(
                top: d(headerCenter) - d(10),
                height: d(20),
                rank: Text('순위', style: head),
                nick: Text('닉네임', style: head),
                points: Text('점수', style: head),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: d(listTop),
                bottom: 0,
                child: list.isEmpty
                    ? Padding(
                        padding: EdgeInsets.only(bottom: bottomPadding + d(listTop)),
                        child: Center(child: _emptyState(status)),
                      )
                    // 아래로 당기면 새로 불러옴
                    : RefreshIndicator(
                        color: primaryColor,
                        onRefresh: rankService,
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(bottom: bottomPadding + d(8)),
                          itemExtent: d(rowHeight),
                          itemCount: list.length > 3 ? list.length - 3 : 0,
                          itemBuilder: (context, index) => _row(list[index + 3], ranks[index + 3]),
                        ),
                      ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _row(RankData data, int rank) {
    return Stack(
      children: [
        _cells(
          top: 0,
          height: d(rowHeight),
          rank: Text('$rank', style: TextStyle(color: mFontLightGray, fontSize: d(15), fontWeight: FontWeight.w500)),
          nick: Text(
            data.nickName,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: mFontMain, fontSize: d(13)),
          ),
          points: Text(
            formatNumber(data.totalPoints),
            style: TextStyle(color: mFontMain, fontSize: d(13), fontWeight: FontWeight.bold),
          ),
        ),
        // 줄 사이 점선
        Positioned(
          left: left + d(dividerLeft),
          width: d(dividerRight - dividerLeft),
          bottom: 0,
          child: const DashedHorizontalDivider(color: Color(0xFFDADADA)),
        ),
      ],
    );
  }

  // 순위 | 닉네임 | 점수 칸 (머리글과 줄이 같은 위치)
  Widget _cells(
      {required double top,
      required double height,
      required Widget rank,
      required Widget nick,
      required Widget points}) {
    return Positioned(
      left: 0,
      right: 0,
      top: top,
      height: height,
      child: Stack(
        children: [
          Positioned(
            left: left + d(rankCenterX - 20),
            width: d(40),
            top: 0,
            bottom: 0,
            child: Center(child: rank),
          ),
          Positioned(
            left: left + d(nickLeft),
            width: d(200),
            top: 0,
            bottom: 0,
            child: Align(alignment: Alignment.centerLeft, child: nick),
          ),
          Positioned(
            left: left + d(nickLeft + 200),
            width: d(pointsRight - nickLeft - 200),
            top: 0,
            bottom: 0,
            child: Align(
              alignment: Alignment.centerRight,
              child: FittedBox(fit: BoxFit.scaleDown, child: points),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(RankStatus status) {
    switch (status) {
      case RankStatus.loading:
        return const CircularProgressIndicator(color: primaryColor);
      case RankStatus.error:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              rankDataController.errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: mFontSub, fontSize: d(14)),
            ),
            Padding(
              padding: EdgeInsets.only(top: d(16)),
              child: ElevatedButton(
                onPressed: rankService,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: mFontWhite,
                  shape: const StadiumBorder(),
                  padding: EdgeInsets.symmetric(horizontal: d(24), vertical: d(10)),
                ),
                child: Text('다시 시도', style: TextStyle(fontSize: d(14))),
              ),
            ),
          ],
        );
      case RankStatus.done:
        return Text(
          '이번 달 랭킹이 아직 없어요.\n콘텐츠를 풀고 코인을 모아 1등에 도전해 보세요!',
          textAlign: TextAlign.center,
          style: TextStyle(color: mFontSub, fontSize: d(14), height: 1.5),
        );
    }
  }
}
