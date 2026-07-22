import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/effective_game_prize.dart';
import '../../domain/repositories/game_prizes_repository.dart';

/// Effective multipliers for every game at the given sucursal. Sellers
/// consult this at ticket-create time so the `prize` sent to the server
/// reflects the override — if the operator configured Diaria at 75x for
/// Puesto Principal, tickets sold there use 75x, not the game default 80x.
final effectiveGamePrizesProvider = FutureProvider.autoDispose
    .family<List<EffectiveGamePrize>, String>((ref, salePointId) async {
  final repo = getIt<GamePrizesRepository>();
  final result = await repo.listBySalePoint(salePointId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (data) => data,
  );
});
