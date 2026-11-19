/// PUT /api/eventualidades/{id}
class ActualizarInasistenciaRequest {
  const ActualizarInasistenciaRequest({
    required this.id,
    required this.fechaInicio,
    required this.fechaFin,
    required this.motivo,
    required this.observacion,
  });

  final String id;
  final String fechaInicio;
  final String fechaFin;
  final int motivo;
  final String observacion;

  Map<String, Object?> toJson() => {
    'fechaInicio': fechaInicio,
    'fechaFin': fechaFin,
    'motivo': motivo,
    'observacion': observacion,
  };
}
