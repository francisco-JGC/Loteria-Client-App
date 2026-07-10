import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/bet.dart';
import 'cart_state.dart';

class CartController extends Notifier<CartState> {
  CartController(this.gameId);

  final String gameId;

  @override
  CartState build() => const CartState();

  void addRange({
    required int start,
    required int end,
    required int amount,
  }) {
    final newBets = [
      for (var n = start; n <= end; n++) Bet(number: n, amount: amount),
    ];
    state = CartState(bets: [...state.bets, ...newBets]);
  }

  void addRandom({required int count, required int amount}) {
    final random = Random();
    final numbers = <int>{};
    final target = count.clamp(1, 100);
    while (numbers.length < target) {
      numbers.add(random.nextInt(100));
    }
    final newBets = numbers.map((n) => Bet(number: n, amount: amount)).toList();
    state = CartState(bets: [...state.bets, ...newBets]);
  }

  void addBets(List<Bet> bets) {
    state = CartState(bets: [...state.bets, ...bets]);
  }

  void removeAt(int index) {
    final bets = [...state.bets]..removeAt(index);
    state = CartState(bets: bets);
  }

  void clear() {
    state = const CartState();
  }
}

final cartControllerProvider =
    NotifierProvider.family<CartController, CartState, String>(
  CartController.new,
);
