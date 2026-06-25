import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutterererere/main.dart';

void main() {
  testWidgets('muestra login antes del panel administrador', (tester) async {
    await tester.pumpWidget(const CasaJardinApp());

    expect(find.text('Iniciar Sesión'), findsWidgets);
    expect(find.text('Panel administrador'), findsNothing);

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('Panel administrador'), findsOneWidget);
    expect(find.text('Reservas'), findsOneWidget);
    expect(find.text('Usuarios'), findsOneWidget);
    expect(find.text('Actividad'), findsOneWidget);
  });
}
