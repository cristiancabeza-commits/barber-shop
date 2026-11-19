/// PUT /api/Servicios/{id}
class ActualizarServicioRequest {
  const ActualizarServicioRequest({
    required this.id,
    required this.nombre,
    required this.precio,
    required this.activo,
    required this.duracion,
  });

  final String id;
  final String nombre;
  final int precio;
  final bool activo;
  final int duracion;

  Map<String, Object?> toJson() => {
    'nombre': nombre,
    'precio': precio,
    'activo': activo,
    'duracion': duracion,
  };
}
