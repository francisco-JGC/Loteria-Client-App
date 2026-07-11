import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/errors/failures.dart';
import '../../../sale_points/presentation/state/active_sale_point_controller.dart';
import '../../domain/entities/list_tickets_query.dart';
import '../../domain/entities/ticket_summary.dart';
import '../../domain/usecases/list_my_tickets.dart';
import '../../domain/usecases/void_my_ticket.dart';

class TicketsHistoryController extends AsyncNotifier<List<TicketSummary>> {
  late final _list = getIt<ListMyTickets>();
  late final _void = getIt<VoidMyTicket>();

  @override
  Future<List<TicketSummary>> build() async {
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
    final result =
        await _void(VoidMyTicketParams(id: id, reason: reason));
    result.match(
      (_) {},
      (updated) {
        final current = state.value;
        if (current == null) return;
        final next = current
            .map<TicketSummary>((t) => t.id == updated.id ? updated : t)
            .toList();
        state = AsyncValue.data(next);
      },
    );
    return result;
  }

  Future<List<TicketSummary>> _fetch() async {
    final salePoint = ref.watch(activeSalePointProvider).selected;
    if (salePoint == null) return const [];

    final result = await _list(ListTicketsQuery(
      salePointId: salePoint.id,
      limit: 50,
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
