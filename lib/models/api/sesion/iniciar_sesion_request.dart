/// POST /api/Sesion
class IniciarSesionRequest {
  const IniciarSesionRequest({required this.usuario, required this.clave});

  final String usuario;
  final String clave;

  Map<String, String> toJson() => {'usuario': usuario, 'clave': clave};
}
