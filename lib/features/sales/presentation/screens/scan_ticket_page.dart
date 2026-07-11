import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../games/domain/entities/game.dart';
import '../../../games/domain/entities/game_type.dart';
import '../../domain/entities/bet.dart';
import '../../domain/entities/date_bet.dart';
import '../../domain/entities/gana3_bet.dart';
import '../state/cart_controller.dart';
import '../state/combo_cart_controller.dart';
import '../state/date_cart_controller.dart';
import '../state/gana3_cart_controller.dart';

class ScanTicketPage extends ConsumerStatefulWidget {
  const ScanTicketPage({required this.game, super.key});

  final Game game;

  @override
  ConsumerState<ScanTicketPage> createState() => _ScanTicketPageState();
}

class _ScanTicketPageState extends ConsumerState<ScanTicketPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final raw = capture.barcodes
        .map((b) => b.rawValue)
        .firstWhere((v) => v != null && v.isNotEmpty, orElse: () => null);
    if (raw == null) return;

    final result = _parse(raw);
    if (result.error != null) {
      setState(() => _error = result.error);
      return;
    }

    _handled = true;
    final count = result.apply!(ref);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$count números cargados')),
    );
    Navigator.of(context).pop();
  }

  _ParseResult _parse(String raw) {
    try {
      final data = jsonDecode(raw);
      if (data is! Map<String, dynamic>) {
        return const _ParseResult.err('QR no reconocido');
      }
      final scannedSlug = data['g'] as String?;
      if (scannedSlug == null) {
        return const _ParseResult.err('QR no reconocido');
      }
      if (scannedSlug != widget.game.slug) {
        return _ParseResult.err(
          'Este boleto es de otro juego ($scannedSlug)',
        );
      }
      if (widget.game.type == GameType.multiSorteo) {
        return const _ParseResult.err(
          'Los boletos de Multi Sorteo no se pueden re-escanear',
        );
      }
      final rawBets = data['b'];
      if (rawBets is! List || rawBets.isEmpty) {
        return const _ParseResult.err('QR sin números');
      }
      final client = data['c'] as String?;

      switch (widget.game.type) {
        case GameType.date:
          return _parseDates(rawBets, client);
        case GameType.threeDigit:
          return _parseGana3(rawBets, client);
        case GameType.fourDigit:
          return _parseCombo(rawBets, client);
        case GameType.regular:
          return _parseRegular(rawBets, client);
        case GameType.multiSorteo:
          return const _ParseResult.err(
            'Los boletos de Multi Sorteo no se pueden re-escanear',
          );
      }
    } catch (_) {
      return const _ParseResult.err('QR ilegible');
    }
  }

  _ParseResult _parseRegular(List<dynamic> raw, String? client) {
    final bets = <Bet>[];
    for (final item in raw) {
      final entry = _entry(item);
      if (entry == null) return const _ParseResult.err('QR con datos inválidos');
      final n = int.tryParse(entry.$1);
      if (n == null || n < 0 || n > 99) {
        return const _ParseResult.err('QR con datos inválidos');
      }
      bets.add(Bet(number: n, amount: entry.$2));
    }
    return _ParseResult.ok((ref) {
      ref
          .read(cartControllerProvider(widget.game.id).notifier)
          .addBets(bets, client: client);
      return bets.length;
    });
  }

  _ParseResult _parseDates(List<dynamic> raw, String? client) {
    final bets = <DateBet>[];
    for (final item in raw) {
      final entry = _entry(item);
      if (entry == null) return const _ParseResult.err('QR con datos inválidos');
      final parts = entry.$1.split('-');
      if (parts.length != 2) return const _ParseResult.err('QR con fecha inválida');
      final day = int.tryParse(parts[0]);
      final monthIndex = kMonthAbbreviations.indexOf(parts[1]);
      if (day == null || day < 1 || day > 31 || monthIndex < 0) {
        return const _ParseResult.err('QR con fecha inválida');
      }
      bets.add(DateBet(day: day, month: monthIndex + 1, amount: entry.$2));
    }
    return _ParseResult.ok((ref) {
      final notifier =
          ref.read(dateCartControllerProvider(widget.game.id).notifier);
      for (final b in bets) {
        notifier.addSingle(
          day: b.day,
          month: b.month,
          amount: b.amount,
          client: client,
        );
      }
      return bets.length;
    });
  }

  _ParseResult _parseGana3(List<dynamic> raw, String? client) {
    final bets = <Gana3Bet>[];
    for (final item in raw) {
      final entry = _entry(item);
      if (entry == null) return const _ParseResult.err('QR con datos inválidos');
      final label = entry.$1;
      final isEasy = label.contains('(F)');
      final numStr = label.replaceAll('(F)', '').trim();
      final n = int.tryParse(numStr);
      if (n == null || n < 0 || n > 999) {
        return const _ParseResult.err('QR con datos inválidos');
      }
      bets.add(Gana3Bet(number: n, amount: entry.$2, isExact: !isEasy));
    }
    return _ParseResult.ok((ref) {
      final notifier =
          ref.read(gana3CartControllerProvider(widget.game.id).notifier);
      for (final b in bets) {
        notifier.addSingle(
          number: b.number,
          amount: b.amount,
          isExact: b.isExact,
          client: client,
        );
      }
      return bets.length;
    });
  }

  _ParseResult _parseCombo(List<dynamic> raw, String? client) {
    final bets = <(int, int)>[];
    for (final item in raw) {
      final entry = _entry(item);
      if (entry == null) return const _ParseResult.err('QR con datos inválidos');
      final n = int.tryParse(entry.$1);
      if (n == null || n < 0 || n > 9999) {
        return const _ParseResult.err('QR con datos inválidos');
      }
      bets.add((n, entry.$2));
    }
    return _ParseResult.ok((ref) {
      final notifier =
          ref.read(comboCartControllerProvider(widget.game.id).notifier);
      for (final b in bets) {
        notifier.addSingle(number: b.$1, amount: b.$2, client: client);
      }
      return bets.length;
    });
  }

  (String, int)? _entry(dynamic item) {
    if (item is! List || item.length < 2) return null;
    final label = item[0]?.toString();
    final amount = item[1];
    if (label == null || amount is! int || amount <= 0) return null;
    return (label, amount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear boleto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            tooltip: 'Linterna',
            onPressed: _controller.toggleTorch,
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch_outlined),
            tooltip: 'Cambiar cámara',
            onPressed: _controller.switchCamera,
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          const _ScannerOverlay(),
          if (_error != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: _ErrorCard(
                message: _error!,
                onDismiss: () => setState(() => _error = null),
              ),
            ),
        ],
      ),
    );
  }
}

class _ParseResult {
  const _ParseResult({this.apply, this.error});

  const _ParseResult.ok(int Function(WidgetRef ref) apply)
      : this(apply: apply);
  const _ParseResult.err(String error) : this(error: error);

  final int Function(WidgetRef ref)? apply;
  final String? error;
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 3),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onDismiss});

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 12),
          Expanded(
            child: Text(message, style: TextStyle(color: Colors.red.shade800)),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onDismiss,
          ),
        ],
      ),
    );
  }
}
