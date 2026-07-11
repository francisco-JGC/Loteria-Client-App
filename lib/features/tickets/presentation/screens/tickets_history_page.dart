import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/currency.dart';
import '../../../../core/utils/time_format.dart';
import '../../../games/domain/entities/game.dart';
import '../../../games/presentation/state/games_controller.dart';
import '../../domain/entities/ticket_summary.dart';
import '../state/tickets_history_controller.dart';

class TicketsHistoryPage extends ConsumerWidget {
  const TicketsHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ticketsHistoryControllerProvider);
    final games = ref.watch(gamesControllerProvider).value ?? const [];
    final gamesById = {for (final g in games) g.id: g};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis boletos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refrescar',
            onPressed: () =>
                ref.read(ticketsHistoryControllerProvider.notifier).refresh(),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _ErrorView(
          message: err.toString(),
          onRetry: () =>
              ref.read(ticketsHistoryControllerProvider.notifier).refresh(),
        ),
        data: (tickets) => tickets.isEmpty
            ? const _EmptyView()
            : RefreshIndicator(
                onRefresh: () => ref
                    .read(ticketsHistoryControllerProvider.notifier)
                    .refresh(),
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: tickets.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _TicketTile(
                    ticket: tickets[i],
                    game: gamesById[tickets[i].gameId],
                  ),
                ),
              ),
      ),
    );
  }
}

class _TicketTile extends ConsumerWidget {
  const _TicketTile({required this.ticket, required this.game});

  final TicketSummary ticket;
  final Game? game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final saleDateFmt = DateFormat('dd/MM');
    final gameName = game?.name ?? '—';

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/reportes/facturas/${ticket.id}'),
        child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    gameName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _StatusChip(status: ticket.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '#${ticket.folio}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _MetaLine(
                  icon: Icons.shopping_cart_outlined,
                  label:
                      '${saleDateFmt.format(ticket.createdAt.toLocal())} · '
                      '${formatTime12h(ticket.createdAt)}',
                ),
                const SizedBox(width: 16),
                _MetaLine(
                  icon: Icons.event_outlined,
                  label: 'Sorteo ${formatTime12h(ticket.drawAt)}',
                ),
              ],
            ),
            if (ticket.client != null && ticket.client!.isNotEmpty) ...[
              const SizedBox(height: 4),
              _MetaLine(
                icon: Icons.person_outline,
                label: ticket.client!,
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '${ticket.count} números',
                  style: theme.textTheme.bodyMedium,
                ),
                const Spacer(),
                Text(
                  kCurrencyFormat.format(ticket.total),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (!ticket.isVoided) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text('Anular'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                  onPressed: () => _confirmVoid(context, ref, ticket),
                ),
              ),
            ],
            if (ticket.isVoided && ticket.voidedReason != null) ...[
              const SizedBox(height: 4),
              Text(
                'Motivo: ${ticket.voidedReason}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: Colors.grey.shade700),
              ),
            ],
          ],
        ),
        ),
      ),
    );
  }
}

Future<void> _confirmVoid(
  BuildContext context,
  WidgetRef ref,
  TicketSummary ticket,
) async {
  final reasonCtrl = TextEditingController();
  final result = await showDialog<String?>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text('Anular #${ticket.folio}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Escribe el motivo de la anulación:'),
          const SizedBox(height: 8),
          TextField(
            controller: reasonCtrl,
            autofocus: true,
            maxLength: 200,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Ej: error del cliente',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(null),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(dialogContext).pop(reasonCtrl.text.trim()),
          child: const Text('Anular'),
        ),
      ],
    ),
  );

  if (result == null || result.isEmpty) return;

  final either = await ref
      .read(ticketsHistoryControllerProvider.notifier)
      .voidTicket(id: ticket.id, reason: result);
  if (!context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  either.match(
    (failure) => messenger.showSnackBar(
      SnackBar(content: Text('No se pudo anular: ${failure.message}')),
    ),
    (_) => messenger.showSnackBar(
      SnackBar(content: Text('Ticket #${ticket.folio} anulado')),
    ),
  );
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final TicketStatus status;

  @override
  Widget build(BuildContext context) {
    final isVoided = status == TicketStatus.voided;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:
            isVoided ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isVoided ? Colors.red.shade200 : Colors.green.shade200,
        ),
      ),
      child: Text(
        isVoided ? 'Anulado' : 'Válido',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isVoided ? Colors.red.shade700 : Colors.green.shade700,
        ),
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
      ],
    );
  }
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
            Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aún no tienes boletos en este puesto',
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
