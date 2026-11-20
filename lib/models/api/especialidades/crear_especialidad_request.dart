class CrearEspecialidadRequest {
  const CrearEspecialidadRequest({required this.nombre});

  final String nombre;

  Map<String, Object?> toJson() => {'nombre': nombre};
}
