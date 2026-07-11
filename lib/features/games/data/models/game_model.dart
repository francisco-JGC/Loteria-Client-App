import '../../domain/entities/game.dart';
import '../../domain/entities/game_type.dart';

class GameModel extends Game {
  const GameModel({
    required super.id,
    required super.slug,
    required super.name,
    required super.type,
    super.mainMultiplier,
    super.secondaryMultiplier,
    super.imagePath,
    super.orderIndex,
    super.isActive,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      type: GameType.fromKey(json['type'] as String),
      mainMultiplier: (json['mainMultiplier'] as num?)?.toInt(),
      secondaryMultiplier: (json['secondaryMultiplier'] as num?)?.toInt(),
      imagePath: json['imagePath'] as String?,
      orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'slug': slug,
        'name': name,
        'type': type.apiKey,
        'mainMultiplier': mainMultiplier,
        'secondaryMultiplier': secondaryMultiplier,
        'imagePath': imagePath,
        'orderIndex': orderIndex,
        'isActive': isActive,
      };
}
