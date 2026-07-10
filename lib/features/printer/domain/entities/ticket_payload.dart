import 'package:equatable/equatable.dart';

class TicketLine extends Equatable {
  const TicketLine({required this.number, required this.amount});

  final String number;
  final int amount;

  @override
  List<Object?> get props => [number, amount];
}

class TicketPayload extends Equatable {
  const TicketPayload({
    required this.gameName,
    required this.lines,
    required this.folio,
    required this.date,
    this.seller,
    this.footer,
  });

  final String gameName;
  final List<TicketLine> lines;
  final String folio;
  final DateTime date;
  final String? seller;
  final String? footer;

  int get total => lines.fold(0, (sum, l) => sum + l.amount);
  int get count => lines.length;

  @override
  List<Object?> get props => [gameName, lines, folio, date, seller, footer];
}
