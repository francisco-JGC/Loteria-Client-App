import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/gana3_bet.dart';
import 'cart_controller.dart';
import 'gana3_cart_state.dart';

class Gana3CartController extends Notifier<Gana3CartState> {
  Gana3CartController(this.gameId);

  final String gameId;

  @override
  Gana3CartState build() => const Gana3CartState();

  AddBetOutcome addSingle({
    required int number,
    required int amount,
    required bool isExact,
    String? client,
  }) {
    if (number < 0 || number > 999) return AddBetOutcome.invalid;
    if (amount < 1 || amount > 999) return AddBetOutcome.invalid;
    state = Gana3CartState(
      bets: [
        ...state.bets,
        Gana3Bet(number: number, amount: amount, isExact: isExact),
      ],
      client: _clean(client),
    );
    return AddBetOutcome.added;
  }

  void removeAt(int index) {
    state = Gana3CartState(
      bets: [...state.bets]..removeAt(index),
      client: state.client,
    );
  }

  void clear() {
    state = const Gana3CartState();
  }

  String? _clean(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}

final gana3CartControllerProvider = NotifierProvider.family<
    Gana3CartController, Gana3CartState, String>(Gana3CartController.new);
