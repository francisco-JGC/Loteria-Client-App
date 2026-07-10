import 'package:go_router/go_router.dart';

import '../../features/games/domain/entities/game.dart';
import '../../features/games/presentation/screens/game_detail_page.dart';
import '../../features/games/presentation/screens/games_page.dart';
import '../../features/printer/presentation/screens/printer_setup_page.dart';
import '../../features/settings/presentation/screens/settings_page.dart';
import '../widgets/placeholder_page.dart';
import 'app_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/juegos',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/juegos',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: GamesPage(),
          ),
        ),
        GoRoute(
          path: '/reportes/facturas',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: PlaceholderPage(title: 'Facturas'),
          ),
        ),
        GoRoute(
          path: '/reportes/totales-sorteos',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: PlaceholderPage(title: 'Totales Sorteos'),
          ),
        ),
        GoRoute(
          path: '/reportes/boletos-ganadores',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: PlaceholderPage(title: 'Boletos Ganadores'),
          ),
        ),
        GoRoute(
          path: '/reportes/ultimos-resultados',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: PlaceholderPage(title: 'Últimos Resultados'),
          ),
        ),
        GoRoute(
          path: '/reportes/movimientos',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: PlaceholderPage(title: 'Movimientos'),
          ),
        ),
        GoRoute(
          path: '/herramientas/guia-suenos',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: PlaceholderPage(title: 'Guía de Sueños'),
          ),
        ),
        GoRoute(
          path: '/herramientas/cruz-suerte',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: PlaceholderPage(title: 'Cruz de la Suerte'),
          ),
        ),
        GoRoute(
          path: '/herramientas/piramide-suerte',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: PlaceholderPage(title: 'Pirámide de la Suerte'),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/juegos/:gameId',
      builder: (context, state) => GameDetailPage(
        gameId: state.pathParameters['gameId']!,
        game: state.extra as Game?,
      ),
    ),
    GoRoute(
      path: '/configuracion',
      builder: (context, state) => const SettingsPage(),
      routes: [
        GoRoute(
          path: 'impresora',
          builder: (context, state) => const PrinterSetupPage(),
        ),
      ],
    ),
  ],
);
