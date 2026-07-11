import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../sale_points/presentation/state/active_sale_point_controller.dart';
import '../../domain/entities/winning_ticket.dart';
import '../../domain/repositories/results_repository.dart';

class WinnersController extends AsyncNotifier<List<WinningTicket>> {
  late final _repository = getIt<ResultsRepository>();

  @override
  Future<List<WinningTicket>> build() async {
    return _fetch();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<List<WinningTicket>> _fetch() async {
    final salePoint = ref.watch(activeSalePointProvider).selected;
    if (salePoint == null) return const [];

    final now = DateTime.now();
    final since = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 3));
    final result = await _repository.listWinners(
      ListWinnersQuery(salePointId: salePoint.id, from: since),
    );
    return result.fold(
      (failure) => throw Exception(failure.message),
      (items) => items,
    );
  }
}

final winnersControllerProvider =
    AsyncNotifierProvider<WinnersController, List<WinningTicket>>(
  WinnersController.new,
);
