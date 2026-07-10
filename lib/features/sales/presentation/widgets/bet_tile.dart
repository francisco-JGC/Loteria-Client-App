import 'package:flutter/material.dart';

import '../../../../core/utils/currency.dart';
import '../../domain/entities/bet.dart';

class BetTile extends StatelessWidget {
  const BetTile({required this.bet, required this.onRemove, super.key});

  final Bet bet;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.tag, size: 20, color: Colors.black),
          const SizedBox(width: 8),
          SizedBox(
            width: 48,
            child: Text(
              bet.numberLabel,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.attach_money, size: 20, color: Colors.black),
          Expanded(
            child: Text(
              kCurrencyFormat.format(bet.amount),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
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
