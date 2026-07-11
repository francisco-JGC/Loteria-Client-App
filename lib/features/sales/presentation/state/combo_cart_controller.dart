import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/combo_bet.dart';
import 'cart_controller.dart';
import 'combo_cart_state.dart';

class ComboCartController extends Notifier<ComboCartState> {
  ComboCartController(this.gameId);

  final String gameId;

  @override
  ComboCartState build() => const ComboCartState();

  AddBetOutcome addSingle({
    required int number,
    required int amount,
    String? client,
  }) {
    if (number < 0 || number > 9999) return AddBetOutcome.invalid;
    if (amount < 1 || amount > 999) return AddBetOutcome.invalid;
    state = ComboCartState(
      bets: [...state.bets, ComboBet(number: number, amount: amount)],
      client: _clean(client) ?? state.client,
    );
    return AddBetOutcome.added;
  }

  void addRange({
    required int start,
    required int end,
    required int amount,
  }) {
    if (start < 0 || end > 9999 || end < start) return;
    if (amount < 1 || amount > 999) return;
    final newBets = [
      for (var n = start; n <= end; n++) ComboBet(number: n, amount: amount),
    ];
    state = ComboCartState(
      bets: [...state.bets, ...newBets],
      client: state.client,
    );
  }

  void addRandom({required int count, required int amount}) {
    if (count < 1 || amount < 1 || amount > 999) return;
    final random = math.Random();
    final numbers = <int>{};
    while (numbers.length < count.clamp(1, 10000)) {
      numbers.add(random.nextInt(10000));
    }
    final newBets =
        numbers.map((n) => ComboBet(number: n, amount: amount)).toList();
    state = ComboCartState(
      bets: [...state.bets, ...newBets],
      client: state.client,
    );
  }

  void removeAt(int index) {
    state = ComboCartState(
      bets: [...state.bets]..removeAt(index),
      client: state.client,
    );
  }

  void clear() {
    state = const ComboCartState();
  }

  String? _clean(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}

final comboCartControllerProvider = NotifierProvider.family<
    ComboCartController, ComboCartState, String>(ComboCartController.new);
