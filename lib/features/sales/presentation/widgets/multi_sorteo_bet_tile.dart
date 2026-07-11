import 'package:flutter/material.dart';

import '../../../../core/utils/currency.dart';
import '../../domain/entities/multi_sorteo_bet.dart';

class MultiSorteoBetTile extends StatelessWidget {
  const MultiSorteoBetTile({
    required this.bet,
    required this.onRemove,
    super.key,
  });

  final MultiSorteoBet bet;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black54),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              bet.subGameName,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            bet.label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 10),
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
