import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/failures.dart';
import '../../../sale_points/presentation/state/active_sale_point_controller.dart';
import '../../../tickets/domain/repositories/tickets_repository.dart';
import '../../domain/entities/winning_ticket.dart';
import '../../domain/repositories/results_repository.dart';

class WinnersFilters {
  const WinnersFilters({this.from, this.to});

  final DateTime? from;
  final DateTime? to;
}

class WinnersFiltersNotifier extends Notifier<WinnersFilters> {
  @override
  WinnersFilters build() {
    final now = DateTime.now();
    return WinnersFilters(
      from: DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 3)),
      to: DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
  }

  void set({DateTime? from, DateTime? to}) {
    state = WinnersFilters(from: from, to: to);
  }
}

final winnersFiltersProvider =
    NotifierProvider<WinnersFiltersNotifier, WinnersFilters>(
  WinnersFiltersNotifier.new,
);

class WinnersController extends AsyncNotifier<List<WinningTicket>> {
  late final _repository = getIt<ResultsRepository>();
  late final _tickets = getIt<TicketsRepository>();

  @override
  Future<List<WinningTicket>> build() async {
    ref.listen(winnersFiltersProvider, (previous, next) {
      if (previous != next) refresh();
    });
    return _fetch();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<Either<Failure, Unit>> pay(String ticketId) async {
    final result = await _tickets.payTicket(ticketId);
    return result.fold<Either<Failure, Unit>>(
      Left.new,
      (updated) {
        final current = state.value;
        if (current != null) {
          state = AsyncValue.data(
            current.map<WinningTicket>((w) {
              if (w.id != ticketId) return w;
              return w.copyWith(
                paidAt: updated.paidAt,
                paidPrize: updated.paidPrize,
              );
            }).toList(),
          );
        }
        return const Right(unit);
      },
    );
  }

  Future<List<WinningTicket>> _fetch() async {
    final salePoint = ref.read(activeSalePointProvider).selected;
    if (salePoint == null) return const [];
    final filters = ref.read(winnersFiltersProvider);

    final result = await _repository.listWinners(
      ListWinnersQuery(
        salePointId: salePoint.id,
        from: filters.from,
        to: filters.to,
      ),
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
