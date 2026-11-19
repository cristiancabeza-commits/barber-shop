import 'cliente_api.dart';

class ConsultarClienteResponse {
  ConsultarClienteResponse.fromJson(Object? json) : datos = _leer(json);

  final ClienteApi datos;

  static ClienteApi _leer(Object? json) {
    final fila = json is List ? json.firstOrNull : json;
    if (fila is! Map) throw const FormatException('Cliente no disponible');
    return ClienteApi.fromJson(Map<String, dynamic>.from(fila));
  }
}
