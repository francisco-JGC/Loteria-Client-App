import 'package:equatable/equatable.dart';

import '../../domain/entities/bet.dart';

class CartState extends Equatable {
  const CartState({this.bets = const []});

  final List<Bet> bets;

  bool get isEmpty => bets.isEmpty;
  bool get isNotEmpty => bets.isNotEmpty;
  int get total => bets.fold(0, (sum, b) => sum + b.amount);
  int get count => bets.length;

  @override
  List<Object?> get props => [bets];
}
