import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hoho_hanja/screens/myroom/myroom_wigets/my_room_item.dart';
import 'package:hoho_hanja/widgets/character_avatar.dart';

/// 앱바 프로필: 지금 입은 모습 그대로 (마이룸·랭킹과 같은 배치)
class MyRoomCircleAvatar extends StatelessWidget {
  final double size;

  const MyRoomCircleAvatar({super.key, this.size = 100});

  @override
  Widget build(BuildContext context) {
    final c = MyroomItemController.to;
    return Obx(() => CharacterAvatar(
          characterIndex: c.characterIndex.value,
          backgroundUrl: c.backgroundImage.value,
          hatUrl: c.hatImage.value,
          clothesUrl: c.clothingImage.value,
          size: size,
        ));
  }
}
