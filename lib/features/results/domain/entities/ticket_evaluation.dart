import 'package:equatable/equatable.dart';

import 'winning_ticket.dart';

class TicketEvaluation extends Equatable {
  const TicketEvaluation({
    required this.ticketId,
    required this.folio,
    required this.gameId,
    required this.drawAt,
    required this.status,
    required this.isWinner,
    required this.hasPendingDraw,
    required this.totalPrize,
    required this.paidAt,
    required this.paidPrize,
    required this.lines,
  });

  final String ticketId;
  final String folio;
  final String gameId;
  final DateTime drawAt;
  final String status;
  final bool isWinner;
  final bool hasPendingDraw;
  final int totalPrize;

  /// When the prize was collected. Null while it's still pending.
  final DateTime? paidAt;
  final int paidPrize;
  final List<WinningTicketLine> lines;

  bool get isPaid => paidAt != null;
  bool get isVoided => status == 'voided';

  /// True when the seller should still hand out the prize on this ticket.
  bool get canPay => isWinner && !isPaid && !isVoided;

  @override
  List<Object?> get props => [
        ticketId,
        folio,
        gameId,
        drawAt,
        status,
        isWinner,
        hasPendingDraw,
        totalPrize,
        paidAt,
        paidPrize,
        lines,
      ];
}
