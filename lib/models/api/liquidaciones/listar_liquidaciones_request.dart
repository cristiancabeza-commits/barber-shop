class ListarLiquidacionesRequest {
  const ListarLiquidacionesRequest({
    this.ultimo,
    this.fechaInicio,
    this.fechaFin,
  });

  final String? ultimo;
  final String? fechaInicio;
  final String? fechaFin;

  Map<String, String> get filtros => {
    if (ultimo != null) 'ultimo': ultimo!,
    if (fechaInicio != null) 'fechaInicio': fechaInicio!,
    if (fechaFin != null) 'fechaFin': fechaFin!,
  };
}
