import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:hoho_hanja/data/models/rank_data.dart';
import 'package:hoho_hanja/screens/rank/rank_widgets/load_circle_image.dart';
import 'package:hoho_hanja/screens/rank/rank_widgets/rank_card.dart';
import 'package:hoho_hanja/screens/rank/rank_widgets/ranking_list.dart';
import 'package:hoho_hanja/services/rank/rank_service.dart';

class RankScreen extends StatefulWidget {
  const RankScreen({super.key});

  @override
  State<RankScreen> createState() => _RankScreenState();
}

class _RankScreenState extends State<RankScreen> {
  final rankController = Get.put(RankDataController());

  @override
  void initState() {
    super.initState();
    rankService();
  }

  Future<ImageProvider> createImage(int index) async {
    final rankData = rankController.rankDataList![index];
    return await getCombinedImageProvider([
      rankData.characterImage,
      rankData.hatImage ?? '',
      rankData.clothesImage ?? '',
      rankData.eyeImage ?? '',
      rankData.backgroundImage ?? '',
    ].whereType<String>().toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: primaryColor,
        title: Text(
          '월간 랭킹',
          style: TextStyle(
              color: mFontWhite, fontSize: 20.sp, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          RankingList(
            rankDataController: rankController,
          ),
          RankCard(
            rank: '1',
            top: 0,
            leftPosition: MediaQuery.of(context).size.width / 2 - 45.w,
            backgroundColor: Color(0xFFF7D214),
            badgeColor: Color(0xFFFCF0B6),
            nickName: rankController.rankDataList![0].nickName,
            totalPoints: rankController.rankDataList![0].totalPoints,
            rankBox: 'first',
            rankerImage: createImage(0),
          ),
          RankCard(
            rank: '2',
            top: 25.h,
            rightPosition: MediaQuery.of(context).size.width * 3 / 4 - 30.w,
            backgroundColor: Color(0xFF4CD5D6),
            badgeColor: Color(0xFFC1F0F1),
            nickName: rankController.rankDataList![1].nickName,
            totalPoints: rankController.rankDataList![1].totalPoints,
            rankBox: 'second',
            rankerImage: createImage(1),
          ),
          RankCard(
            rank: '3',
            top: 25.h,
            leftPosition: MediaQuery.of(context).size.width * 3 / 4 - 30.w,
            backgroundColor: Color(0xFFD1AD5E),
            badgeColor: Color(0xFFF0E4C9),
            nickName: rankController.rankDataList![2].nickName,
            totalPoints: rankController.rankDataList![2].totalPoints,
            rankBox: 'third',
            rankerImage: createImage(2),
          ),
        ],
      ),
    );
  }
}
