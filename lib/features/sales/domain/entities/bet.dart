import 'package:equatable/equatable.dart';

class Bet extends Equatable {
  const Bet({required this.number, required this.amount});

  final int number;
  final int amount;

  String get numberLabel => number.toString().padLeft(2, '0');

  @override
  List<Object?> get props => [number, amount];
}
