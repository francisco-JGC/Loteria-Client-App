import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/time_format.dart';
import '../../../games/domain/entities/game.dart';
import '../../../games/presentation/state/games_controller.dart';
import '../../domain/entities/draw_result.dart';
import '../state/latest_results_controller.dart';

class LatestResultsPage extends ConsumerWidget {
  const LatestResultsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(latestResultsControllerProvider);
    final games = ref.watch(gamesControllerProvider).value ?? const [];
    final gamesById = {for (final g in games) g.id: g};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Últimos Resultados'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refrescar',
            onPressed: () => ref
                .read(latestResultsControllerProvider.notifier)
                .refresh(),
          ),
        ],
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => _ErrorView(
          message: err.toString(),
          onRetry: () => ref
              .read(latestResultsControllerProvider.notifier)
              .refresh(),
        ),
        data: (items) => items.isEmpty
            ? const _EmptyView()
            : RefreshIndicator(
                onRefresh: () => ref
                    .read(latestResultsControllerProvider.notifier)
                    .refresh(),
                child: _groupByDate(items, gamesById),
              ),
      ),
    );
  }

  Widget _groupByDate(
    List<DrawResult> items,
    Map<String, Game> gamesById,
  ) {
    final groups = <String, List<DrawResult>>{};
    final dateKey = DateFormat('yyyy-MM-dd');
    for (final r in items) {
      final key = dateKey.format(r.drawAt.toLocal());
      groups.putIfAbsent(key, () => []).add(r);
    }
    final orderedKeys = groups.keys.toList()..sort((a, b) => b.compareTo(a));
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: orderedKeys.length,
      itemBuilder: (context, i) {
        final key = orderedKeys[i];
        final dayLabel = _humanDay(DateTime.parse(key));
        final rows = [...groups[key]!]
          ..sort((a, b) => b.drawAt.compareTo(a.drawAt));
        return _DayGroup(dayLabel: dayLabel, results: rows, gamesById: gamesById);
      },
    );
  }

  String _humanDay(DateTime d) {
    final today = DateTime.now();
    final t = DateTime(today.year, today.month, today.day);
    final target = DateTime(d.year, d.month, d.day);
    final diff = target.difference(t).inDays;
    if (diff == 0) return 'Hoy';
    if (diff == -1) return 'Ayer';
    return DateFormat('EEEE d MMM', 'es').format(d);
  }
}

class _DayGroup extends StatelessWidget {
  const _DayGroup({
    required this.dayLabel,
    required this.results,
    required this.gamesById,
  });

  final String dayLabel;
  final List<DrawResult> results;
  final Map<String, Game> gamesById;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            dayLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        for (final r in results)
          Card(
            child: ListTile(
              title: Text(gamesById[r.gameId]?.name ?? '—'),
              subtitle: Text('Sorteo ${formatTime12h(r.drawAt)}'),
              trailing: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  r.winningNumber,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
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
            Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aún no hay resultados registrados',
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
