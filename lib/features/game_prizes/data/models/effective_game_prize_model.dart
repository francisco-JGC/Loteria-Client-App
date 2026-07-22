import '../../domain/entities/effective_game_prize.dart';

class EffectiveGamePrizeModel extends EffectiveGamePrize {
  const EffectiveGamePrizeModel({
    required super.gameId,
    required super.gameName,
    required super.exactDefault,
    required super.easyDefault,
    required super.exactMultiplier,
    required super.easyMultiplier,
    required super.hasOverride,
  });

  factory EffectiveGamePrizeModel.fromJson(Map<String, dynamic> json) {
    int? asInt(dynamic v) => v is num ? v.toInt() : null;
    return EffectiveGamePrizeModel(
      gameId: json['gameId'] as String,
      gameName: json['gameName'] as String,
      exactDefault: asInt(json['exactDefault']),
      easyDefault: asInt(json['easyDefault']),
      exactMultiplier: asInt(json['exactMultiplier']),
      easyMultiplier: asInt(json['easyMultiplier']),
      hasOverride: json['hasOverride'] as bool? ?? false,
    );
  }
}
