import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/session/current_user.dart';
import '../../../../core/utils/currency.dart';
import '../../../printer/domain/entities/ticket_payload.dart';
import '../../../printer/presentation/state/printer_controller.dart';
import '../../../sales/presentation/state/cart_controller.dart';
import '../../../sales/presentation/state/cart_state.dart';
import '../../../sales/presentation/widgets/bet_tile.dart';
import '../../../sales/presentation/widgets/line_form.dart';
import '../../../sales/presentation/widgets/random_form.dart';
import '../../domain/entities/game.dart';

class GameDetailPage extends ConsumerWidget {
  const GameDetailPage({required this.gameId, this.game, super.key});

  final String gameId;
  final Game? game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolved = game;
    if (resolved == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Juego')),
        body: _NotFound(gameId: gameId),
      );
    }

    final cart = ref.watch(cartControllerProvider(resolved.id));
    final controller = ref.read(cartControllerProvider(resolved.id).notifier);
    final printerState = ref.watch(printerControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(resolved.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Registrar línea',
            onPressed: () => _openLineForm(context, controller),
          ),
          IconButton(
            icon: const Icon(Icons.casino_outlined),
            tooltip: 'Registrar aleatorio',
            onPressed: () => _openRandomForm(context, controller),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Limpiar carrito',
            onPressed: cart.isEmpty
                ? null
                : () => _confirmClear(context, controller),
          ),
        ],
      ),
      body: cart.isEmpty
          ? const _EmptyView()
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: cart.bets.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) => BetTile(
                bet: cart.bets[i],
                onRemove: () => controller.removeAt(i),
              ),
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : _TotalBar(
              total: cart.total,
              numberCount: cart.count,
              isPrinting: printerState.isPrinting,
              onPrint: () => _print(context, ref, resolved, cart),
            ),
    );
  }

  Future<void> _openLineForm(
    BuildContext context,
    CartController controller,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => LineForm(
        onSubmit: (r) => controller.addRange(
          start: r.start,
          end: r.end,
          amount: r.amount,
        ),
      ),
    );
  }

  Future<void> _openRandomForm(
    BuildContext context,
    CartController controller,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => RandomForm(
        onSubmit: (r) => controller.addRandom(
          count: r.count,
          amount: r.amount,
        ),
      ),
    );
  }

  Future<void> _confirmClear(
    BuildContext context,
    CartController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Limpiar carrito'),
        content: const Text('¿Descartar todos los números registrados?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) controller.clear();
  }

  Future<void> _print(
    BuildContext context,
    WidgetRef ref,
    Game game,
    CartState cart,
  ) async {
    final printerNotifier = ref.read(printerControllerProvider.notifier);
    final printer = ref.read(printerControllerProvider);
    final messenger = ScaffoldMessenger.of(context);

    if (!printer.isConnected) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'No hay impresora conectada. Ve a Configuración → Impresora.',
          ),
        ),
      );
      return;
    }

    final user = ref.read(currentUserProvider);
    final payload = TicketPayload(
      gameName: game.name,
      lines: cart.bets
          .map((b) => TicketLine(
                number: b.numberLabel,
                amount: b.amount,
                prize: b.prize,
              ))
          .toList(),
      folio: _generateFolio(),
      date: DateTime.now(),
      seller: user.name,
    );

    await printerNotifier.printTicket(payload);

    final after = ref.read(printerControllerProvider);
    if (after.errorMessage != null) {
      messenger.showSnackBar(SnackBar(
        content: Text('Error al imprimir: ${after.errorMessage}'),
      ));
      return;
    }

    ref.read(cartControllerProvider(game.id).notifier).clear();
    messenger.showSnackBar(
      const SnackBar(content: Text('Ticket impreso')),
    );
  }

  String _generateFolio() {
    final now = DateTime.now();
    return now.millisecondsSinceEpoch.toRadixString(36).toUpperCase();
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.grid_view_outlined,
                size: 64, color: Colors.black26),
            SizedBox(height: 12),
            Text(
              'Aún no hay números registrados',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalBar extends StatelessWidget {
  const _TotalBar({
    required this.total,
    required this.numberCount,
    required this.isPrinting,
    required this.onPrint,
  });

  final int total;
  final int numberCount;
  final bool isPrinting;
  final VoidCallback onPrint;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    kCurrencyFormat.format(total),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '$numberCount número${numberCount == 1 ? '' : 's'}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
            FilledButton.icon(
              icon: isPrinting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.print),
              label: const Text('Imprimir'),
              onPressed: isPrinting ? null : onPrint,
            ),
          ],
        ),
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  const _NotFound({required this.gameId});

  final String gameId;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.black38),
          const SizedBox(height: 12),
          Text('Juego "$gameId" no encontrado'),
        ],
      ),
    );
  }
}
