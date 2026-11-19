/// GET /api/Reservas
class ListarReservasRequest {
  const ListarReservasRequest({
    this.fechaInicio,
    this.fechaFin,
    this.clienteId,
    this.servicioId,
    this.profesionalId,
  });

  final String? fechaInicio;
  final String? fechaFin;
  final String? clienteId;
  final String? servicioId;
  final String? profesionalId;

  Map<String, String> get filtros => {
    if (fechaInicio != null) 'fechaInicio': fechaInicio!,
    if (fechaFin != null) 'fechaFin': fechaFin!,
    if (clienteId != null) 'clienteId': clienteId!,
    if (servicioId != null) 'servicioId': servicioId!,
    if (profesionalId != null) 'profesionalId': profesionalId!,
  };
}
