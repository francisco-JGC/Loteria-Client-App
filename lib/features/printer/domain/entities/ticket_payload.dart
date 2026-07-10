import 'package:equatable/equatable.dart';

class TicketPayload extends Equatable {
  const TicketPayload({
    required this.gameName,
    required this.numbers,
    required this.amount,
    required this.folio,
    required this.date,
    this.seller,
    this.footer,
  });

  final String gameName;
  final List<String> numbers;
  final double amount;
  final String folio;
  final DateTime date;
  final String? seller;
  final String? footer;

  @override
  List<Object?> get props => [
        gameName,
        numbers,
        amount,
        folio,
        date,
        seller,
        footer,
      ];
}
