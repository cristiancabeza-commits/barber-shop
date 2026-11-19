import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  ApiService({required this.baseUrl});

  final String baseUrl;

  Future<http.Response> post(String ruta, Map<String, String> datos) =>
      enviar('POST', ruta, datos: datos);

  Future<http.Response> enviar(
    String metodo,
    String ruta, {
    String? token,
    Map<String, Object?>? datos,
    Map<String, String>? filtros,
  }) async {
    final uri = Uri.parse('$baseUrl$ruta').replace(queryParameters: filtros);
    final peticion = http.Request(metodo, uri)
      ..headers.addAll({
        'Accept': 'application/json',
        if (datos != null) 'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });
    if (datos != null) peticion.body = jsonEncode(datos);
    final cliente = http.Client();
    try {
      return await cliente
          .send(peticion)
          .then(http.Response.fromStream)
          .timeout(const Duration(seconds: 30));
    } finally {
      cliente.close();
    }
  }
}

class ErrorApi implements Exception {
  const ErrorApi(this.estado, this.mensaje);
  final int estado;
  final String mensaje;
}
