import 'package:flutter/foundation.dart';

import '../models/datos_barberia.dart';
import '../services/local/datos_reserva_local.dart';
import 'formato_repositorio.dart';
import '../models/api/reservas/reserva_api.dart';
import '../services/remote/reservas_service.dart';
import '../models/api/reservas/actualizar_reserva_request.dart';
import '../models/api/reservas/cancelar_reserva_request.dart';
import '../models/api/reservas/consultar_reserva_request.dart';
import '../models/api/reservas/crear_reserva_request.dart';
import '../models/api/reservas/listar_reservas_request.dart';
import '../services/remote/servicio_barberia.dart';

/// Mantiene las reservas y coordina crear, modificar, cancelar y recargar.
class RepositorioReservas extends ChangeNotifier {
  RepositorioReservas(ServicioBarberia conexion, this.listar)
    : _apiReservas = ReservasService(conexion);
  final ReservasService _apiReservas;
  final List<Registro> Function(Modulo modulo) listar;
  final _local = DatosReservaLocal();
  List<Reserva> _reservas = [];
  List<Reserva> get reservas => List.unmodifiable(_reservas);
  String? ultimoIdReserva;
  Future<Reserva> consultarReserva(Reserva actual) async {
    final datos = (await _apiReservas.consultarReserva(
      ConsultarReservaRequest(id: actual.id),
    )).datos;
    return _reserva(datos, anterior: actual);
  }

  Future<List<Reserva>> consultarReservas({
    DateTime? desde,
    DateTime? hasta,
    String cliente = '',
    String servicio = '',
    String profesional = '',
  }) async {
    final filas = (await _apiReservas.listarReservas(
      ListarReservasRequest(
        fechaInicio: desde == null ? null : fechaIso(desde),
        fechaFin: hasta == null ? null : '${fechaIso(hasta)}T23:59:59',
        clienteId: cliente.isEmpty ? null : cliente,
        servicioId: servicio.isEmpty ? null : servicio,
        profesionalId: profesional.isEmpty ? null : profesional,
      ),
    )).datos;
    return filas.map(_reserva).toList();
  }

  Future<void> cargar() async {
    _reservas = await consultarReservas();
    notifyListeners();
  }

  Reserva _reserva(ReservaApi fila, {Reserva? anterior}) {
    final id = fila.id.isEmpty ? anterior?.id ?? '' : fila.id;
    final fecha = fila.fecha ?? anterior?.fecha;
    if (fecha == null || id.isEmpty)
      throw const FormatException('Reserva incompleta');
    final servicioId = fila.servicioId.isEmpty
        ? anterior?.servicioId ?? ''
        : fila.servicioId;
    final profesionalId = fila.profesionalId.isEmpty
        ? anterior?.profesionalId ?? ''
        : fila.profesionalId;
    final servicio = listar(Modulo.servicios)
        .where((r) => r.id == servicioId)
        .firstOrNull;
    final profesional = listar(Modulo.profesionales)
        .where((r) => r.id == profesionalId)
        .firstOrNull;
    final estado = fila.estado ?? anterior?.estado ?? '';
    return Reserva(
      id: id,
      clienteId: fila.clienteId.isEmpty
          ? anterior?.clienteId ?? ''
          : fila.clienteId,
      servicioId: servicioId,
      profesionalId: profesionalId,
      fecha: DateTime(fecha.year, fecha.month, fecha.day),
      hora: horaVista(
        fila.horaInicio ??
            anterior?.hora ??
            fecha.toIso8601String().split('T').last,
      ),
      creada: fila.fechaCreacion ?? anterior?.creada ?? fecha,
      precio:
          (fila.precio ?? num.tryParse(servicio?.valor('precio') ?? '') ?? 0)
              .round(),
      duracion: int.tryParse(servicio?.valor('duracion') ?? '') ?? 0,
      comision: double.tryParse(profesional?.valor('comision') ?? '') ?? 0,
      estado: estado == '1' || estado.toLowerCase().startsWith('cancel')
          ? 'Cancelada'
          : _local.atendidas.contains(id)
          ? 'Atendida'
          : (estado.isEmpty || estado == '0')
          ? 'Programada'
          : estado,
      medioPago: _local.mediosPago[id] ?? '',
      motivo: fila.motivo,
    );
  }

  Future<void> guardarReserva(Reserva reserva) async {
    final id = int.tryParse(reserva.id);
    if (id != null && reserva.estado == 'Atendida') {
      _local.atendidas.add(reserva.id);
      _reservas = [for (final r in _reservas) r.id == reserva.id ? reserva : r];
      notifyListeners();
      return;
    }
    if (id != null && reserva.estado == 'Cancelada') {
      await _apiReservas.cancelarReserva(
        CancelarReservaRequest(id: '$id', motivoOtro: reserva.motivo),
      );
    } else {
      final fecha = '${fechaIso(reserva.fecha)}T${reserva.hora}:00';
      final servicioId = int.parse(reserva.servicioId);
      final clienteId = int.parse(reserva.clienteId);
      final datos = id == null
          ? (await _apiReservas.crearReserva(
              CrearReservaRequest(
                fecha: fecha,
                servicioId: servicioId,
                clienteId: clienteId,
              ),
            )).datos
          : (await _apiReservas.actualizarReserva(
              ActualizarReservaRequest(
                id: '$id',
                fecha: fecha,
                servicioId: servicioId,
                clienteId: clienteId,
                profesionalId: int.tryParse(reserva.profesionalId),
              ),
            )).datos;
      final nuevoId = id?.toString() ?? idCreado(datos, 'reservaId');
      _local.mediosPago[nuevoId] = reserva.medioPago;
      ultimoIdReserva = nuevoId;
    }
    await cargar();
  }
}
