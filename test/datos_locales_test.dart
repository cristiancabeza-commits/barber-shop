import 'package:flutter_test/flutter_test.dart';
import 'package:barrber_figma/models/datos_barberia.dart';
import 'package:barrber_figma/controllers/estado_aplicacion.dart';
import 'package:barrber_figma/controllers/disponibilidad_local.dart';

void main() {
  setUp(EstadoAplicacion.reiniciar);
  test('Disponibilidad excluye reservas solapadas, almuerzo y días libres', () {
    final lunes = DateTime(2026, 10, 26);
    final horas = horasDisponibles('P-001', lunes, 50);
    expect(horas, contains('11:00'));
    expect(horas, isNot(contains('11:30')));
    expect(horas, isNot(contains('12:00')));
    expect(horasDisponibles('P-001', DateTime(2026, 10, 25), 30), isEmpty);
    final r = EstadoAplicacion.repositorio.reservas.first;
    if (r.fecha.weekday != DateTime.sunday) {
      expect(
        horasDisponibles(r.profesionalId, r.fecha, 30),
        isNot(contains(r.hora)),
      );
      expect(
        horasDisponibles(r.profesionalId, r.fecha, 30, ignorar: r.id),
        contains(r.hora),
      );
    }
  });
  test(
    'Una inasistencia elimina la disponibilidad solo de ese profesional',
    () async {
      await EstadoAplicacion.repositorio.guardar(
        Modulo.inasistencias,
        Registro('I-test', {
          'profesional': 'P-001',
          'desde': '26/10/2026',
          'hasta': '28/10/2026',
          'motivo': 'Cita médica',
        }),
      );
      expect(horasDisponibles('P-001', DateTime(2026, 10, 27), 30), isEmpty);
      expect(horasDisponibles('P-002', DateTime(2026, 10, 27), 30), isNotEmpty);
    },
  );
  test('Un servicio no se puede incluir dos veces en un cierre', () async {
    final r = EstadoAplicacion.repositorio.reservas.firstWhere(
      (r) => r.estado == 'Atendida',
    );
    await EstadoAplicacion.repositorio.guardarCierre(
      Cierre('C-test', r.fecha, r.fecha, [r]),
    );
    await expectLater(
      EstadoAplicacion.repositorio.guardarCierre(
        Cierre('C-duplicado', r.fecha, r.fecha, [r]),
      ),
      throwsStateError,
    );
    final c = EstadoAplicacion.repositorio.cierres.last;
    expect(c.total, 60000);
    expect(c.comisiones, 9000);
  });
  test('Los catálogos y cierres no exponen listas mutables', () {
    expect(
      () => EstadoAplicacion.repositorio.listar(Modulo.clientes).clear(),
      throwsUnsupportedError,
    );
    expect(
      () => EstadoAplicacion.repositorio.cierres.last.reservas.clear(),
      throwsUnsupportedError,
    );
  });
  test('Fechas imposibles no se normalizan a otro mes', () {
    expect(leerFecha('31/02/2026'), isNull);
    expect(leerFecha('29/02/2024'), DateTime(2024, 2, 29));
  });
}
