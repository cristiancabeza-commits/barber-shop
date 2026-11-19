import '../../config/app_config.dart';

import 'dart:convert';

import '../../models/api/sesion/iniciar_sesion_request.dart';
import '../../models/api/sesion/iniciar_sesion_response.dart';
import 'api_service.dart';

class ServicioSesion {
  ServicioSesion(this._api);

  static final instancia = ServicioSesion(
    ApiService(baseUrl: AppConfig.apiBaseUrl),
  );

  final ApiService _api;
  String? _token;

  String? get token => _token;

  Future<bool> iniciar(String usuario, String clave) async {
    final request = IniciarSesionRequest(usuario: usuario, clave: clave);
    final respuesta = await _api.post('/api/Sesion', request.toJson());
    if (respuesta.statusCode == 401 || respuesta.statusCode == 403)
      return false;
    if (respuesta.statusCode != 200)
      throw StateError('Error de inicio de sesión');
    final datos = jsonDecode(utf8.decode(respuesta.bodyBytes));
    _token = IniciarSesionResponse.fromJson(datos).accessToken;
    return true;
  }

  void cerrar() => _token = null;
}
