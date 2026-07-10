import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_drawer.dart';
import 'nav_items.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.child, super.key});

  final Widget child;

  String _titleFor(String route) {
    for (final group in kNavGroups) {
      for (final item in group.items) {
        if (item.route == route) return item.label;
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final route = GoRouterState.of(context).uri.toString();
    return Scaffold(
      appBar: AppBar(
        title: Text(_titleFor(route)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Configuración',
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      drawer: const AppDrawer(),
      body: child,
    );
  }
}
