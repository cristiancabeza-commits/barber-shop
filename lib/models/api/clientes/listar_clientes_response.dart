import 'cliente_api.dart';

class ListarClientesResponse {
  ListarClientesResponse.fromJson(List<Map<String, dynamic>> filas)
    : datos = List.unmodifiable(filas.map(ClienteApi.fromJson));

  final List<ClienteApi> datos;
}
