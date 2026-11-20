class ConsultarDisponibilidadRequest {
  const ConsultarDisponibilidadRequest({
    this.fecha,
    this.servicioId,
    this.profesionalId,
  });

  final String? fecha;
  final String? servicioId;
  final String? profesionalId;

  Map<String, String> get filtros => {
    if (fecha != null) 'fecha': fecha!,
    if (servicioId != null) 'servicioId': servicioId!,
    if (profesionalId != null) 'profesionalId': profesionalId!,
  };
}
