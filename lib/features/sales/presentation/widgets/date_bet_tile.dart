import 'package:flutter/material.dart';

import '../../../../core/utils/currency.dart';
import '../../domain/entities/date_bet.dart';

class DateBetTile extends StatelessWidget {
  const DateBetTile({required this.bet, required this.onRemove, super.key});

  final DateBet bet;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, size: 20, color: Colors.black),
          const SizedBox(width: 8),
          SizedBox(
            width: 88,
            child: Text(
              bet.label,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Text(
              kCurrencyFormat.format(bet.amount),
              style: const TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
          const Icon(Icons.emoji_events_outlined,
              size: 18, color: Colors.black),
          const SizedBox(width: 4),
          Text(
            kCurrencyFormat.format(bet.prize),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.black),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}
