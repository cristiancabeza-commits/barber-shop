import 'reserva_api.dart';

class ListarReservasResponse {
  ListarReservasResponse.fromJson(List<Map<String, dynamic>> filas)
    : datos = List.unmodifiable(filas.map(ReservaApi.fromJson));

  final List<ReservaApi> datos;
}
