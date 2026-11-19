/// PUT /api/Profesionales/{id}
class ActualizarProfesionalRequest {
  const ActualizarProfesionalRequest({
    required this.id,
    required this.documento,
    required this.nombres,
    required this.apellidos,
    this.fechaNacimiento,
    required this.porcentaje,
    required this.estado,
  });

  final String id;
  final String documento;
  final String nombres;
  final String apellidos;
  final String? fechaNacimiento;
  final num porcentaje;
  final bool estado;

  Map<String, Object?> toJson() => {
    'documento': documento,
    'nombres': nombres,
    'apellidos': apellidos,
    'fechaNacimiento': fechaNacimiento,
    'porcentaje': porcentaje,
    'estado': estado,
  };
}
