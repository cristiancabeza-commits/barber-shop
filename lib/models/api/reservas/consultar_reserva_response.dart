import 'reserva_api.dart';

class ConsultarReservaResponse {
  ConsultarReservaResponse.fromJson(Object? json) : datos = _leer(json);

  final ReservaApi datos;

  static ReservaApi _leer(Object? json) {
    final fila = json is List ? json.firstOrNull : json;
    if (fila is! Map) throw const FormatException('Reserva no disponible');
    return ReservaApi.fromJson(Map<String, dynamic>.from(fila));
  }
}
