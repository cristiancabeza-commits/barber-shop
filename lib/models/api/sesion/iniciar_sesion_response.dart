class IniciarSesionResponse {
  const IniciarSesionResponse({required this.accessToken});

  factory IniciarSesionResponse.fromJson(Object? json) {
    final token = json is Map ? json['accessToken'] : null;
    if (token is! String || token.isEmpty) {
      throw const FormatException('Respuesta de sesión incompleta');
    }
    return IniciarSesionResponse(accessToken: token);
  }

  final String accessToken;
}
