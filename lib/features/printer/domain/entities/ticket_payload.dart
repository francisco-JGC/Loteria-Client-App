import 'dart:convert';

import 'package:equatable/equatable.dart';

class TicketLine extends Equatable {
  const TicketLine({
    required this.number,
    required this.amount,
    required this.prize,
    this.subGameName,
  });

  final String number;
  final int amount;
  final int prize;
  final String? subGameName;

  List<dynamic> toQrEntry() => [number, amount];

  @override
  List<Object?> get props => [number, amount, prize, subGameName];
}

class TicketPayload extends Equatable {
  const TicketPayload({
    required this.gameId,
    required this.gameSlug,
    required this.gameName,
    required this.lines,
    required this.folio,
    required this.date,
    this.drawAt,
    this.seller,
    this.client,
    this.footer,
  });

  final String gameId;
  final String gameSlug;
  final String gameName;
  final List<TicketLine> lines;
  final String folio;
  final DateTime date;
  final DateTime? drawAt;
  final String? seller;
  final String? client;
  final String? footer;

  int get total => lines.fold(0, (sum, l) => sum + l.amount);
  int get totalPrize => lines.fold(0, (sum, l) => sum + l.prize);
  int get count => lines.length;

  String toQrData() {
    return jsonEncode({
      'g': gameSlug,
      'f': folio,
      if (client != null) 'c': _ascii(client!),
      'b': lines.map((l) => l.toQrEntry()).toList(),
    });
  }

  static String _ascii(String value) {
    const map = {
      'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u',
      'Á': 'A', 'É': 'E', 'Í': 'I', 'Ó': 'O', 'Ú': 'U',
      'ñ': 'n', 'Ñ': 'N', 'ü': 'u', 'Ü': 'U',
    };
    final buf = StringBuffer();
    for (final ch in value.split('')) {
      buf.write(map[ch] ?? ch);
    }
    return buf.toString();
  }

  @override
  List<Object?> get props => [
        gameId,
        gameSlug,
        gameName,
        lines,
        folio,
        date,
        drawAt,
        seller,
        client,
        footer,
      ];
}
