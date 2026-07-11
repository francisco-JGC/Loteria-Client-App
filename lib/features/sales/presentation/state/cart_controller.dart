import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/bet.dart';
import 'cart_state.dart';

enum AddBetOutcome { added, invalid }

class CartController extends Notifier<CartState> {
  CartController(this.gameId);

  final String gameId;

  @override
  CartState build() => const CartState();

  AddBetOutcome addSingle({
    required int number,
    required int amount,
    String? client,
  }) {
    if (number < 0 || number > 99 || amount < 1 || amount > 999) {
      return AddBetOutcome.invalid;
    }
    state = CartState(
      bets: [...state.bets, Bet(number: number, amount: amount)],
      client: _clean(client) ?? state.client,
    );
    return AddBetOutcome.added;
  }

  void addRange({
    required int start,
    required int end,
    required int amount,
  }) {
    final newBets = [
      for (var n = start; n <= end; n++) Bet(number: n, amount: amount),
    ];
    state = CartState(
      bets: [...state.bets, ...newBets],
      client: state.client,
    );
  }

  void addRandom({required int count, required int amount}) {
    final random = Random();
    final numbers = <int>{};
    final target = count.clamp(1, 100);
    while (numbers.length < target) {
      numbers.add(random.nextInt(100));
    }
    final newBets =
        numbers.map((n) => Bet(number: n, amount: amount)).toList();
    state = CartState(
      bets: [...state.bets, ...newBets],
      client: state.client,
    );
  }

  void addBets(List<Bet> bets, {String? client}) {
    if (bets.isEmpty) return;
    state = CartState(
      bets: [...state.bets, ...bets],
      client: _clean(client) ?? state.client,
    );
  }

  void removeAt(int index) {
    state = CartState(
      bets: [...state.bets]..removeAt(index),
      client: state.client,
    );
  }

  void clear() {
    state = const CartState();
  }

  String? _clean(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}

final cartControllerProvider =
    NotifierProvider.family<CartController, CartState, String>(
  CartController.new,
);
