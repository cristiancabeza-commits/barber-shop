/// POST /api/Servicios
class CrearServicioRequest {
  const CrearServicioRequest({
    required this.nombre,
    required this.precio,
    required this.descripcion,
    required this.duracion,
    required this.especialidad,
  });

  final String nombre;
  final int precio;
  final String descripcion;
  final int duracion;
  final int especialidad;

  Map<String, Object?> toJson() => {
    'nombre': nombre,
    'precio': precio,
    'descripcion': descripcion,
    'duracion': duracion,
    'especialidad': especialidad,
  };
}
