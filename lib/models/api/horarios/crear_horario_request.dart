class CrearHorarioRequest {
  const CrearHorarioRequest({
    required this.profesionalId,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
    required this.tieneAlmuerzo,
    this.horaInicioAlmuerzo,
    this.horaFinAlmuerzo,
  });

  final int profesionalId;
  final int diaSemana;
  final String horaInicio;
  final String horaFin;
  final bool tieneAlmuerzo;
  final String? horaInicioAlmuerzo;
  final String? horaFinAlmuerzo;

  Map<String, Object?> toJson() => {
    'profesionalId': profesionalId,
    'diaSemana': diaSemana,
    'horaInicio': horaInicio,
    'horaFin': horaFin,
    'tieneAlmuerzo': tieneAlmuerzo,
    'horaInicioAlmuerzo': horaInicioAlmuerzo,
    'horaFinAlmuerzo': horaFinAlmuerzo,
  };
}
