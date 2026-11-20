class CrearHorariosMasivosRequest {
  const CrearHorariosMasivosRequest({
    required this.profesionalId,
    required this.dias,
    required this.horaInicio,
    required this.horaFin,
    required this.tieneAlmuerzo,
    this.horaInicioAlmuerzo,
    this.horaFinAlmuerzo,
  });

  final int profesionalId;
  final List<int> dias;
  final String horaInicio;
  final String horaFin;
  final bool tieneAlmuerzo;
  final String? horaInicioAlmuerzo;
  final String? horaFinAlmuerzo;

  Map<String, Object?> toJson() => {
    'profesionalId': profesionalId,
    'dias': dias,
    'horaInicio': horaInicio,
    'horaFin': horaFin,
    'tieneAlmuerzo': tieneAlmuerzo,
    'horaInicioAlmuerzo': horaInicioAlmuerzo,
    'horaFinAlmuerzo': horaFinAlmuerzo,
  };
}
