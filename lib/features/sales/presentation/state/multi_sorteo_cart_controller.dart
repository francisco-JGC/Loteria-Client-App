import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/prize.dart';
import '../../domain/entities/date_bet.dart';
import '../../domain/entities/multi_sorteo_bet.dart';
import 'cart_controller.dart';
import 'multi_sorteo_cart_state.dart';

class MultiSorteoCartController extends Notifier<MultiSorteoCartState> {
  MultiSorteoCartController(this.gameId);

  final String gameId;

  @override
  MultiSorteoCartState build() => const MultiSorteoCartState();

  AddBetOutcome addRegular({
    required String subGameId,
    required String subGameName,
    required int number,
    required int amount,
    String? client,
  }) {
    if (number < 0 || number > 99) return AddBetOutcome.invalid;
    if (amount < 1 || amount > 999) return AddBetOutcome.invalid;
    _push(
      subGameId: subGameId,
      subGameName: subGameName,
      label: number.toString().padLeft(2, '0'),
      amount: amount,
      prize: amount * kPrizeMultiplier,
      client: client,
    );
    return AddBetOutcome.added;
  }

  AddBetOutcome addDate({
    required String subGameId,
    required String subGameName,
    required int day,
    required int month,
    required int amount,
    String? client,
  }) {
    if (day < 1 || day > 31) return AddBetOutcome.invalid;
    if (month < 1 || month > 12) return AddBetOutcome.invalid;
    if (amount < 1 || amount > 999) return AddBetOutcome.invalid;
    final dayStr = day.toString().padLeft(2, '0');
    final label = '$dayStr-${kMonthAbbreviations[month - 1]}';
    _push(
      subGameId: subGameId,
      subGameName: subGameName,
      label: label,
      amount: amount,
      prize: amount * kDateMultiplier,
      client: client,
    );
    return AddBetOutcome.added;
  }

  AddBetOutcome addGana3({
    required String subGameId,
    required String subGameName,
    required int number,
    required int amount,
    required bool isExact,
    String? client,
  }) {
    if (number < 0 || number > 999) return AddBetOutcome.invalid;
    if (amount < 1 || amount > 999) return AddBetOutcome.invalid;
    final numStr = number.toString().padLeft(3, '0');
    final label = isExact ? numStr : '$numStr (F)';
    final multiplier =
        isExact ? kGana3ExactMultiplier : kGana3EasyMultiplier;
    _push(
      subGameId: subGameId,
      subGameName: subGameName,
      label: label,
      amount: amount,
      prize: amount * multiplier,
      client: client,
    );
    return AddBetOutcome.added;
  }

  AddBetOutcome addCombo({
    required String subGameId,
    required String subGameName,
    required int number,
    required int amount,
    String? client,
  }) {
    if (number < 0 || number > 9999) return AddBetOutcome.invalid;
    if (amount < 1 || amount > 999) return AddBetOutcome.invalid;
    _push(
      subGameId: subGameId,
      subGameName: subGameName,
      label: number.toString().padLeft(4, '0'),
      amount: amount,
      prize: amount * kComboMultiplier,
      client: client,
    );
    return AddBetOutcome.added;
  }

  void removeAt(int index) {
    state = MultiSorteoCartState(
      bets: [...state.bets]..removeAt(index),
      client: state.client,
    );
  }

  void clear() {
    state = const MultiSorteoCartState();
  }

  void _push({
    required String subGameId,
    required String subGameName,
    required String label,
    required int amount,
    required int prize,
    required String? client,
  }) {
    state = MultiSorteoCartState(
      bets: [
        ...state.bets,
        MultiSorteoBet(
          subGameId: subGameId,
          subGameName: subGameName,
          label: label,
          amount: amount,
          prize: prize,
        ),
      ],
      client: _clean(client),
    );
  }

  String? _clean(String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}

final multiSorteoCartControllerProvider = NotifierProvider.family<
    MultiSorteoCartController,
    MultiSorteoCartState,
    String>(MultiSorteoCartController.new);
