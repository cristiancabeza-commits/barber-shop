import 'servicio_barberia.dart';
import '../../models/api/profesionales/listar_profesionales_request.dart';
import '../../models/api/profesionales/listar_profesionales_response.dart';
import '../../models/api/profesionales/crear_profesional_request.dart';
import '../../models/api/profesionales/crear_profesional_response.dart';
import '../../models/api/profesionales/consultar_profesional_request.dart';
import '../../models/api/profesionales/consultar_profesional_response.dart';
import '../../models/api/profesionales/actualizar_profesional_request.dart';
import '../../models/api/profesionales/actualizar_profesional_response.dart';
import '../../models/api/profesionales/eliminar_profesional_request.dart';
import '../../models/api/profesionales/eliminar_profesional_response.dart';
import '../../models/api/profesionales/listar_profesionales_por_servicio_request.dart';
import '../../models/api/profesionales/listar_profesionales_por_servicio_response.dart';

class ProfesionalesService {
  const ProfesionalesService(this._http);

  final ServicioBarberia _http;

  Future<ListarProfesionalesResponse> listarProfesionales(
    ListarProfesionalesRequest request,
  ) async {
    return ListarProfesionalesResponse(
      await _http.listar('/api/Profesionales', filtros: request.filtros),
    );
  }

  Future<CrearProfesionalResponse> crearProfesional(
    CrearProfesionalRequest request,
  ) async {
    return CrearProfesionalResponse(
      await _http.solicitar(
        'POST',
        '/api/Profesionales',
        datos: request.toJson(),
      ),
    );
  }

  Future<ConsultarProfesionalResponse> consultarProfesional(
    ConsultarProfesionalRequest request,
  ) async {
    return ConsultarProfesionalResponse(
      await _http.solicitar(
        'GET',
        '/api/Profesionales/${Uri.encodeComponent(request.id)}',
      ),
    );
  }

  Future<ActualizarProfesionalResponse> actualizarProfesional(
    ActualizarProfesionalRequest request,
  ) async {
    return ActualizarProfesionalResponse(
      await _http.solicitar(
        'PUT',
        '/api/Profesionales/${Uri.encodeComponent(request.id)}',
        datos: request.toJson(),
      ),
    );
  }

  Future<EliminarProfesionalResponse> eliminarProfesional(
    EliminarProfesionalRequest request,
  ) async {
    return EliminarProfesionalResponse(
      await _http.solicitar(
        'DELETE',
        '/api/Profesionales/${Uri.encodeComponent(request.id)}',
      ),
    );
  }

  Future<ListarProfesionalesPorServicioResponse> listarProfesionalesPorServicio(
    ListarProfesionalesPorServicioRequest request,
  ) async {
    return ListarProfesionalesPorServicioResponse(
      await _http.listar(
        '/api/Profesionales/${Uri.encodeComponent(request.id)}/especialiades',
      ),
    );
  }
}
