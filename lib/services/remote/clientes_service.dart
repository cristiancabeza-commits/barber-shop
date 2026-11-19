import 'servicio_barberia.dart';
import '../../models/api/clientes/listar_clientes_request.dart';
import '../../models/api/clientes/listar_clientes_response.dart';
import '../../models/api/clientes/crear_cliente_request.dart';
import '../../models/api/clientes/crear_cliente_response.dart';
import '../../models/api/clientes/consultar_cliente_request.dart';
import '../../models/api/clientes/consultar_cliente_response.dart';
import '../../models/api/clientes/actualizar_cliente_request.dart';
import '../../models/api/clientes/actualizar_cliente_response.dart';
import '../../models/api/clientes/eliminar_cliente_request.dart';
import '../../models/api/clientes/eliminar_cliente_response.dart';

class ClientesService {
  const ClientesService(this._http);

  final ServicioBarberia _http;

  Future<ListarClientesResponse> listarClientes(
    ListarClientesRequest request,
  ) async {
    return ListarClientesResponse.fromJson(await _http.listar('/api/Clientes'));
  }

  Future<CrearClienteResponse> crearCliente(CrearClienteRequest request) async {
    return CrearClienteResponse(
      await _http.solicitar('POST', '/api/Clientes', datos: request.toJson()),
    );
  }

  Future<ConsultarClienteResponse> consultarCliente(
    ConsultarClienteRequest request,
  ) async {
    return ConsultarClienteResponse.fromJson(
      await _http.solicitar(
        'GET',
        '/api/Clientes/${Uri.encodeComponent(request.documento)}',
      ),
    );
  }

  Future<ActualizarClienteResponse> actualizarCliente(
    ActualizarClienteRequest request,
  ) async {
    return ActualizarClienteResponse(
      await _http.solicitar(
        'PUT',
        '/api/Clientes/${Uri.encodeComponent(request.id)}',
        datos: request.toJson(),
      ),
    );
  }

  Future<EliminarClienteResponse> eliminarCliente(
    EliminarClienteRequest request,
  ) async {
    return EliminarClienteResponse(
      await _http.solicitar(
        'DELETE',
        '/api/Clientes/${Uri.encodeComponent(request.id)}',
      ),
    );
  }
}
