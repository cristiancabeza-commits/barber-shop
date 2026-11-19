import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:barrber_figma/routes/routes.dart';
import 'package:barrber_figma/theme/tema_aplicacion.dart';

void main() {
  setUpAll(() async {
    for (final name in ['Inter', 'Gabarito']) {
      final loader = FontLoader(name)
        ..addFont(rootBundle.load('assets/fonts/$name.ttf'));
      await loader.load();
    }
  });
  for (final claro in [false, true]) {
    for (final entry in Rutas.pantallas.entries) {
      testWidgets('Teléfono pequeño con texto ampliado ${entry.key} $claro', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(320, 640);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        await tester.pumpWidget(
          MaterialApp(
            theme: claro ? TemaAplicacion.claro : TemaAplicacion.oscuro,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.3)),
              child: child!,
            ),
            routes: Rutas.pantallas,
            home: Builder(builder: entry.value),
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));
        expect(tester.takeException(), isNull, reason: entry.key);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
  testWidgets('Buscar cliente filtra los datos de ejemplo', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaAplicacion.claro,
        initialRoute: '/clientes',
        routes: Rutas.pantallas,
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Juan');
    await tester.pump();
    expect(find.text('Juan Pérez'), findsOneWidget);
    expect(find.text('Andrés Mendoza'), findsNothing);
    await tester.enterText(find.byType(TextField).first, 'zzz');
    await tester.pump();
    expect(find.textContaining('No encontramos resultados'), findsOneWidget);
  });
}
