/// POST /api/liquidaciones-comisiones
class CrearLiquidacionRequest {
  const CrearLiquidacionRequest({
    required this.fechaInicio,
    required this.fechaFin,
  });

  final String fechaInicio;
  final String fechaFin;

  Map<String, Object?> toJson() => {
    'fechaInicio': fechaInicio,
    'fechaFin': fechaFin,
  };
}
