import 'package:flutter/material.dart';

import '../../domain/entities/game.dart';

class GameDetailPage extends StatelessWidget {
  const GameDetailPage({required this.gameId, this.game, super.key});

  final String gameId;
  final Game? game;

  @override
  Widget build(BuildContext context) {
    final resolved = game;
    return Scaffold(
      appBar: AppBar(title: Text(resolved?.name ?? 'Juego')),
      body: resolved == null ? _NotFound(gameId: gameId) : _Placeholder(game: resolved),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.game});

  final Game game;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.videogame_asset, size: 80, color: Colors.black26),
            const SizedBox(height: 16),
            Text(
              game.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'id: ${game.id}',
              style: const TextStyle(color: Colors.black45),
            ),
            const SizedBox(height: 24),
            const Text(
              'Aquí va el flujo de venta del juego.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black45),
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
