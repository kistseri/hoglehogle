import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hoho_hanja/_core/colors.dart';
import 'package:marquee/marquee.dart';

class RankCard extends StatelessWidget {
  final String rank;
  final double top;
  final double? leftPosition;
  final double? rightPosition;
  final Color backgroundColor;
  final Color badgeColor;
  final String nickName;
  final int totalPoints;
  final String rankBox;
  final Future<ImageProvider> rankerImage;

  const RankCard({
    super.key,
    required this.rank,
    required this.top,
    this.leftPosition,
    this.rightPosition,
    required this.backgroundColor,
    required this.badgeColor,
    required this.nickName,
    required this.totalPoints,
    required this.rankBox,
    required this.rankerImage,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      left: leftPosition,
      right: rightPosition,
      child: Stack(
        children: [
          Container(
            width: 90.w,
            height: 120.h,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/icon/$rankBox.png'),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                children: [
                  Center(
                    child: SizedBox(
                        width: 50.w,
                        child: FutureBuilder<ImageProvider>(
                          future: rankerImage,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            } else {
                              return CircleAvatar(
                                radius: 25.r,
                                backgroundImage: snapshot.data,
                              );
                            }
                          },
                        )),
                  ),
                  SizedBox(
                    height: 30,
                    width: 200,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Marquee(
                        text: nickName,
                        style: TextStyle(color: mFontWhite),
                        scrollAxis: Axis.horizontal,
                        velocity: 10.0,
blankSpace: 30.0,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 1.h, horizontal: 10.w),
                      child: Text(
                        '$totalPoints점',
                        style: TextStyle(color: mFontMain, fontSize: 10.sp),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 2.h,
            right: MediaQuery.of(context).size.width * 1 / 7,
            child: Visibility(
              visible: rankBox == 'first',
              child: Container(
                width: 30.w,
                height: 30.h,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/icon/crown.png'),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: MediaQuery.of(context).size.width >= 500 ? 10 : 0,
            child: Container(
              width: 30.w,
              height: 30.h,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    'assets/images/icon/rank_badge.png',
                  ),
                ),
              ),
              child: Center(
                  child: Text(
                '$rank',
                style: TextStyle(fontSize: 10.sp, fontFamily: 'BMJUA'),
              )),
            ),
          ),
        ],
      ),
    );
  }
}

class PentagonBadge extends StatelessWidget {
  final int number;

  const PentagonBadge({super.key, required this.number});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: Size(60, 60),
          painter: PentagonPainter(),
        ),
        // 가운데 노란색 원형 영역
        Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: Colors.yellow,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class PentagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green // 배경 색상
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.5, 0); // 위쪽 꼭짓점
    path.lineTo(size.width, size.height * 0.35); // 오른쪽 위 모서리
    path.lineTo(size.width * 0.8, size.height); // 오른쪽 아래 모서리
    path.lineTo(size.width * 0.2, size.height); // 왼쪽 아래 모서리
    path.lineTo(0, size.height * 0.35); // 왼쪽 위 모서리
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
