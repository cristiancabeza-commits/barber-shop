class ActualizarEspecialidadRequest {
  const ActualizarEspecialidadRequest({required this.id, required this.nombre});

  final String id;
  final String nombre;

  Map<String, Object?> toJson() => {'nombre': nombre};
}
