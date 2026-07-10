import '../../domain/entities/game.dart';

class GameModel extends Game {
  const GameModel({
    required super.id,
    required super.name,
    super.imagePath,
    super.isEnabled,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'] as String,
      name: json['name'] as String,
      imagePath: json['imagePath'] as String?,
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imagePath': imagePath,
        'isEnabled': isEnabled,
      };
}
