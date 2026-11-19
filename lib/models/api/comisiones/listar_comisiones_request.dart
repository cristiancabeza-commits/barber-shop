/// GET /api/Comisiones
class ListarComisionesRequest {
  const ListarComisionesRequest({
    this.profesionalId,
    this.liquidacionComisionId,
    this.fechaInicio,
    this.fechaFin,
  });

  final String? profesionalId;
  final String? liquidacionComisionId;
  final String? fechaInicio;
  final String? fechaFin;

  Map<String, String> get filtros => {
    if (profesionalId != null) 'profesionalId': profesionalId!,
    if (liquidacionComisionId != null)
      'liquidacionComisionId': liquidacionComisionId!,
    if (fechaInicio != null) 'fechaInicio': fechaInicio!,
    if (fechaFin != null) 'fechaFin': fechaFin!,
  };
}
