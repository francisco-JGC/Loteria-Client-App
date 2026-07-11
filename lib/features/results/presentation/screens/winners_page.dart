import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/currency.dart';
import '../../../../core/utils/time_format.dart';
import '../../../games/domain/entities/game.dart';
import '../../../games/presentation/state/games_controller.dart';
import '../../domain/entities/winning_ticket.dart';
import '../state/winners_controller.dart';

class WinnersPage extends ConsumerWidget {
  const WinnersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(winnersControllerProvider);
    final games = ref.watch(gamesControllerProvider).value ?? const [];
    final gamesById = {for (final g in games) g.id: g};
    final filters = ref.watch(winnersFiltersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Boletos ganadores'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refrescar',
            onPressed: () =>
                ref.read(winnersControllerProvider.notifier).refresh(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Verificar boleto'),
        onPressed: () =>
            context.push('/reportes/boletos-ganadores/verificar'),
      ),
      bottomNavigationBar: _TotalsBar(tickets: state.value ?? const []),
      body: Column(
        children: [
          _DateRangeBar(filters: filters),
          const Divider(height: 1),
          Expanded(
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => _ErrorView(
                message: err.toString(),
                onRetry: () =>
                    ref.read(winnersControllerProvider.notifier).refresh(),
              ),
              data: (items) => items.isEmpty
                  ? const _EmptyView()
                  : RefreshIndicator(
                      onRefresh: () => ref
                          .read(winnersControllerProvider.notifier)
                          .refresh(),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, i) => _WinnerTile(
                          ticket: items[i],
                          game: gamesById[items[i].gameId],
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateRangeBar extends ConsumerWidget {
  const _DateRangeBar({required this.filters});

  final WinnersFilters filters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = _rangeLabel(filters);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.date_range, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextButton(
              style: TextButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.zero,
              ),
              onPressed: () => _pickRange(context, ref),
              child: Text(label),
            ),
          ),
        ],
      ),
    );
  }

  String _rangeLabel(WinnersFilters f) {
    final fmt = DateFormat('dd/MM/yyyy');
    if (f.from == null && f.to == null) return 'Sin filtro';
    final from = f.from == null ? '—' : fmt.format(f.from!);
    final to = f.to == null ? '—' : fmt.format(f.to!);
    return 'Del $from al $to';
  }

  Future<void> _pickRange(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final initial = DateTimeRange(
      start: filters.from ?? now.subtract(const Duration(days: 3)),
      end: filters.to ?? now,
    );
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      initialDateRange: initial,
    );
    if (picked == null) return;
    ref.read(winnersFiltersProvider.notifier).set(
          from: picked.start,
          to: DateTime(
            picked.end.year,
            picked.end.month,
            picked.end.day,
            23,
            59,
            59,
          ),
        );
  }
}

class _TotalsBar extends StatelessWidget {
  const _TotalsBar({required this.tickets});

  final List<WinningTicket> tickets;

  @override
  Widget build(BuildContext context) {
    var totalWon = 0;
    var totalPaid = 0;
    for (final t in tickets) {
      totalWon += t.totalPrize;
      if (t.isPaid) totalPaid += t.paidPrize;
    }
    final pending = totalWon - totalPaid;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: _TotalCell(
                label: 'Pendiente',
                value: pending,
                color: Colors.orange.shade800,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TotalCell(
                label: 'Pagado',
                value: totalPaid,
                color: Colors.green.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalCell extends StatelessWidget {
  const _TotalCell({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
        ),
        Text(
          kCurrencyFormat.format(value),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _WinnerTile extends ConsumerWidget {
  const _WinnerTile({required this.ticket, required this.game});

  final WinningTicket ticket;
  final Game? game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateFmt = DateFormat('dd/MM/yyyy');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    game?.name ?? '—',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (ticket.isPaid)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Text(
                      'Pagado',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.green.shade800,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Text(
                      kCurrencyFormat.format(ticket.totalPrize),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.orange.shade800,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '#${ticket.folio}',
              style:
                  theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              'Sorteo: ${dateFmt.format(ticket.drawAt.toLocal())} '
              '${formatTime12h(ticket.drawAt)}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.grey.shade700),
            ),
            if (ticket.client != null && ticket.client!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Cliente: ${ticket.client}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: Colors.grey.shade700),
              ),
            ],
            const SizedBox(height: 8),
            for (final line in ticket.lines.where((l) => l.isWinner))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        size: 16, color: Colors.green.shade600),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        [
                          if (line.subGameName != null)
                            '${line.subGameName} — ',
                          line.label,
                          ' → ganador ${line.winningNumber ?? ''}',
                        ].join(),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      kCurrencyFormat.format(line.wonPrize),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            if (!ticket.isPaid) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.payments_outlined),
                  label: Text(
                      'Pagar ${kCurrencyFormat.format(ticket.totalPrize)}'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                  ),
                  onPressed: () => _confirmPay(context, ref, ticket),
                ),
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                'Pagado el ${DateFormat('dd/MM').format(ticket.paidAt!.toLocal())} '
                '${formatTime12h(ticket.paidAt!)}',
                style: TextStyle(
                  color: Colors.green.shade800,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<void> _confirmPay(
  BuildContext context,
  WidgetRef ref,
  WinningTicket ticket,
) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Pagar #${ticket.folio}'),
      content: Text(
        '¿Confirmas el pago de ${kCurrencyFormat.format(ticket.totalPrize)}?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Pagar'),
        ),
      ],
    ),
  );
  if (ok != true) return;
  final either =
      await ref.read(winnersControllerProvider.notifier).pay(ticket.id);
  if (!context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  either.match(
    (failure) => messenger.showSnackBar(
      SnackBar(content: Text('No se pudo pagar: ${failure.message}')),
    ),
    (_) => messenger.showSnackBar(
      SnackBar(content: Text('Ticket #${ticket.folio} pagado')),
    ),
  );
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Sin boletos ganadores en este rango',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
