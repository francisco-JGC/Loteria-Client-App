import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/di/injection.dart';
import 'core/navigation/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/printer/presentation/state/printer_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env').catchError((_) {});
  await configureDependencies();

  runApp(const ProviderScope(child: LoteriaClientApp()));
}

class LoteriaClientApp extends ConsumerStatefulWidget {
  const LoteriaClientApp({super.key});

  @override
  ConsumerState<LoteriaClientApp> createState() => _LoteriaClientAppState();
}

class _LoteriaClientAppState extends ConsumerState<LoteriaClientApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(printerControllerProvider.notifier).autoReconnect();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Lotería',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light,
      routerConfig: router,
    );
  }
}
