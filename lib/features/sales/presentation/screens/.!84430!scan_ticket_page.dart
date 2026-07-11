import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../core/di/injection.dart';
import '../../../games/domain/entities/game.dart';
import '../../../games/domain/entities/game_type.dart';
import '../../../tickets/domain/entities/ticket_detail.dart';
import '../../../tickets/domain/repositories/tickets_repository.dart';
import '../../domain/entities/bet.dart';
import '../../domain/entities/date_bet.dart';
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
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_busy) return;
    final raw = capture.barcodes
        .map((b) => b.rawValue)
        .firstWhere((v) => v != null && v.isNotEmpty, orElse: () => null);
    if (raw == null) return;

    if (!_looksLikeUuid(raw)) {
      setState(() => _error = 'QR no reconocido');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    final either = await getIt<TicketsRepository>().findById(raw);
    if (!mounted) return;

    either.match(
      (failure) {
        setState(() {
          _busy = false;
          _error = 'No se encontró el boleto: ${failure.message}';
        });
      },
      (detail) {
        if (detail.summary.gameId != widget.game.id) {
          setState(() {
            _busy = false;
            _error = 'Este boleto es de otro juego';
          });
          return;
        }
        if (widget.game.type == GameType.multiSorteo) {
          setState(() {
            _busy = false;
            _error = 'Los boletos de Multi Sorteo no se pueden re-escanear';
          });
          return;
        }
        final count = _loadIntoCart(detail);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$count números cargados')),
        );
        Navigator.of(context).pop();
      },
    );
  }

  bool _looksLikeUuid(String raw) {
    final v = raw.trim();
    final uuidPattern = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidPattern.hasMatch(v);
  }

  int _loadIntoCart(TicketDetail detail) {
    final client = detail.summary.client;
    switch (widget.game.type) {
      case GameType.regular:
        return _loadRegular(detail, client);
      case GameType.threeDigit:
        return _loadGana3(detail, client);
      case GameType.fourDigit:
        return _loadCombo(detail, client);
      case GameType.date:
        return _loadDates(detail, client);
      case GameType.multiSorteo:
        return 0;
    }
  }

  int _loadRegular(TicketDetail detail, String? client) {
    final bets = <Bet>[];
    for (final line in detail.lines) {
      final n = int.tryParse(line.label);
      if (n == null || n < 0 || n > 99) continue;
      bets.add(Bet(number: n, amount: line.amount));
    }
    ref
        .read(cartControllerProvider(widget.game.id).notifier)
        .addBets(bets, client: client);
    return bets.length;
  }

  int _loadGana3(TicketDetail detail, String? client) {
    final notifier =
        ref.read(gana3CartControllerProvider(widget.game.id).notifier);
    int count = 0;
    for (final line in detail.lines) {
      final isFalso = line.label.contains('(F)');
      final numStr = line.label.replaceAll('(F)', '').trim();
      final n = int.tryParse(numStr);
      if (n == null || n < 0 || n > 999) continue;
      notifier.addSingle(
