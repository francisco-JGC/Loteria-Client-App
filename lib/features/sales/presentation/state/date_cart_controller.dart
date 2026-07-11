import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/date_bet.dart';
import 'cart_controller.dart';
import 'date_cart_state.dart';

class DateCartController extends Notifier<DateCartState> {
  DateCartController(this.gameId);

  final String gameId;

  @override
  DateCartState build() => const DateCartState();

  AddBetOutcome addSingle({
    required int day,
    required int month,
    required int amount,
    String? client,
  }) {
    if (day < 1 || day > 31) return AddBetOutcome.invalid;
    if (month < 1 || month > 12) return AddBetOutcome.invalid;
    if (amount < 1 || amount > 999) return AddBetOutcome.invalid;
    state = DateCartState(
      bets: [
        ...state.bets,
        DateBet(day: day, month: month, amount: amount),
      ],
      client: _clean(client) ?? state.client,
    );
    return AddBetOutcome.added;
  }

  void addRange({
    required int dayStart,
    required int dayEnd,
    required int month,
    required int amount,
  }) {
    if (dayStart < 1 || dayEnd > 31 || dayEnd < dayStart) return;
    if (month < 1 || month > 12) return;
    if (amount < 1 || amount > 999) return;
    final newBets = [
      for (var d = dayStart; d <= dayEnd; d++)
        DateBet(day: d, month: month, amount: amount),
    ];
    state = DateCartState(
      bets: [...state.bets, ...newBets],
      client: state.client,
    );
  }

  void removeAt(int index) {
    state = DateCartState(
      bets: [...state.bets]..removeAt(index),
      client: state.client,
    );
  }

  void clear() {
    state = const DateCartState();
  }

  String? _clean(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}

final dateCartControllerProvider = NotifierProvider.family<
    DateCartController, DateCartState, String>(DateCartController.new);
