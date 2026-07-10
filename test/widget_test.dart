import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:loteria_client_app/main.dart';

void main() {
  testWidgets('app boots into Juegos route with drawer available',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: LoteriaClientApp()),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Juegos'), findsWidgets);
    expect(find.byIcon(Icons.menu), findsOneWidget);
  });

  testWidgets('drawer opens and shows user + groups', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: LoteriaClientApp()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.text('Francisco 1'), findsOneWidget);
    expect(find.text('Vendedor'), findsOneWidget);
    expect(find.text('Reportes'), findsOneWidget);
    expect(find.text('Herramientas'), findsOneWidget);
    expect(find.text('Facturas'), findsOneWidget);
    expect(find.text('Guía de Sueños'), findsOneWidget);
  });
}
