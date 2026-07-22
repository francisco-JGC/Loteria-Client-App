import 'package:equatable/equatable.dart';

import 'game_type.dart';

class Game extends Equatable {
  const Game({
    required this.id,
    required this.slug,
    required this.name,
    required this.type,
    this.exactMultiplier,
    this.easyMultiplier,
    this.imagePath,
    this.orderIndex = 0,
    this.isActive = true,
  });

  final String id;
  final String slug;
  final String name;
  final GameType type;
  final int? exactMultiplier;
  final int? easyMultiplier;
  final String? imagePath;
  final int orderIndex;
  final bool isActive;

  @override
  List<Object?> get props => [
        id,
        slug,
        name,
        type,
        exactMultiplier,
        easyMultiplier,
        imagePath,
        orderIndex,
        isActive,
      ];
}
