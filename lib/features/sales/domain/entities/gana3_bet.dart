import 'package:equatable/equatable.dart';

import '../../../../core/utils/prize.dart';

class Gana3Bet extends Equatable {
  const Gana3Bet({
    required this.number,
    required this.amount,
    required this.isExact,
  });

  final int number;
  final int amount;
  final bool isExact;

  String get numberLabel => number.toString().padLeft(3, '0');
  String get modeLabel => isExact ? 'Exacto' : 'Fácil';
  int get prize => amount * (isExact ? kGana3ExactMultiplier : kGana3EasyMultiplier);

  @override
  List<Object?> get props => [number, amount, isExact];
}
