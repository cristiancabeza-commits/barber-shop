import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:barrber_figma/routes/routes.dart';
import 'package:barrber_figma/theme/tema_aplicacion.dart';
import 'package:barrber_figma/widgets/barra_inferior.dart';

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
      testWidgets('Vista ${entry.key} ${claro ? "clara" : "oscura"}', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(430, 1000);
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final originalHandler = FlutterError.onError;
        FlutterError.onError = (details) {
          FlutterError.dumpErrorToConsole(details, forceReport: true);
          originalHandler!(details);
        };
        await tester.pumpWidget(
          MaterialApp(
            theme: claro ? TemaAplicacion.claro : TemaAplicacion.oscuro,
            routes: Rutas.pantallas,
            home: Builder(builder: entry.value),
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));
        FlutterError.onError = originalHandler;
        expect(tester.takeException(), isNull, reason: entry.key);
        expect(find.text('9:41'), findsNothing);
        expect(find.byIcon(Icons.battery_full), findsNothing);
        final cabecera = find.byType(AppBar);
        if (cabecera.evaluate().isNotEmpty) {
          final antes = tester.getRect(cabecera);
          final scroll = find.byType(Scrollable);
          if (scroll.evaluate().isNotEmpty) {
            await tester.drag(scroll.first, const Offset(0, -180));
            await tester.pump();
            expect(
              tester.getRect(cabecera),
              antes,
              reason: 'La cabecera permanece fija: ${entry.key}',
            );
          }
        }
        if (find.byType(BarraInferior).evaluate().isNotEmpty) {
          final barra = tester.getRect(find.byType(BarraInferior));
          expect(
            barra.bottom,
            closeTo(1000, 1),
            reason: 'Barra al pie: ${entry.key}',
          );
          expect(barra.top, greaterThan(900));
          expect(
            find.descendant(
              of: find.byType(BarraInferior),
              matching: find.text('Inicio'),
            ),
            findsOneWidget,
          );
        }
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
}
