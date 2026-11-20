class CrearProfesionalRequest {
  const CrearProfesionalRequest({
    required this.documento,
    required this.nombres,
    required this.apellidos,
    this.fechaNacimiento,
    required this.porcentaje,
    required this.estado,
    required this.especialidad,
  });

  final String documento;
  final String nombres;
  final String apellidos;
  final String? fechaNacimiento;
  final num porcentaje;
  final bool estado;
  final int especialidad;

  Map<String, Object?> toJson() => {
    'documento': documento,
    'nombres': nombres,
    'apellidos': apellidos,
    'fechaNacimiento': fechaNacimiento,
    'porcentaje': porcentaje,
    'estado': estado,
    'especialidad': especialidad,
  };
}
