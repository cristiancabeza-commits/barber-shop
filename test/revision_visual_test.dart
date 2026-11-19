import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:barrber_figma/routes/routes.dart';
import 'package:barrber_figma/controllers/estado_aplicacion.dart';
import 'package:barrber_figma/widgets/selector_busqueda.dart';
import 'package:barrber_figma/theme/tema_aplicacion.dart';

void main() {
  setUp(() => EstadoAplicacion.reiniciar(fecha: DateTime(2026, 10, 24)));
  setUpAll(() async {
    for (final name in ['Inter', 'Gabarito']) {
      final loader = FontLoader(name)
        ..addFont(rootBundle.load('assets/fonts/$name.ttf'));
      await loader.load();
    }
    final iconos = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await iconos.load();
  });
  for (final claro in [false, true]) {
    for (final ruta in [
      '/inicio-principal',
      '/especialidades',
      '/nueva-reserva',
    ]) {
      testWidgets('Revisión visual $ruta $claro', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(390, 844);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        await tester.pumpWidget(
          MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: claro ? TemaAplicacion.claro : TemaAplicacion.oscuro,
            initialRoute: ruta,
            routes: Rutas.pantallas,
          ),
        );
        await tester.runAsync(
          () => precacheImage(
            const AssetImage('assets/images/logo.png'),
            tester.element(find.byType(MaterialApp)),
          ),
        );
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(MaterialApp),
          matchesGoldenFile(
            '../referencias/revision_visual/${ruta.substring(1)}_${claro ? "claro" : "oscuro"}.png',
          ),
        );
      });
    }
  }
  testWidgets('Selector de clientes con búsqueda y documento', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: TemaAplicacion.claro,
        routes: Rutas.pantallas,
        initialRoute: '/nueva-reserva',
      ),
    );
    await tester.pumpAndSettle();
    final selector = find.byWidgetPredicate(
      (w) => w is SelectorBusqueda && w.etiqueta == 'Cliente *',
    );
    await tester.tap(selector);
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile(
        '../referencias/revision_visual/selector_clientes_claro.png',
      ),
    );
  });
}
