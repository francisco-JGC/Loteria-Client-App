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
      client: _clean(client),
    );
    return AddBetOutcome.added;
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
