import 'formato_repositorio.dart';
import '../services/remote/agenda_service.dart';
import '../models/api/agenda/consultar_agenda_diaria_request.dart';
import '../models/api/agenda/consultar_disponibilidad_request.dart';
import '../services/remote/servicio_barberia.dart';

/// Coordina las consultas de agenda usando su servicio remoto.
class RepositorioAgenda {
  RepositorioAgenda(ServicioBarberia conexion)
    : _agenda = AgendaService(conexion);
  final AgendaService _agenda;
  Future<Object?> consultarAgenda(
    DateTime fecha, {
    String servicio = '',
    String profesional = '',
  }) async {
    if (servicio.isEmpty && profesional.isEmpty) return agendaDiaria(fecha);
    return (await _agenda.consultarDisponibilidad(
      ConsultarDisponibilidadRequest(
        fecha: fechaIso(fecha),
        servicioId: servicio.isEmpty ? null : servicio,
        profesionalId: profesional.isEmpty ? null : profesional,
      ),
    )).datos;
  }

  Future<List<String>> horasAgenda(
    DateTime fecha,
    String servicio, {
    String profesional = '',
  }) async {
    final datos = await consultarAgenda(
      fecha,
      servicio: servicio,
      profesional: profesional,
    );
    if (datos is! List) throw const FormatException('Disponibilidad inválida');
    return datos
        .map((fila) {
          final marca = DateTime.parse((fila as Map)['fecha'] as String);
          return horaVista(marca.toIso8601String().split('T').last);
        })
        .toSet()
        .toList()
      ..sort();
  }

  Future<List<Map<String, dynamic>>> agendaDiaria(DateTime fecha) async =>
      (await _agenda.consultarAgendaDiaria(
        ConsultarAgendaDiariaRequest(fecha: fechaIso(fecha)),
      )).datos;
}
