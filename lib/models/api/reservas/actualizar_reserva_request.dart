class ActualizarReservaRequest {
  const ActualizarReservaRequest({
    required this.id,
    required this.fecha,
    required this.servicioId,
    this.profesionalId,
    required this.clienteId,
  });

  final String id;
  final String fecha;
  final int servicioId;
  final int? profesionalId;
  final int clienteId;

  Map<String, Object?> toJson() => {
    'fecha': fecha,
    'servicioId': servicioId,
    'profesionalId': profesionalId,
    'clienteId': clienteId,
  };
}
