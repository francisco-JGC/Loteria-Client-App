import 'package:equatable/equatable.dart';

/// Effective payout multipliers for one game at one sucursal. `main` and
/// `secondary` are ALREADY MERGED — override wins, otherwise the game's
/// default is used. `hasOverride` is a display hint (the mobile shows a
/// banner so the seller knows their sucursal has custom multipliers).
class EffectiveGamePrize extends Equatable {
  const EffectiveGamePrize({
    required this.gameId,
    required this.gameName,
    required this.mainDefault,
    required this.secondaryDefault,
    required this.mainMultiplier,
    required this.secondaryMultiplier,
    required this.hasOverride,
  });

  final String gameId;
  final String gameName;
  final int? mainDefault;
  final int? secondaryDefault;
  final int? mainMultiplier;
  final int? secondaryMultiplier;
  final bool hasOverride;

  @override
  List<Object?> get props => [
        gameId,
        gameName,
        mainDefault,
        secondaryDefault,
        mainMultiplier,
        secondaryMultiplier,
        hasOverride,
      ];
}
