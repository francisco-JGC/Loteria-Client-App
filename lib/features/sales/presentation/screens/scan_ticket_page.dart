import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../domain/entities/bet.dart';
import '../state/cart_controller.dart';

class ScanTicketPage extends ConsumerStatefulWidget {
  const ScanTicketPage({required this.gameId, super.key});

  final String gameId;

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
    ref
        .read(cartControllerProvider(widget.gameId).notifier)
        .addBets(result.bets!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${result.bets!.length} números cargados')),
    );
    Navigator.of(context).pop();
  }

  _ParseResult _parse(String raw) {
    try {
      final data = jsonDecode(raw);
      if (data is! Map<String, dynamic>) {
        return const _ParseResult.err('QR no reconocido');
      }
      final scannedGameId = data['g'] as String?;
      if (scannedGameId == null) {
        return const _ParseResult.err('QR no reconocido');
      }
      if (scannedGameId != widget.gameId) {
        return _ParseResult.err(
          'Este boleto es de otro juego ($scannedGameId)',
        );
      }
      final rawBets = data['b'];
      if (rawBets is! List) {
        return const _ParseResult.err('QR sin números');
      }
      final bets = <Bet>[];
      for (final item in rawBets) {
        if (item is! Map<String, dynamic>) continue;
        final n = int.tryParse(item['n']?.toString() ?? '');
        final a = item['a'];
        if (n == null || n < 0 || n > 99 || a is! int || a <= 0) {
          return const _ParseResult.err('QR con datos inválidos');
        }
        bets.add(Bet(number: n, amount: a));
      }
      if (bets.isEmpty) return const _ParseResult.err('QR sin números');
      return _ParseResult.ok(bets);
    } catch (_) {
      return const _ParseResult.err('QR ilegible');
    }
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
  const _ParseResult({this.bets, this.error});

  const _ParseResult.ok(List<Bet> bets) : this(bets: bets);
  const _ParseResult.err(String error) : this(error: error);

  final List<Bet>? bets;
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
