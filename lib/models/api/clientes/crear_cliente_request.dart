/// POST /api/Clientes
///
class CrearClienteRequest {
  const CrearClienteRequest({
    required this.documento,
    required this.nombres,
    required this.apellidos,
    this.fechaNacimiento,
    required this.celular,
    required this.correo,
  });

  final String documento;
  final String nombres;
  final String apellidos;
  final String? fechaNacimiento;
  final String celular;
  final String correo;

  Map<String, Object?> toJson() => {
    'documento': documento,
    'nombres': nombres,
    'apellidos': apellidos,
    'fechaNacimiento': fechaNacimiento,
    'celular': celular,
    'correo': correo,
  };
}
