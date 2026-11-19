import 'package:barrber_figma/controllers/estado_aplicacion.dart';
import 'package:barrber_figma/widgets/tarjeta.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:barrber_figma/routes/routes.dart';
import 'package:barrber_figma/theme/tema_aplicacion.dart';
import 'package:barrber_figma/widgets/tarjeta_gestion.dart';
import 'package:barrber_figma/widgets/resumen_agenda.dart';

void main() {
  testWidgets('Clientes busca por nombre sin tildes y por documento', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: TemaAplicacion.claro,
        routes: Rutas.pantallas,
        initialRoute: '/clientes',
      ),
    );
    await tester.pumpAndSettle();
    final campo = find.byType(TextField);
    await tester.enterText(campo, '  ANDRES  ');
    await tester.pump();
    expect(
      find.widgetWithText(TarjetaGestion, 'Andrés Mendoza'),
      findsOneWidget,
    );
    expect(find.widgetWithText(TarjetaGestion, 'Juan Pérez'), findsNothing);
    await tester.enterText(campo, '1076543210');
    await tester.pump();
    expect(
      find.widgetWithText(TarjetaGestion, 'Andrés Mendoza'),
      findsOneWidget,
    );
    await tester.enterText(campo, '315222');
    await tester.pump();
    expect(
      find.widgetWithText(TarjetaGestion, 'Andrés Mendoza'),
      findsOneWidget,
    );
    await tester.enterText(campo, 'inexistente');
    await tester.pump();
    expect(find.textContaining('No encontramos resultados'), findsOneWidget);
    await tester.enterText(campo, '');
    await tester.pump();
    expect(find.byType(TarjetaGestion), findsNWidgets(4));
  });

  testWidgets(
    'Resumen actualiza estados e incluye reservas de próximas fechas',
    (tester) async {
      EstadoAplicacion.reiniciar(fecha: DateTime(2026, 11, 18));
      addTearDown(EstadoAplicacion.reiniciar);
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ResumenAgenda())),
      );
      String contador(String etiqueta) {
        final tarjeta = find.ancestor(
          of: find.text(etiqueta),
          matching: find.byType(Tarjeta),
        );
        return tester
            .widgetList<Text>(
              find.descendant(of: tarjeta, matching: find.byType(Text)),
            )
            .first
            .data!;
      }

      final pendiente = EstadoAplicacion.repositorio.reservas.firstWhere(
        (reserva) => reserva.estado == 'Programada',
      );
      expect(contador('Pendientes'), '1');
      expect(contador('Atendidos'), '1');
      await EstadoAplicacion.repositorio.guardarReserva(
        pendiente.copiar(estado: 'Atendida'),
      );
      await tester.pump();
      expect(contador('Pendientes'), '0');
      expect(contador('Atendidos'), '2');
      final futuro = pendiente.copiar(
        id: 'futura',
        fecha: DateTime(2026, 11, 19),
      );
      await EstadoAplicacion.repositorio.guardarReserva(futuro);
      await tester.pump();
      expect(contador('Reservas'), '4');
      expect(contador('Pendientes'), '1');
    },
  );

  for (final ancho in [280.0, 320.0, 360.0, 412.0, 720.0]) {
    for (final escala in [1.0, 1.3, 2.0]) {
      testWidgets('Resumen completo a $ancho px y escala $escala', (
        tester,
      ) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(ancho, 1200);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
        await tester.pumpWidget(
          MaterialApp(
            theme: TemaAplicacion.claro,
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(escala)),
              child: const Scaffold(
                body: Padding(
                  padding: EdgeInsets.all(20),
                  child: ResumenAgenda(),
                ),
              ),
            ),
          ),
        );
        for (final nombre in ['Reservas', 'Pendientes', 'Atendidos']) {
          final parrafo = tester.renderObject<RenderParagraph>(
            find.text(nombre),
          );
          expect(parrafo.didExceedMaxLines, isFalse);
          expect(
            parrafo
                .getBoxesForSelection(
                  TextSelection(baseOffset: 0, extentOffset: nombre.length),
                )
                .map((caja) => caja.top)
                .toSet()
                .length,
            1,
          );
        }
        expect(tester.takeException(), isNull);
      });
    }
  }
}
