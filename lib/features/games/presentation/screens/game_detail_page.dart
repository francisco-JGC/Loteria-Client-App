import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/session/current_user.dart';
import '../../../../core/utils/currency.dart';
import '../../../printer/domain/entities/ticket_payload.dart';
import '../../../printer/presentation/state/printer_controller.dart';
import '../../../sales/presentation/state/cart_controller.dart';
import '../../../sales/presentation/state/cart_state.dart';
import '../../../sales/presentation/state/combo_cart_controller.dart';
import '../../../sales/presentation/state/combo_cart_state.dart';
import '../../../sales/presentation/state/date_cart_controller.dart';
import '../../../sales/presentation/state/date_cart_state.dart';
import '../../../sales/presentation/state/gana3_cart_controller.dart';
import '../../../sales/presentation/state/gana3_cart_state.dart';
import '../../../sales/presentation/widgets/bet_tile.dart';
import '../../../sales/presentation/widgets/combo_bet_tile.dart';
import '../../../sales/presentation/widgets/date_bet_tile.dart';
import '../../../sales/presentation/widgets/gana3_bet_tile.dart';
import '../../../sales/presentation/widgets/line_form.dart';
import '../../../sales/presentation/widgets/quick_bet_form.dart';
import '../../../sales/presentation/widgets/quick_combo_bet_form.dart';
import '../../../sales/presentation/widgets/quick_date_bet_form.dart';
import '../../../sales/presentation/widgets/quick_gana3_bet_form.dart';
import '../../../sales/presentation/widgets/random_form.dart';
import '../../domain/entities/game.dart';

const String _kDateGameId = 'fechas';
const String _kComboGameId = 'combo';
const Set<String> _kGana3LikeGameIds = {'gana3', 'juega3', 'tresmonazo'};

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
    if (resolved.id == _kDateGameId) {
      return _DateGameView(game: resolved);
    }
    if (_kGana3LikeGameIds.contains(resolved.id)) {
      return _Gana3GameView(game: resolved);
    }
    if (resolved.id == _kComboGameId) {
      return _ComboGameView(game: resolved);
    }
    return _RegularGameView(game: resolved);
  }
}

class _RegularGameView extends ConsumerWidget {
  const _RegularGameView({required this.game});

  final Game game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartControllerProvider(game.id));
    final controller = ref.read(cartControllerProvider(game.id).notifier);
    final printerState = ref.watch(printerControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(game.name),
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
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Escanear boleto',
            onPressed: () => context.push('/juegos/${game.id}/escanear'),
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Limpiar carrito',
            onPressed: cart.isEmpty
                ? null
                : () => _confirmClear(context, controller.clear),
          ),
        ],
      ),
      body: Column(
        children: [
          QuickBetForm(onSubmit: controller.addSingle),
          Expanded(
            child: cart.isEmpty
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
          ),
        ],
      ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : _TotalBar(
              total: cart.total,
              numberCount: cart.count,
              isPrinting: printerState.isPrinting,
              onPrint: () => _printRegular(context, ref, game, cart),
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
}

class _DateGameView extends ConsumerWidget {
  const _DateGameView({required this.game});

  final Game game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(dateCartControllerProvider(game.id));
    final controller =
        ref.read(dateCartControllerProvider(game.id).notifier);
    final printerState = ref.watch(printerControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(game.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Limpiar carrito',
            onPressed: cart.isEmpty
                ? null
                : () => _confirmClear(context, controller.clear),
          ),
        ],
      ),
      body: Column(
        children: [
          QuickDateBetForm(onSubmit: controller.addSingle),
          Expanded(
            child: cart.isEmpty
                ? const _EmptyView(
                    icon: Icons.calendar_month_outlined,
                    label: 'Aún no hay fechas registradas',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: cart.bets.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, i) => DateBetTile(
                      bet: cart.bets[i],
                      onRemove: () => controller.removeAt(i),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : _TotalBar(
              total: cart.total,
              numberCount: cart.count,
              isPrinting: printerState.isPrinting,
              onPrint: () => _printDates(context, ref, game, cart),
            ),
    );
  }
}

class _ComboGameView extends ConsumerWidget {
  const _ComboGameView({required this.game});

  final Game game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(comboCartControllerProvider(game.id));
    final controller =
        ref.read(comboCartControllerProvider(game.id).notifier);
    final printerState = ref.watch(printerControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(game.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Limpiar carrito',
            onPressed: cart.isEmpty
                ? null
                : () => _confirmClear(context, controller.clear),
          ),
        ],
      ),
      body: Column(
        children: [
          QuickComboBetForm(onSubmit: controller.addSingle),
          Expanded(
            child: cart.isEmpty
                ? const _EmptyView(
                    icon: Icons.tag,
                    label: 'Aún no hay números registrados',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: cart.bets.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, i) => ComboBetTile(
                      bet: cart.bets[i],
                      onRemove: () => controller.removeAt(i),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : _TotalBar(
              total: cart.total,
              numberCount: cart.count,
              isPrinting: printerState.isPrinting,
              onPrint: () => _printCombo(context, ref, game, cart),
            ),
    );
  }
}

class _Gana3GameView extends ConsumerWidget {
  const _Gana3GameView({required this.game});

  final Game game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(gana3CartControllerProvider(game.id));
    final controller =
        ref.read(gana3CartControllerProvider(game.id).notifier);
    final printerState = ref.watch(printerControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(game.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Limpiar carrito',
            onPressed: cart.isEmpty
                ? null
                : () => _confirmClear(context, controller.clear),
          ),
        ],
      ),
      body: Column(
        children: [
          QuickGana3BetForm(onSubmit: controller.addSingle),
          Expanded(
            child: cart.isEmpty
                ? const _EmptyView(
                    icon: Icons.tag,
                    label: 'Aún no hay números registrados',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: cart.bets.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, i) => Gana3BetTile(
                      bet: cart.bets[i],
                      onRemove: () => controller.removeAt(i),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : _TotalBar(
              total: cart.total,
              numberCount: cart.count,
              isPrinting: printerState.isPrinting,
              onPrint: () => _printGana3(context, ref, game, cart),
            ),
    );
  }
}

Future<void> _confirmClear(
  BuildContext context,
  VoidCallback onConfirm,
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
  if (confirmed ?? false) onConfirm();
}

Future<void> _printRegular(
  BuildContext context,
  WidgetRef ref,
  Game game,
  CartState cart,
) async {
  final payload = TicketPayload(
    gameId: game.id,
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
    seller: ref.read(currentUserProvider).name,
    client: cart.client,
  );
  await _sendToPrinter(
    context,
    ref,
    payload,
    onSuccess: () =>
        ref.read(cartControllerProvider(game.id).notifier).clear(),
  );
}

Future<void> _printCombo(
  BuildContext context,
  WidgetRef ref,
  Game game,
  ComboCartState cart,
) async {
  final payload = TicketPayload(
    gameId: game.id,
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
    seller: ref.read(currentUserProvider).name,
    client: cart.client,
  );
  await _sendToPrinter(
    context,
    ref,
    payload,
    onSuccess: () =>
        ref.read(comboCartControllerProvider(game.id).notifier).clear(),
  );
}

Future<void> _printGana3(
  BuildContext context,
  WidgetRef ref,
  Game game,
  Gana3CartState cart,
) async {
  final payload = TicketPayload(
    gameId: game.id,
    gameName: game.name,
    lines: cart.bets
        .map((b) => TicketLine(
              number: b.isExact ? b.numberLabel : '${b.numberLabel} (F)',
              amount: b.amount,
              prize: b.prize,
            ))
        .toList(),
    folio: _generateFolio(),
    date: DateTime.now(),
    seller: ref.read(currentUserProvider).name,
    client: cart.client,
  );
  await _sendToPrinter(
    context,
    ref,
    payload,
    onSuccess: () =>
        ref.read(gana3CartControllerProvider(game.id).notifier).clear(),
  );
}

Future<void> _printDates(
  BuildContext context,
  WidgetRef ref,
  Game game,
  DateCartState cart,
) async {
  final payload = TicketPayload(
    gameId: game.id,
    gameName: game.name,
    lines: cart.bets
        .map((b) => TicketLine(
              number: b.label,
              amount: b.amount,
              prize: b.prize,
            ))
        .toList(),
    folio: _generateFolio(),
    date: DateTime.now(),
    seller: ref.read(currentUserProvider).name,
    client: cart.client,
  );
  await _sendToPrinter(
    context,
    ref,
    payload,
    onSuccess: () =>
        ref.read(dateCartControllerProvider(game.id).notifier).clear(),
  );
}

Future<void> _sendToPrinter(
  BuildContext context,
  WidgetRef ref,
  TicketPayload payload, {
  required VoidCallback onSuccess,
}) async {
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

  await printerNotifier.printTicket(payload);
  final after = ref.read(printerControllerProvider);
  if (after.errorMessage != null) {
    messenger.showSnackBar(SnackBar(
      content: Text('Error al imprimir: ${after.errorMessage}'),
    ));
    return;
  }

  onSuccess();
  messenger.showSnackBar(const SnackBar(content: Text('Ticket impreso')));
}

String _generateFolio() {
  return DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase();
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({
    this.icon = Icons.grid_view_outlined,
    this.label = 'Aún no hay números registrados',
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: Colors.black26),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.black54),
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
