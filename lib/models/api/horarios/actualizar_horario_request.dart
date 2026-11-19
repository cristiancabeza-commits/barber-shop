/// PUT /api/horarios-laboral/{id}
class ActualizarHorarioRequest {
  const ActualizarHorarioRequest({
    required this.id,
    required this.horaInicio,
    required this.horaFin,
    required this.tieneAlmuerzo,
    this.horaInicioAlmuerzo,
    this.horaFinAlmuerzo,
  });

  final String id;
  final String horaInicio;
  final String horaFin;
  final bool tieneAlmuerzo;
  final String? horaInicioAlmuerzo;
  final String? horaFinAlmuerzo;

  Map<String, Object?> toJson() => {
    'horaInicio': horaInicio,
    'horaFin': horaFin,
    'tieneAlmuerzo': tieneAlmuerzo,
    'horaInicioAlmuerzo': horaInicioAlmuerzo,
    'horaFinAlmuerzo': horaFinAlmuerzo,
  };
}
