import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_page.dart';
import '../../features/auth/presentation/screens/splash_page.dart';
import '../../features/auth/presentation/state/auth_controller.dart';
import '../../features/auth/presentation/state/auth_state.dart';
import '../../features/games/domain/entities/game.dart';
import '../../features/games/presentation/screens/game_detail_page.dart';
import '../../features/games/presentation/screens/games_page.dart';
import '../../features/printer/presentation/screens/printer_setup_page.dart';
import '../../features/sales/presentation/screens/scan_ticket_page.dart';
import '../../features/settings/presentation/screens/settings_page.dart';
import '../widgets/placeholder_page.dart';
import 'app_shell.dart';

class _AuthRouterListenable extends ChangeNotifier {
  _AuthRouterListenable(Ref ref) {
    _sub = ref.listen<AuthState>(
      authControllerProvider,
      (previous, next) {
        if (previous?.status != next.status) notifyListeners();
      },
    );
  }

  late final ProviderSubscription<AuthState> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final listenable = _AuthRouterListenable(ref);
  ref.onDispose(listenable.dispose);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: listenable,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final location = state.matchedLocation;

      if (auth.isLoading) {
        return location == '/splash' ? null : '/splash';
      }
      if (auth.isUnauthenticated) {
        return location == '/login' ? null : '/login';
      }
      if (location == '/splash' || location == '/login') {
        return '/juegos';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
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
        routes: [
          GoRoute(
            path: 'escanear',
            builder: (context, state) => ScanTicketPage(
              gameId: state.pathParameters['gameId']!,
            ),
          ),
        ],
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
});
