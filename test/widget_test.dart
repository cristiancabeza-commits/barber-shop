import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:barrber_figma/main.dart';
import 'package:barrber_figma/routes/routes.dart';
import 'package:barrber_figma/controllers/estado_aplicacion.dart';
import 'package:barrber_figma/models/datos_barberia.dart';
import 'package:barrber_figma/repositories/repositorio_memoria.dart';
import 'package:barrber_figma/theme/tema_aplicacion.dart';
import 'package:barrber_figma/theme/preferencia_tema.dart';
import 'package:barrber_figma/widgets/selector_busqueda.dart';
import 'package:barrber_figma/widgets/tarjeta_gestion.dart';
import 'package:barrber_figma/widgets/tarjeta_registro.dart';

class RepositorioConError extends RepositorioMemoria {
  @override
  Future<void> guardar(Modulo modulo, Registro registro) async {
    throw StateError('Error simulado de guardado');
  }
}

Future<void> abrir(WidgetTester t, String ruta, {Object? argumentos}) async {
  t.view.devicePixelRatio = 1;
  t.view.physicalSize = const Size(390, 1000);
  addTearDown(t.view.resetDevicePixelRatio);
  addTearDown(t.view.resetPhysicalSize);
  await t.pumpWidget(
    MaterialApp(
      theme: TemaAplicacion.claro,
      routes: Rutas.pantallas,
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () =>
              Navigator.pushNamed(context, ruta, arguments: argumentos),
          child: const Text('Abrir prueba'),
        ),
      ),
    ),
  );
  await t.tap(find.text('Abrir prueba'));
  await t.pumpAndSettle();
}

Future<void> pulsar(WidgetTester t, String texto) async {
  final boton = find.widgetWithText(FilledButton, texto);
  final secundario = find.widgetWithText(OutlinedButton, texto);
  final f = boton.evaluate().isNotEmpty
      ? boton.last
      : secundario.evaluate().isNotEmpty
      ? secundario.last
      : find.text(texto).last;
  await t.ensureVisible(f);
  await t.tap(f);
  await t.pumpAndSettle();
}

Future<void> escribir(WidgetTester t, String etiqueta, String texto) async {
  final f = find.byKey(ValueKey(etiqueta));
  await t.ensureVisible(f);
  await t.enterText(f, texto);
  await t.pump();
}

Future<void> seleccionar(
  WidgetTester t,
  String etiqueta,
  String nombre, {
  String? buscar,
}) async {
  final selector = find.byWidgetPredicate(
    (w) => w is SelectorBusqueda && w.etiqueta == etiqueta,
  );
  await t.ensureVisible(selector);
  await t.tap(selector);
  await t.pumpAndSettle();
  if (buscar != null) {
    await t.enterText(find.byType(TextField).last, buscar);
    await t.pumpAndSettle();
  }
  final opcion = find.widgetWithText(ListTile, nombre).last;
  await t.ensureVisible(opcion);
  await t.tap(opcion);
  await t.pumpAndSettle();
}

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    EstadoAplicacion.reiniciar(fecha: DateTime(2026, 10, 24));
    PreferenciaTema.modo.value = ThemeMode.dark;
  });
  testWidgets('Acceso valida vacíos y credenciales antes de entrar', (t) async {
    await t.pumpWidget(const AplicacionBarberia());
    await t.pump(const Duration(seconds: 2));
    await t.pumpAndSettle();
    await pulsar(t, 'INGRESAR');
    expect(find.text('Este campo es obligatorio'), findsNWidgets(2));
    final cliente = MockClient((peticion) async {
      expect(peticion.url.path, '/api/Sesion');
      final datos = jsonDecode(peticion.body) as Map<String, dynamic>;
      return datos['usuario'] == 'usuario_prueba' &&
              datos['clave'] == 'clave_prueba'
          ? http.Response('{"accessToken":"token_prueba"}', 200)
          : http.Response('{}', 401);
    });
    await escribir(t, 'Usuario', 'incorrecto');
    await t.enterText(find.byType(TextFormField).last, 'clave');
    await http.runWithClient(() => pulsar(t, 'INGRESAR'), () => cliente);
    expect(find.text('Usuario o contraseña incorrectos'), findsOneWidget);
    await escribir(t, 'Usuario', 'usuario_prueba');
    await t.enterText(find.byType(TextFormField).last, 'clave_prueba');
    await http.runWithClient(() => pulsar(t, 'INGRESAR'), () => cliente);
    expect(find.text('Hola, Admin'), findsOneWidget);
    await t.pumpWidget(const SizedBox());
    await abrir(t, '/inicio-sesion');
    final campos = t
        .widgetList<TextFormField>(find.byType(TextFormField))
        .toList();
    expect(campos.first.controller!.text, 'usuario_prueba');
    expect(campos.last.controller!.text, 'clave_prueba');
    final enlace = find.text('¿Olvidaste tu contraseña?');
    expect(
      t
          .widget<Align>(
            find.ancestor(of: enlace, matching: find.byType(Align)).first,
          )
          .alignment,
      Alignment.center,
    );
  });
  testWidgets('Cliente nuevo valida, guarda y aparece al buscar documento', (
    t,
  ) async {
    await abrir(t, '/clientes');
    await t.tap(find.byIcon(Icons.add));
    await t.pumpAndSettle();
    await pulsar(t, 'GUARDAR');
    expect(find.text('Este campo es obligatorio'), findsWidgets);
    await escribir(t, 'Documento *', '555000');
    await escribir(t, 'Nombres *', 'Lucía');
    await escribir(t, 'Apellidos *', 'Rojas');
    await escribir(t, 'Correo electrónico', 'correo-invalido');
    await pulsar(t, 'GUARDAR');
    expect(find.text('Ingresa un correo válido'), findsOneWidget);
    await escribir(t, 'Correo electrónico', 'lucia@example.com');
    await pulsar(t, 'GUARDAR');
    expect(EstadoAplicacion.repositorio.listar(Modulo.clientes).length, 5);
    await t.enterText(find.byType(TextField).first, '555000');
    await t.pump();
    expect(find.text('Lucía Rojas'), findsOneWidget);
  });
  testWidgets('Editar la segunda tarjeta cambia ese cliente y no el primero', (
    t,
  ) async {
    await abrir(t, '/clientes');
    await t.ensureVisible(find.text('Andrés Mendoza'));
    await t.tap(find.text('Andrés Mendoza'));
    await t.pumpAndSettle();
    await escribir(t, 'Nombres *', 'Andrés José');
    await pulsar(t, 'Guardar cambios');
    expect(
      EstadoAplicacion.registro(Modulo.clientes, 'CL-002').nombre,
      'Andrés José Mendoza',
    );
    expect(
      EstadoAplicacion.registro(Modulo.clientes, 'CL-001').nombre,
      'Juan Pérez',
    );
  });
  testWidgets('Servicios filtra especialidad y estado, y limpia filtros', (
    t,
  ) async {
    await abrir(t, '/servicios');
    await seleccionar(t, 'Especialidad', 'Coloración', buscar: 'coloracion');
    expect(
      find.widgetWithText(TarjetaGestion, 'Tinte capilar'),
      findsOneWidget,
    );
    expect(find.text('Corte clásico'), findsNothing);
    await seleccionar(t, 'Especialidad', 'Todas');
    await pulsar(t, 'Inactivos');
    expect(find.widgetWithText(TarjetaGestion, 'Corte clásico'), findsNothing);
  });
  testWidgets('Formulario profesional rechaza comisiones fuera de rango', (
    t,
  ) async {
    await abrir(t, '/nuevo-profesional');
    await escribir(t, 'Documento *', '777');
    await escribir(t, 'Nombres *', 'Laura');
    await escribir(t, 'Porcentaje de comisión *', '101');
    await seleccionar(t, 'Especialidad *', 'Barbería clásica');
    await pulsar(t, 'GUARDAR');
    expect(find.text('Ingresa un entero entre 0 y 100'), findsOneWidget);
    expect(EstadoAplicacion.repositorio.listar(Modulo.profesionales).length, 3);
  });
  testWidgets('Reserva exige selecciones y conserva cliente, hora y pago', (
    t,
  ) async {
    await abrir(t, '/nueva-reserva');
    await pulsar(t, 'CONTINUAR');
    expect(find.text('Selecciona una opción'), findsWidgets);
    await seleccionar(t, 'Cliente *', 'Andrés Mendoza', buscar: '1076543210');
    await seleccionar(t, 'Servicio *', 'Corte clásico', buscar: 'corte');
    await seleccionar(t, 'Profesional', 'Carlos Gómez', buscar: '98765432');
    await pulsar(t, '08:00');
    await pulsar(t, 'CONTINUAR');
    expect(find.text('Andrés Mendoza'), findsOneWidget);
    await pulsar(t, 'Transferencia');
    await pulsar(t, 'CONFIRMAR RESERVA');
    final r = EstadoAplicacion.repositorio.reservas.last;
    expect(r.clienteId, 'CL-002');
    expect(r.servicioId, 'S-001');
    expect(r.hora, '08:00');
    expect(r.medioPago, 'Transferencia');
    expect(find.text('1076543210'), findsOneWidget);
    expect(find.text('315 222 9876'), findsOneWidget);
    await pulsar(t, 'VER DETALLE');
    await pulsar(t, 'REAGENDAR');
    await pulsar(t, '08:30');
    await pulsar(t, 'GUARDAR CAMBIOS');
    expect(EstadoAplicacion.repositorio.reservas.last.hora, '08:30');
    expect(find.text('08:30'), findsOneWidget);
  });
  testWidgets('Cancelar solicita motivo, permite abortar y actualiza agenda', (
    t,
  ) async {
    await abrir(t, '/detalle-reserva', argumentos: 'R-001');
    await pulsar(t, 'CANCELAR RESERVA');
    expect(find.byType(AlertDialog), findsOneWidget);
    await pulsar(t, 'Sí, Cancelar');
    expect(find.text('Este campo es obligatorio'), findsOneWidget);
    await pulsar(t, 'No, Volver');
    expect(EstadoAplicacion.repositorio.reservas.first.estado, 'Programada');
    await pulsar(t, 'CANCELAR RESERVA');
    await t.enterText(
      find.byType(TextFormField).last,
      'Cliente no puede asistir',
    );
    await pulsar(t, 'Sí, Cancelar');
    expect(EstadoAplicacion.repositorio.reservas.first.estado, 'Cancelada');
    expect(find.text('CANCELAR RESERVA'), findsNothing);
    await pulsar(t, 'VOLVER A AGENDA');
    expect(find.widgetWithText(TarjetaRegistro, 'Juan Pérez'), findsOneWidget);
    await pulsar(t, 'Programada');
    expect(find.widgetWithText(TarjetaRegistro, 'Juan Pérez'), findsNothing);
  });
  testWidgets(
    'Cierre usa servicios atendidos y conserva consolidado y detalle',
    (t) async {
      await abrir(t, '/nuevo-cierre');
      await pulsar(t, 'Revisar resumen');
      expect(find.text('María López'), findsOneWidget);
      await pulsar(t, 'Confirmar cierre');
      expect(EstadoAplicacion.repositorio.cierres.length, 2);
      await pulsar(t, 'Consultar comisiones');
      await pulsar(t, 'María López');
      expect(find.text('Andrés Mendoza'), findsOneWidget);
      expect(find.textContaining('Comisión \$9.000'), findsOneWidget);
    },
  );
  testWidgets('Horario rechaza orden inválido y oculta campos de almuerzo', (
    t,
  ) async {
    await abrir(t, '/editar-horario', argumentos: 'H-P-001-0');
    expect(find.byKey(const ValueKey('Inicio almuerzo *')), findsOneWidget);
    await t.ensureVisible(
      find.widgetWithText(SwitchListTile, 'Tiene almuerzo'),
    );
    await t.tap(find.widgetWithText(SwitchListTile, 'Tiene almuerzo'));
    await t.pump();
    expect(find.byKey(const ValueKey('Inicio almuerzo *')), findsNothing);
    final fin = find.widgetWithText(TextFormField, 'Hora de fin *');
    t.widget<TextFormField>(fin).controller!.text = '07:00';
    await pulsar(t, 'Guardar cambios');
    expect(
      find.text('La hora final debe ser posterior a la inicial.'),
      findsOneWidget,
    );
  });
  testWidgets('Más mantiene el cambio de tema entre pantallas', (t) async {
    await abrir(t, '/inicio-principal');
    await pulsar(t, 'Más');
    await t.tap(find.byType(SwitchListTile));
    await t.pumpAndSettle();
    expect(PreferenciaTema.modo.value, ThemeMode.light);
    Navigator.pop(t.element(find.byType(SwitchListTile)));
    await t.pumpAndSettle();
    await pulsar(t, 'Especialidades');
    expect(find.text('Especialidad'), findsOneWidget);
  });
  testWidgets(
    'Crear cliente desde reserva regresa al formulario y permite seleccionarlo',
    (t) async {
      await abrir(t, '/nueva-reserva');
      await pulsar(t, 'Crear cliente');
      await escribir(t, 'Documento *', '1234567');
      await escribir(t, 'Nombres *', 'Ana');
      await escribir(t, 'Apellidos *', 'Torres');
      await pulsar(t, 'GUARDAR');
      expect(find.text('Nueva reserva'), findsOneWidget);
      await seleccionar(t, 'Cliente *', 'Ana Torres', buscar: '1234567');
      expect(find.text('Ana Torres'), findsOneWidget);
    },
  );
  testWidgets('Cambiar especialidad limpia servicio y profesional anteriores', (
    t,
  ) async {
    await abrir(t, '/nueva-reserva');
    await seleccionar(t, 'Servicio *', 'Corte clásico');
    await seleccionar(t, 'Profesional', 'Carlos Gómez');
    await seleccionar(t, 'Especialidad', 'Coloración');
    expect(find.text('Corte clásico'), findsNothing);
    expect(find.text('Carlos Gómez'), findsNothing);
    await seleccionar(t, 'Servicio *', 'Tinte capilar');
    await seleccionar(t, 'Profesional', 'María López');
    expect(find.text('María López'), findsOneWidget);
  });
  testWidgets(
    'Recuperación exige solicitud y código antes de volver al acceso',
    (t) async {
      await abrir(t, '/restablecer-contrasena');
      expect(find.text('VERIFICAR CÓDIGO'), findsNothing);
      await escribir(t, 'Correo o usuario', 'admin_barrber');
      await pulsar(t, 'ENVIAR CÓDIGO');
      await escribir(t, 'Código de verificación', '000000');
      await pulsar(t, 'VERIFICAR CÓDIGO');
      expect(
        find.text('Ingresa el código de prueba de seis dígitos'),
        findsOneWidget,
      );
      await escribir(t, 'Código de verificación', '123456');
      await pulsar(t, 'VERIFICAR CÓDIGO');
      expect(find.text('INGRESAR'), findsOneWidget);
    },
  );
  testWidgets('Un ID inexistente no abre el primer registro para editar', (
    t,
  ) async {
    await abrir(t, '/editar-cliente', argumentos: 'no-existe');
    expect(find.textContaining('No se encontró el registro'), findsOneWidget);
    expect(find.text('Guardar cambios'), findsNothing);
  });
  testWidgets('Un fallo al guardar conserva el formulario y sus datos', (
    t,
  ) async {
    EstadoAplicacion.repositorio = RepositorioConError();
    await abrir(t, '/nuevo-cliente');
    await escribir(t, 'Documento *', '9999');
    await escribir(t, 'Nombres *', 'Elena');
    await escribir(t, 'Apellidos *', 'Ruiz');
    await pulsar(t, 'GUARDAR');
    expect(
      find.text('No se pudo guardar. Inténtalo de nuevo.'),
      findsOneWidget,
    );
    expect(
      t
          .widget<TextFormField>(find.byKey(const ValueKey('Nombres *')))
          .controller!
          .text,
      'Elena',
    );
    expect(EstadoAplicacion.repositorio.listar(Modulo.clientes).length, 4);
  });
  testWidgets(
    'Limpiar filtros también restablece un rango inválido de agenda',
    (t) async {
      await abrir(t, '/agenda');
      t
              .widget<TextFormField>(
                find.byKey(const ValueKey('Fecha inicial')),
              )
              .controller!
              .text =
          '31/12/2030';
      await t.pump();
      expect(
        find.text('La fecha final debe ser igual o posterior a la inicial.'),
        findsOneWidget,
      );
      await pulsar(t, 'Limpiar filtros');
      expect(
        find.text('La fecha final debe ser igual o posterior a la inicial.'),
        findsNothing,
      );
      expect(
        find.widgetWithText(TarjetaRegistro, 'Juan Pérez'),
        findsOneWidget,
      );
    },
  );
}
