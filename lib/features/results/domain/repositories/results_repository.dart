import 'package:fpdart/fpdart.dart';

import '../../../../core/errors/failures.dart';
import '../entities/draw_result.dart';
import '../entities/ticket_evaluation.dart';
import '../entities/winning_ticket.dart';

class ListDrawResultsQuery {
  const ListDrawResultsQuery({
    this.gameId,
    this.from,
    this.to,
    this.limit,
  });

  final String? gameId;
  final DateTime? from;
  final DateTime? to;
  final int? limit;

  Map<String, dynamic> toQueryParameters() => {
        if (gameId != null) 'gameId': gameId,
        if (from != null) 'from': from!.toUtc().toIso8601String(),
        if (to != null) 'to': to!.toUtc().toIso8601String(),
        if (limit != null) 'limit': limit,
      };
}

class ListWinnersQuery {
  const ListWinnersQuery({
    this.salePointId,
    this.gameId,
    this.from,
    this.to,
  });

  final String? salePointId;
  final String? gameId;
  final DateTime? from;
  final DateTime? to;

  Map<String, dynamic> toQueryParameters() => {
        if (salePointId != null) 'salePointId': salePointId,
        if (gameId != null) 'gameId': gameId,
        if (from != null) 'from': from!.toUtc().toIso8601String(),
        if (to != null) 'to': to!.toUtc().toIso8601String(),
      };
}

abstract interface class ResultsRepository {
  Future<Either<Failure, List<DrawResult>>> listResults(
    ListDrawResultsQuery query,
  );
  Future<Either<Failure, List<WinningTicket>>> listWinners(
    ListWinnersQuery query,
  );
  Future<Either<Failure, TicketEvaluation>> evaluateTicket(String ticketId);
}
