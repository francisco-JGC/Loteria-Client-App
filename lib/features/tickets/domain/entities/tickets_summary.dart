import 'package:equatable/equatable.dart';

/// Aggregate totals for a set of tickets, returned by `GET /tickets/summary`.
/// Amounts are in the same integer unit the API uses everywhere else.
class TicketsSummary extends Equatable {
  const TicketsSummary({
    required this.ticketCount,
    required this.voidedCount,
    required this.paidCount,
    required this.billed,
    required this.paidPrize,
  });

  static const empty = TicketsSummary(
    ticketCount: 0,
    voidedCount: 0,
    paidCount: 0,
    billed: 0,
    paidPrize: 0,
  );

  final int ticketCount;
  final int voidedCount;
  final int paidCount;
  final int billed;
  final int paidPrize;

  @override
  List<Object?> get props =>
      [ticketCount, voidedCount, paidCount, billed, paidPrize];
}

/// Query params for `GET /tickets/summary`. Sellers cannot spy on other
/// sellers: the server forces `sellerId = requesterId` when the caller has
/// role=seller regardless of what's sent here.
class TicketsSummaryQuery extends Equatable {
  const TicketsSummaryQuery({
    this.salePointId,
    this.gameId,
    this.sellerId,
    this.from,
    this.to,
  });

  final String? salePointId;
  final String? gameId;
  final String? sellerId;
  final DateTime? from;
  final DateTime? to;

  Map<String, dynamic> toQueryParameters() => {
        if (salePointId != null) 'salePointId': salePointId,
        if (gameId != null) 'gameId': gameId,
        if (sellerId != null) 'sellerId': sellerId,
        if (from != null) 'from': from!.toUtc().toIso8601String(),
        if (to != null) 'to': to!.toUtc().toIso8601String(),
      };

  @override
  List<Object?> get props => [salePointId, gameId, sellerId, from, to];
}
