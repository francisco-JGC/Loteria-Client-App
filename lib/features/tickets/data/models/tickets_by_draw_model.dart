import '../../domain/entities/tickets_by_draw.dart';

class TicketsByDrawItemModel extends TicketsByDrawItem {
  const TicketsByDrawItemModel({
    required super.gameId,
    required super.drawAt,
    required super.ticketCount,
    required super.voidedCount,
    required super.paidCount,
    required super.billed,
    required super.paidPrize,
    required super.winningNumber,
  });

  factory TicketsByDrawItemModel.fromJson(Map<String, dynamic> json) {
    return TicketsByDrawItemModel(
      gameId: json['gameId'] as String,
      drawAt: DateTime.parse(json['drawAt'] as String),
      ticketCount: (json['ticketCount'] as num).toInt(),
      voidedCount: (json['voidedCount'] as num).toInt(),
      paidCount: (json['paidCount'] as num).toInt(),
      billed: (json['billed'] as num).toInt(),
      paidPrize: (json['paidPrize'] as num).toInt(),
      winningNumber: json['winningNumber'] as String?,
    );
  }
}
