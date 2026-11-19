/// GET /api/Profesionales
class ListarProfesionalesRequest {
  const ListarProfesionalesRequest({this.soloActivos});

  final String? soloActivos;

  Map<String, String> get filtros => {
    if (soloActivos != null) 'soloActivos': soloActivos!,
  };
}
