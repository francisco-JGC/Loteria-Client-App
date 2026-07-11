import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/failures.dart';
import '../../../sale_points/presentation/state/active_sale_point_controller.dart';
import '../../domain/entities/list_tickets_query.dart';
import '../../domain/entities/ticket_summary.dart';
import '../../domain/repositories/tickets_repository.dart';
import '../../domain/usecases/list_my_tickets.dart';
import '../../domain/usecases/void_my_ticket.dart';

class TicketsHistoryFilters {
  const TicketsHistoryFilters({this.from, this.to});

  final DateTime? from;
  final DateTime? to;
}

class TicketsHistoryFiltersNotifier extends Notifier<TicketsHistoryFilters> {
  @override
  TicketsHistoryFilters build() {
    final now = DateTime.now();
    return TicketsHistoryFilters(
      from: DateTime(now.year, now.month, now.day),
      to: DateTime(now.year, now.month, now.day, 23, 59, 59),
    );
  }

  void set({DateTime? from, DateTime? to}) {
    state = TicketsHistoryFilters(from: from, to: to);
  }

  void clear() => state = const TicketsHistoryFilters();
}

final ticketsHistoryFiltersProvider =
    NotifierProvider<TicketsHistoryFiltersNotifier, TicketsHistoryFilters>(
  TicketsHistoryFiltersNotifier.new,
);

class TicketsHistoryController extends AsyncNotifier<List<TicketSummary>> {
  late final _list = getIt<ListMyTickets>();
  late final _void = getIt<VoidMyTicket>();
  late final _repository = getIt<TicketsRepository>();

  @override
  Future<List<TicketSummary>> build() async {
    ref.listen(ticketsHistoryFiltersProvider, (previous, next) {
      if (previous != next) refresh();
    });
    return _fetch();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
  }

  Future<Either<Failure, TicketSummary>> voidTicket({
    required String id,
    required String reason,
  }) async {
    final result = await _void(VoidMyTicketParams(id: id, reason: reason));
    result.match(
      (_) {},
      _replace,
    );
    return result;
  }

  Future<Either<Failure, TicketSummary>> payTicket(String id) async {
    final result = await _repository.payTicket(id);
    result.match(
      (_) {},
      _replace,
    );
    return result;
  }

  void _replace(TicketSummary updated) {
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data(current
        .map<TicketSummary>((t) => t.id == updated.id ? updated : t)
        .toList());
  }

  Future<List<TicketSummary>> _fetch() async {
    final salePoint = ref.read(activeSalePointProvider).selected;
    if (salePoint == null) return const [];
    final filters = ref.read(ticketsHistoryFiltersProvider);

    final result = await _list(ListTicketsQuery(
      salePointId: salePoint.id,
      from: filters.from,
      to: filters.to,
      limit: 200,
    ));
    return result.fold(
      (failure) => throw Exception(failure.message),
      (r) => r.items,
    );
  }
}

final ticketsHistoryControllerProvider = AsyncNotifierProvider<
    TicketsHistoryController, List<TicketSummary>>(
  TicketsHistoryController.new,
);
