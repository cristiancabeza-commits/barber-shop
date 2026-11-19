/// GET /api/horarios-laboral/profesional/{profesionalId}
class ListarHorariosPorProfesionalRequest {
  const ListarHorariosPorProfesionalRequest({required this.profesionalId});

  final String profesionalId;
}
