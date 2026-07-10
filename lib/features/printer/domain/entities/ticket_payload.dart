import 'dart:convert';

import 'package:equatable/equatable.dart';

class TicketLine extends Equatable {
  const TicketLine({
    required this.number,
    required this.amount,
    required this.prize,
  });

  final String number;
  final int amount;
  final int prize;

  Map<String, dynamic> toQrMap() => {'n': number, 'a': amount};

  @override
  List<Object?> get props => [number, amount, prize];
}

class TicketPayload extends Equatable {
  const TicketPayload({
    required this.gameId,
    required this.gameName,
    required this.lines,
    required this.folio,
    required this.date,
    this.seller,
    this.footer,
  });

  final String gameId;
  final String gameName;
  final List<TicketLine> lines;
  final String folio;
  final DateTime date;
  final String? seller;
  final String? footer;

  int get total => lines.fold(0, (sum, l) => sum + l.amount);
  int get totalPrize => lines.fold(0, (sum, l) => sum + l.prize);
  int get count => lines.length;

  String toQrData() {
    return jsonEncode({
      'g': gameId,
      'f': folio,
      'd': date.toIso8601String(),
      if (seller != null) 's': seller,
      'b': lines.map((l) => l.toQrMap()).toList(),
    });
  }

  @override
  List<Object?> get props => [
        gameId,
        gameName,
        lines,
        folio,
        date,
        seller,
        footer,
      ];
}
