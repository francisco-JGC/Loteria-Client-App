import 'package:equatable/equatable.dart';

class MultiSorteoBet extends Equatable {
  const MultiSorteoBet({
    required this.subGameId,
    required this.subGameName,
    required this.label,
    required this.amount,
    required this.prize,
  });

  final String subGameId;
  final String subGameName;
  final String label;
  final int amount;
  final int prize;

  @override
  List<Object?> get props => [subGameId, subGameName, label, amount, prize];
}
