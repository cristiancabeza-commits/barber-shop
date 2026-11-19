class ReservaApi {
  ReservaApi.fromJson(Map<String, dynamic> json)
    : id = _texto(json['id'] ?? json['reservaId']),
      clienteId = _texto(json['clienteId'] ?? json['cliente']),
      servicioId = _texto(json['servicioId'] ?? json['servicio']),
      profesionalId = _texto(json['profesionalId'] ?? json['profesional']),
      fecha = DateTime.tryParse(_texto(json['fecha'])),
      fechaCreacion = DateTime.tryParse(_texto(json['fechaCreacion'])),
      horaInicio = json['horaInicio']?.toString(),
      estado = json['estado']?.toString(),
      precio = num.tryParse(_texto(json['precio'])),
      motivo = _texto(json['motivoOtro'] ?? json['motivoCancelacion']);

  final String id, clienteId, servicioId, profesionalId, motivo;
  final DateTime? fecha, fechaCreacion;
  final String? horaInicio, estado;
  final num? precio;

  static String _texto(Object? valor) =>
      (valor is Map ? valor['id'] : valor)?.toString() ?? '';
}
