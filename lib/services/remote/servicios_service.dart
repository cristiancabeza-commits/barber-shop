import 'servicio_barberia.dart';
import '../../models/api/servicios/listar_servicios_request.dart';
import '../../models/api/servicios/listar_servicios_response.dart';
import '../../models/api/servicios/crear_servicio_request.dart';
import '../../models/api/servicios/crear_servicio_response.dart';
import '../../models/api/servicios/consultar_servicio_request.dart';
import '../../models/api/servicios/consultar_servicio_response.dart';
import '../../models/api/servicios/actualizar_servicio_request.dart';
import '../../models/api/servicios/actualizar_servicio_response.dart';
import '../../models/api/servicios/eliminar_servicio_request.dart';
import '../../models/api/servicios/eliminar_servicio_response.dart';

class ServiciosService {
  const ServiciosService(this._http);

  final ServicioBarberia _http;

  Future<ListarServiciosResponse> listarServicios(
    ListarServiciosRequest request,
  ) async {
    return ListarServiciosResponse(await _http.listar('/api/Servicios'));
  }

  Future<CrearServicioResponse> crearServicio(
    CrearServicioRequest request,
  ) async {
    return CrearServicioResponse(
      await _http.solicitar('POST', '/api/Servicios', datos: request.toJson()),
    );
  }

  Future<ConsultarServicioResponse> consultarServicio(
    ConsultarServicioRequest request,
  ) async {
    return ConsultarServicioResponse(
      await _http.solicitar(
        'GET',
        '/api/Servicios/${Uri.encodeComponent(request.id)}',
      ),
    );
  }

  Future<ActualizarServicioResponse> actualizarServicio(
    ActualizarServicioRequest request,
  ) async {
    return ActualizarServicioResponse(
      await _http.solicitar(
        'PUT',
        '/api/Servicios/${Uri.encodeComponent(request.id)}',
        datos: request.toJson(),
      ),
    );
  }

  Future<EliminarServicioResponse> eliminarServicio(
    EliminarServicioRequest request,
  ) async {
    return EliminarServicioResponse(
      await _http.solicitar(
        'DELETE',
        '/api/Servicios/${Uri.encodeComponent(request.id)}',
      ),
    );
  }
}
