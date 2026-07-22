import '../../domain/entities/effective_game_prize.dart';

class EffectiveGamePrizeModel extends EffectiveGamePrize {
  const EffectiveGamePrizeModel({
    required super.gameId,
    required super.gameName,
    required super.mainDefault,
    required super.secondaryDefault,
    required super.mainMultiplier,
    required super.secondaryMultiplier,
    required super.hasOverride,
  });

  factory EffectiveGamePrizeModel.fromJson(Map<String, dynamic> json) {
    int? asInt(dynamic v) => v is num ? v.toInt() : null;
    return EffectiveGamePrizeModel(
      gameId: json['gameId'] as String,
      gameName: json['gameName'] as String,
      mainDefault: asInt(json['mainDefault']),
      secondaryDefault: asInt(json['secondaryDefault']),
      mainMultiplier: asInt(json['mainMultiplier']),
      secondaryMultiplier: asInt(json['secondaryMultiplier']),
      hasOverride: json['hasOverride'] as bool? ?? false,
    );
  }
}
