import 'package:equatable/equatable.dart';

class WinningTicketLine extends Equatable {
  const WinningTicketLine({
    required this.label,
    required this.amount,
    required this.prize,
    required this.wonPrize,
    required this.isWinner,
    required this.winningNumber,
    required this.subGameName,
  });

  final String label;
  final int amount;
  final int prize;
  final int wonPrize;
  final bool isWinner;
  final String? winningNumber;
  final String? subGameName;

  @override
  List<Object?> get props =>
      [label, amount, prize, wonPrize, isWinner, winningNumber, subGameName];
}

class WinningTicket extends Equatable {
  const WinningTicket({
    required this.id,
    required this.folio,
    required this.gameId,
    required this.client,
    required this.drawAt,
    required this.totalPrize,
    required this.lines,
    required this.paidAt,
    required this.paidPrize,
  });

  final String id;
  final String folio;
  final String gameId;
  final String? client;
  final DateTime drawAt;
  final int totalPrize;
  final List<WinningTicketLine> lines;
  final DateTime? paidAt;
  final int paidPrize;

  bool get isPaid => paidAt != null;

  WinningTicket copyWith({DateTime? paidAt, int? paidPrize}) => WinningTicket(
        id: id,
        folio: folio,
        gameId: gameId,
        client: client,
        drawAt: drawAt,
        totalPrize: totalPrize,
        lines: lines,
        paidAt: paidAt ?? this.paidAt,
        paidPrize: paidPrize ?? this.paidPrize,
      );

  @override
  List<Object?> get props => [
        id,
        folio,
        gameId,
        client,
        drawAt,
        totalPrize,
        lines,
        paidAt,
        paidPrize,
      ];
}
