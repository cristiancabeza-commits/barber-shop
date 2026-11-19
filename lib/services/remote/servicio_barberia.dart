import 'dart:convert';

import 'api_service.dart';
import 'servicio_sesion.dart';

class ServicioBarberia {
  ServicioBarberia(this._api, this._sesion);

  final ApiService _api;
  final ServicioSesion _sesion;

  Future<Object?> solicitar(
    String metodo,
    String ruta, {
    Map<String, Object?>? datos,
    Map<String, String>? filtros,
  }) async {
    final token = _sesion.token;
    if (token == null) throw const ErrorApi(401, 'Inicia sesión de nuevo.');
    final respuesta = await _api.enviar(
      metodo,
      ruta,
      token: token,
      datos: datos,
      filtros: filtros,
    );
    final texto = utf8.decode(respuesta.bodyBytes);
    Object? json;
    try {
      json = texto.isEmpty ? null : jsonDecode(texto);
    } on FormatException {
      if (respuesta.statusCode >= 200 && respuesta.statusCode < 300) rethrow;
    }
    if (respuesta.statusCode < 200 ||
        respuesta.statusCode >= 300 ||
        (json is Map && json['success'] == false)) {
      throw ErrorApi(
        respuesta.statusCode,
        json is Map && json['message'] is String
            ? json['message'] as String
            : 'No se pudo completar la solicitud.',
      );
    }
    return json is Map && json.containsKey('data') ? json['data'] : json;
  }

  Future<List<Map<String, dynamic>>> listar(
    String ruta, {
    Map<String, String>? filtros,
  }) async {
    final datos = await solicitar('GET', ruta, filtros: filtros);
    if (datos is! List) throw const FormatException('Se esperaba una lista');
    return datos.map((fila) => Map<String, dynamic>.from(fila as Map)).toList();
  }
}
