import 'package:flutter/material.dart';
import 'package:hoho_hanja/data/models/rank_data.dart';
import 'package:hoho_hanja/widgets/character_avatar.dart';

/// 랭킹 아바타: 서버 랭킹 데이터를 [CharacterAvatar]로 그림 (마이룸에서 입은 모습 그대로)
class RankCircleAvatar extends StatelessWidget {
  final RankData data;
  final double size;

  const RankCircleAvatar({
    super.key,
    required this.data,
    this.size = 100,
  });

  @override
  Widget build(BuildContext context) {
    return CharacterAvatar(
      // 서버 값이 비었거나 숫자가 아니거나 범위를 넘으면 첫 캐릭터(호랑이)
      characterIndex: int.tryParse(data.characterImage?.trim() ?? '') ?? 0,
      backgroundUrl: data.backgroundImage,
      hatUrl: data.hatImage,
      clothesUrl: data.clothesImage,
      size: size,
    );
  }
}
