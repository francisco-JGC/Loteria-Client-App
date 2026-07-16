import 'package:equatable/equatable.dart';

/// One row per (game, drawAt) that had at least one ticket in the requested
/// window. Returned by `GET /tickets/by-draw`.
class TicketsByDrawItem extends Equatable {
  const TicketsByDrawItem({
    required this.gameId,
    required this.drawAt,
    required this.ticketCount,
    required this.voidedCount,
    required this.paidCount,
    required this.billed,
    required this.paidPrize,
    required this.winningNumber,
  });

  final String gameId;
  final DateTime drawAt;
  final int ticketCount;
  final int voidedCount;
  final int paidCount;
  final int billed;
  final int paidPrize;

  /// Winning number if the draw already has a registered result.
  final String? winningNumber;

  @override
  List<Object?> get props => [
        gameId,
        drawAt,
        ticketCount,
        voidedCount,
        paidCount,
        billed,
        paidPrize,
        winningNumber,
      ];
}

class TicketsByDrawQuery extends Equatable {
  const TicketsByDrawQuery({
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
