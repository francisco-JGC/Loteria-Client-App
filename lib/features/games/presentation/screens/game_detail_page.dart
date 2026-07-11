import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/session/current_user.dart';
import '../../../../core/utils/currency.dart';
import '../../../../core/utils/time_format.dart';
import '../../../printer/domain/entities/ticket_payload.dart';
import '../../../printer/presentation/state/printer_controller.dart';
import '../../../sale_points/presentation/state/active_sale_point_controller.dart';
import '../../../sales/presentation/state/cart_controller.dart';
import '../../../sales/presentation/state/cart_state.dart';
import '../../../sales/presentation/state/combo_cart_controller.dart';
import '../../../sales/presentation/state/combo_cart_state.dart';
import '../../../sales/presentation/state/date_cart_controller.dart';
import '../../../sales/presentation/state/date_cart_state.dart';
import '../../../sales/presentation/state/gana3_cart_controller.dart';
import '../../../sales/presentation/state/gana3_cart_state.dart';
import '../../../sales/presentation/state/multi_sorteo_cart_controller.dart';
import '../../../sales/presentation/state/multi_sorteo_cart_state.dart';
import '../../../sales/presentation/widgets/bet_tile.dart';
import '../../../sales/presentation/widgets/combo_bet_tile.dart';
import '../../../sales/presentation/widgets/combo_line_form.dart';
import '../../../sales/presentation/widgets/combo_random_form.dart';
import '../../../sales/presentation/widgets/date_bet_tile.dart';
import '../../../sales/presentation/widgets/date_line_form.dart';
import '../../../sales/presentation/widgets/gana3_bet_tile.dart';
import '../../../sales/presentation/widgets/gana3_line_form.dart';
import '../../../sales/presentation/widgets/gana3_random_form.dart';
import '../../../sales/presentation/widgets/line_form.dart';
import '../../../sales/presentation/widgets/multi_sorteo_bet_tile.dart';
import '../../../sales/presentation/widgets/quick_bet_form.dart';
import '../../../sales/presentation/widgets/quick_combo_bet_form.dart';
import '../../../sales/presentation/widgets/quick_date_bet_form.dart';
import '../../../sales/presentation/widgets/quick_gana3_bet_form.dart';
import '../../../sales/presentation/widgets/random_form.dart';
import '../../../tickets/domain/entities/create_ticket_request.dart';
import '../../../tickets/domain/entities/ticket_receipt.dart';
import '../../../tickets/domain/usecases/create_ticket.dart';
import '../../domain/entities/game.dart';
import '../../domain/entities/game_type.dart';
import '../state/games_controller.dart';

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
    switch (resolved.type) {
      case GameType.date:
        return _DateGameView(game: resolved);
      case GameType.threeDigit:
        return _Gana3GameView(game: resolved);
      case GameType.fourDigit:
        return _ComboGameView(game: resolved);
      case GameType.multiSorteo:
        return _MultiSorteoGameView(game: resolved);
      case GameType.regular:
        return _RegularGameView(game: resolved);
    }
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
            onPressed: () => context.push('/juegos/${game.id}/escanear', extra: game),
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
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Registrar línea',
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              showDragHandle: true,
              builder: (_) => DateLineForm(
                onSubmit: (r) => controller.addRange(
                  dayStart: r.dayStart,
                  dayEnd: r.dayEnd,
                  month: r.month,
                  amount: r.amount,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Escanear boleto',
            onPressed: () => context.push('/juegos/${game.id}/escanear', extra: game),
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

class _MultiSorteoGameView extends ConsumerStatefulWidget {
  const _MultiSorteoGameView({required this.game});

  final Game game;

  @override
  ConsumerState<_MultiSorteoGameView> createState() =>
      _MultiSorteoGameViewState();
}

class _MultiSorteoGameViewState
    extends ConsumerState<_MultiSorteoGameView> {
  Game? _selectedSubGame;
  final TextEditingController _sharedClientCtrl = TextEditingController();

  @override
  void dispose() {
    _sharedClientCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gamesAsync = ref.watch(gamesControllerProvider);
    final cart = ref.watch(multiSorteoCartControllerProvider(widget.game.id));
    final controller =
        ref.read(multiSorteoCartControllerProvider(widget.game.id).notifier);
    final printerState = ref.watch(printerControllerProvider);

    final subGames = gamesAsync.value
            ?.where((Game g) => g.id != widget.game.id)
            .toList() ??
        <Game>[];

    if (_selectedSubGame == null && subGames.isNotEmpty) {
      _selectedSubGame = subGames.first;
    } else if (_selectedSubGame != null &&
        !subGames.any((g) => g.id == _selectedSubGame!.id)) {
      _selectedSubGame = subGames.isNotEmpty ? subGames.first : null;
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.game.name, style: const TextStyle(fontSize: 18)),
            if (_selectedSubGame != null)
              Text(
                _selectedSubGame!.name,
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Escanear boleto',
            onPressed: () =>
                context.push('/juegos/${widget.game.id}/escanear', extra: widget.game),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: subGames.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final g = subGames[i];
                  final isSelected = _selectedSubGame?.id == g.id;
                  return ChoiceChip(
                    label: Text(g.name),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedSubGame = g);
                    },
                  );
                },
              ),
            ),
          ),
          if (_selectedSubGame != null)
            KeyedSubtree(
              key: ValueKey('multi-body-${_selectedSubGame!.id}'),
              child: _buildForm(controller, _selectedSubGame!),
            ),
          Expanded(
            child: cart.isEmpty
                ? const _EmptyView(
                    icon: Icons.shuffle,
                    label: 'Aún no hay números registrados',
                  )
                : _buildGroupedList(cart, controller),
          ),
        ],
      ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : _TotalBar(
              total: cart.total,
              numberCount: cart.count,
              isPrinting: printerState.isPrinting,
              onPrint: () => _printMultiSorteo(context, ref, widget.game, cart),
            ),
    );
  }

  Widget _buildGroupedList(
    MultiSorteoCartState cart,
    MultiSorteoCartController controller,
  ) {
    final sorted = cart.bets.asMap().entries.toList()
      ..sort((a, b) => a.value.subGameName.compareTo(b.value.subGameName));

    final children = <Widget>[];
    String? current;
    for (final entry in sorted) {
      final bet = entry.value;
      if (bet.subGameName != current) {
        current = bet.subGameName;
        children.add(_GroupHeader(name: bet.subGameName));
      } else {
        children.add(const Divider(height: 1));
      }
      children.add(MultiSorteoBetTile(
        bet: bet,
        onRemove: () => controller.removeAt(entry.key),
      ));
    }
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 4),
      children: children,
    );
  }

  Widget _buildForm(MultiSorteoCartController controller, Game sub) {
    final key = ValueKey('multi-form-${sub.id}');

    if (sub.type == GameType.date) {
      return QuickDateBetForm(
        key: key,
        clientController: _sharedClientCtrl,
        onSubmit: ({
          required int day,
          required int month,
          required int amount,
          String? client,
        }) =>
            controller.addDate(
          subGameId: sub.id,
          subGameName: sub.name,
          day: day,
          month: month,
          amount: amount,
          client: client,
        ),
      );
    }
    if (sub.type == GameType.threeDigit) {
      return QuickGana3BetForm(
        key: key,
        clientController: _sharedClientCtrl,
        onSubmit: ({
          required int number,
          required int amount,
          required bool isExact,
          String? client,
        }) =>
            controller.addGana3(
          subGameId: sub.id,
          subGameName: sub.name,
          number: number,
          amount: amount,
          isExact: isExact,
          client: client,
        ),
      );
    }
    if (sub.type == GameType.fourDigit) {
      return QuickComboBetForm(
        key: key,
        clientController: _sharedClientCtrl,
        onSubmit: ({
          required int number,
          required int amount,
          String? client,
        }) =>
            controller.addCombo(
          subGameId: sub.id,
          subGameName: sub.name,
          number: number,
          amount: amount,
          client: client,
        ),
      );
    }
    return QuickBetForm(
      key: key,
      clientController: _sharedClientCtrl,
      onSubmit: ({
        required int number,
        required int amount,
        String? client,
      }) =>
          controller.addRegular(
        subGameId: sub.id,
        subGameName: sub.name,
        number: number,
        amount: amount,
        client: client,
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
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Registrar línea',
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              showDragHandle: true,
              builder: (_) => ComboLineForm(
                onSubmit: (r) => controller.addRange(
                  start: r.start,
                  end: r.end,
                  amount: r.amount,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.casino_outlined),
            tooltip: 'Registrar aleatorio',
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              showDragHandle: true,
              builder: (_) => ComboRandomForm(
                onSubmit: (r) =>
                    controller.addRandom(count: r.count, amount: r.amount),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Escanear boleto',
            onPressed: () => context.push('/juegos/${game.id}/escanear', extra: game),
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
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Registrar línea',
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              showDragHandle: true,
              builder: (_) => Gana3LineForm(
                onSubmit: (r) => controller.addRange(
                  start: r.start,
                  end: r.end,
                  amount: r.amount,
                  isExact: r.isExact,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.casino_outlined),
            tooltip: 'Registrar aleatorio',
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              showDragHandle: true,
              builder: (_) => Gana3RandomForm(
                onSubmit: (r) => controller.addRandom(
                  count: r.count,
                  amount: r.amount,
                  isExact: r.isExact,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Escanear boleto',
            onPressed: () => context.push('/juegos/${game.id}/escanear', extra: game),
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
  final lines = cart.bets
      .map((b) => (
            label: b.numberLabel,
            amount: b.amount,
            prize: b.prize,
            subGameId: null as String?,
            subGameName: null as String?,
          ))
      .toList();

  await _persistAndPrint(
    context,
    ref,
    game: game,
    client: cart.client,
    lines: lines,
    buildPayload: (receipt) => TicketPayload(
      id: receipt.id,
      gameId: game.id,
      gameSlug: game.slug,
      gameName: game.name,
      lines: cart.bets
          .map((b) => TicketLine(
                number: b.numberLabel,
                amount: b.amount,
                prize: b.prize,
              ))
          .toList(),
      folio: receipt.folio,
      date: DateTime.now(),
      drawAt: receipt.drawAt,
      seller: ref.read(currentUserProvider)?.name,
      client: cart.client,
    ),
    onSuccess: () =>
        ref.read(cartControllerProvider(game.id).notifier).clear(),
  );
}

Future<void> _printMultiSorteo(
  BuildContext context,
  WidgetRef ref,
  Game game,
  MultiSorteoCartState cart,
) async {
  final sorted = [...cart.bets]
    ..sort((a, b) => a.subGameName.compareTo(b.subGameName));
  final lines = sorted
      .map((b) => (
            label: b.label,
            amount: b.amount,
            prize: b.prize,
            subGameId: null as String?,
            subGameName: b.subGameName as String?,
          ))
      .toList();

  await _persistAndPrint(
    context,
    ref,
    game: game,
    client: cart.client,
    lines: lines,
    buildPayload: (receipt) => TicketPayload(
      id: receipt.id,
      gameId: game.id,
      gameSlug: game.slug,
      gameName: game.name,
      lines: sorted
          .map((b) => TicketLine(
                number: b.label,
                amount: b.amount,
                prize: b.prize,
                subGameName: b.subGameName,
              ))
          .toList(),
      folio: receipt.folio,
      date: DateTime.now(),
      drawAt: receipt.drawAt,
      seller: ref.read(currentUserProvider)?.name,
      client: cart.client,
    ),
    onSuccess: () =>
        ref.read(multiSorteoCartControllerProvider(game.id).notifier).clear(),
  );
}

Future<void> _printCombo(
  BuildContext context,
  WidgetRef ref,
  Game game,
  ComboCartState cart,
) async {
  final lines = cart.bets
      .map((b) => (
            label: b.numberLabel,
            amount: b.amount,
            prize: b.prize,
            subGameId: null as String?,
            subGameName: null as String?,
          ))
      .toList();

  await _persistAndPrint(
    context,
    ref,
    game: game,
    client: cart.client,
    lines: lines,
    buildPayload: (receipt) => TicketPayload(
      id: receipt.id,
      gameId: game.id,
      gameSlug: game.slug,
      gameName: game.name,
      lines: cart.bets
          .map((b) => TicketLine(
                number: b.numberLabel,
                amount: b.amount,
                prize: b.prize,
              ))
          .toList(),
      folio: receipt.folio,
      date: DateTime.now(),
      drawAt: receipt.drawAt,
      seller: ref.read(currentUserProvider)?.name,
      client: cart.client,
    ),
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
  final lines = cart.bets
      .map((b) => (
            label: b.isExact ? b.numberLabel : '${b.numberLabel} (F)',
            amount: b.amount,
            prize: b.prize,
            subGameId: null as String?,
            subGameName: null as String?,
          ))
      .toList();

  await _persistAndPrint(
    context,
    ref,
    game: game,
    client: cart.client,
    lines: lines,
    buildPayload: (receipt) => TicketPayload(
      id: receipt.id,
      gameId: game.id,
      gameSlug: game.slug,
      gameName: game.name,
      lines: cart.bets
          .map((b) => TicketLine(
                number: b.isExact ? b.numberLabel : '${b.numberLabel} (F)',
                amount: b.amount,
                prize: b.prize,
              ))
          .toList(),
      folio: receipt.folio,
      date: DateTime.now(),
      drawAt: receipt.drawAt,
      seller: ref.read(currentUserProvider)?.name,
      client: cart.client,
    ),
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
  final lines = cart.bets
      .map((b) => (
            label: b.label,
            amount: b.amount,
            prize: b.prize,
            subGameId: null as String?,
            subGameName: null as String?,
          ))
      .toList();

  await _persistAndPrint(
    context,
    ref,
    game: game,
    client: cart.client,
    lines: lines,
    buildPayload: (receipt) => TicketPayload(
      id: receipt.id,
      gameId: game.id,
      gameSlug: game.slug,
      gameName: game.name,
      lines: cart.bets
          .map((b) => TicketLine(
                number: b.label,
                amount: b.amount,
                prize: b.prize,
              ))
          .toList(),
      folio: receipt.folio,
      date: DateTime.now(),
      drawAt: receipt.drawAt,
      seller: ref.read(currentUserProvider)?.name,
      client: cart.client,
    ),
    onSuccess: () =>
        ref.read(dateCartControllerProvider(game.id).notifier).clear(),
  );
}

typedef _RequestLine = ({
  String label,
  int amount,
  int prize,
  String? subGameId,
  String? subGameName,
});

Future<void> _persistAndPrint(
  BuildContext context,
  WidgetRef ref, {
  required Game game,
  required String? client,
  required List<_RequestLine> lines,
  required TicketPayload Function(TicketReceipt) buildPayload,
  required VoidCallback onSuccess,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final printer = ref.read(printerControllerProvider);
  final salePoint = ref.read(activeSalePointProvider).selected;

  if (salePoint == null) {
    messenger.showSnackBar(const SnackBar(
      content: Text('No hay puesto de venta activo.'),
    ));
    return;
  }
  if (!printer.isConnected) {
    messenger.showSnackBar(const SnackBar(
      content: Text(
        'No hay impresora conectada. Ve a Configuración → Impresora.',
      ),
    ));
    return;
  }

  final request = CreateTicketRequest(
    gameId: game.id,
    salePointId: salePoint.id,
    client: client,
    lines: lines
        .map((l) => CreateTicketLine(
              label: l.label,
              amount: l.amount,
              prize: l.prize,
              subGameId: l.subGameId,
              subGameName: l.subGameName,
            ))
        .toList(),
  );

  final result = await getIt<CreateTicket>().call(request);
  final receipt = result.fold<TicketReceipt?>(
    (failure) {
      messenger.showSnackBar(SnackBar(
        content: Text('No se pudo registrar el ticket: ${failure.message}'),
      ));
      return null;
    },
    (r) => r,
  );
  if (receipt == null) return;

  final payload = buildPayload(receipt);
  await ref.read(printerControllerProvider.notifier).printTicket(payload);
  final after = ref.read(printerControllerProvider);
  if (after.errorMessage != null) {
    messenger.showSnackBar(SnackBar(
      content: Text('Ticket #${receipt.folio} registrado, pero falló la '
          'impresión: ${after.errorMessage}'),
    ));
    return;
  }

  onSuccess();
  final drawTime = formatTime12h(receipt.drawAt);
  messenger.showSnackBar(SnackBar(
    content: Text('Ticket #${receipt.folio} — Sorteo $drawTime'),
  ));
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        name.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.black54,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
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
