class CrearInasistenciasMasivasRequest {
  const CrearInasistenciasMasivasRequest({
    required this.profesionalId,
    required this.motivo,
    required this.observacion,
    required this.periodos,
  });

  final int profesionalId;
  final int motivo;
  final String observacion;
  final List<Map<String, String>> periodos;

  Map<String, Object?> toJson() => {
    'profesionalId': profesionalId,
    'motivo': motivo,
    'observacion': observacion,
    'periodos': periodos,
  };
}
