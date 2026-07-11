import '../../domain/entities/winning_ticket.dart';

class WinningTicketModel extends WinningTicket {
  const WinningTicketModel({
    required super.id,
    required super.folio,
    required super.gameId,
    required super.client,
    required super.drawAt,
    required super.totalPrize,
    required super.lines,
    required super.paidAt,
    required super.paidPrize,
  });

  factory WinningTicketModel.fromJson(Map<String, dynamic> json) {
    final rawTicket = json['ticket'] as Map<String, dynamic>;
    final rawLines = (json['lines'] as List<dynamic>? ?? const [])
        .map((raw) => raw as Map<String, dynamic>)
        .map(WinningTicketLineModel.fromJson)
        .toList();
    return WinningTicketModel(
      id: rawTicket['id'] as String,
      folio: rawTicket['folio'] as String,
      gameId: rawTicket['gameId'] as String,
      client: rawTicket['client'] as String?,
      drawAt: DateTime.parse(rawTicket['drawAt'] as String),
      totalPrize: (json['totalPrize'] as num).toInt(),
      lines: rawLines,
      paidAt: rawTicket['paidAt'] == null
          ? null
          : DateTime.parse(rawTicket['paidAt'] as String),
      paidPrize: (rawTicket['paidPrize'] as num?)?.toInt() ?? 0,
    );
  }
}

class WinningTicketLineModel extends WinningTicketLine {
  const WinningTicketLineModel({
    required super.label,
    required super.amount,
    required super.prize,
    required super.wonPrize,
    required super.isWinner,
    required super.winningNumber,
    required super.subGameName,
  });

  factory WinningTicketLineModel.fromJson(Map<String, dynamic> json) {
    return WinningTicketLineModel(
      label: json['label'] as String,
      amount: (json['amount'] as num).toInt(),
      prize: (json['prize'] as num).toInt(),
      wonPrize: (json['wonPrize'] as num).toInt(),
      isWinner: json['isWinner'] as bool,
      winningNumber: json['winningNumber'] as String?,
      subGameName: json['subGameName'] as String?,
    );
  }
}
