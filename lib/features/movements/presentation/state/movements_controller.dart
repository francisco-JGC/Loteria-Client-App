import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection.dart';
import '../../../sale_points/presentation/state/active_sale_point_controller.dart';
import '../../../tickets/domain/entities/list_tickets_query.dart';
import '../../../tickets/domain/repositories/tickets_repository.dart';
import '../../domain/entities/movements_summary.dart';

class MovementsFilters extends Equatable {
  const MovementsFilters({required this.from, required this.to});

  final DateTime from;
  final DateTime to;

  @override
  List<Object?> get props => [from, to];
}

class MovementsFiltersNotifier extends Notifier<MovementsFilters> {
  @override
  MovementsFilters build() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return MovementsFilters(from: today, to: endOfDay);
  }

  void setRange(DateTime from, DateTime to) {
    state = MovementsFilters(from: from, to: to);
  }
}

final movementsFiltersProvider = NotifierProvider<
    MovementsFiltersNotifier, MovementsFilters>(
  MovementsFiltersNotifier.new,
);

class MovementsController extends AsyncNotifier<MovementsSummary> {
  late final _tickets = getIt<TicketsRepository>();

  @override
  Future<MovementsSummary> build() async {
    ref.listen(movementsFiltersProvider, (previous, next) {
      if (previous != next) refresh();
    });
    return _fetch();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<MovementsSummary> _fetch() async {
    final salePoint = ref.read(activeSalePointProvider).selected;
    if (salePoint == null) return MovementsSummary.empty;
    final filters = ref.read(movementsFiltersProvider);

    final result = await _tickets.list(ListTicketsQuery(
      salePointId: salePoint.id,
      from: filters.from,
      to: filters.to,
      limit: 500,
    ));
    return result.fold(
      (failure) => throw Exception(failure.message),
      (list) {
        var billed = 0;
        var paidPrize = 0;
        for (final t in list.items) {
          if (!t.isVoided) billed += t.total;
          if (t.isPaid) paidPrize += t.paidPrize;
        }
        // For now: collected == billed (no separate credit tracking yet).
        // Expenses and salary will come from future modules; leave as 0.
        return MovementsSummary(
          billed: billed,
          collected: billed,
          paidPrize: paidPrize,
          expenses: 0,
          salary: 0,
        );
      },
    );
  }
}

final movementsControllerProvider = AsyncNotifierProvider<
    MovementsController, MovementsSummary>(MovementsController.new);
