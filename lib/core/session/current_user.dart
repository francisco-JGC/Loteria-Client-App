import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrentUser {
  const CurrentUser({required this.name, required this.role});

  final String name;
  final String role;
}

final currentUserProvider = Provider<CurrentUser>((ref) {
  return const CurrentUser(name: 'Francisco 1', role: 'Vendedor');
});
