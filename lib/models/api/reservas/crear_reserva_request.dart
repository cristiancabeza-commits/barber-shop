/// POST /api/Reservas
class CrearReservaRequest {
  const CrearReservaRequest({
    required this.fecha,
    required this.servicioId,
    this.clienteId,
    this.documento,
    this.nombres,
    this.apellidos,
    this.fechaNacimiento,
    this.celular,
    this.correo,
  });

  final String fecha;
  final int servicioId;
  final int? clienteId;
  final String? documento;
  final String? nombres;
  final String? apellidos;
  final String? fechaNacimiento;
  final String? celular;
  final String? correo;

  Map<String, Object?> toJson() => {
    'fecha': fecha,
    'servicioId': servicioId,
    if (clienteId != null) 'clienteId': clienteId,
    if (documento != null) 'documento': documento,
    if (nombres != null) 'nombres': nombres,
    if (apellidos != null) 'apellidos': apellidos,
    if (fechaNacimiento != null) 'fechaNacimiento': fechaNacimiento,
    if (celular != null) 'celular': celular,
    if (correo != null) 'correo': correo,
  };
}
