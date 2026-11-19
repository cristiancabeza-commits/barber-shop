import 'servicio_barberia.dart';
import '../../models/api/especialidades/listar_especialidades_request.dart';
import '../../models/api/especialidades/listar_especialidades_response.dart';
import '../../models/api/especialidades/crear_especialidad_request.dart';
import '../../models/api/especialidades/crear_especialidad_response.dart';
import '../../models/api/especialidades/consultar_especialidad_request.dart';
import '../../models/api/especialidades/consultar_especialidad_response.dart';
import '../../models/api/especialidades/actualizar_especialidad_request.dart';
import '../../models/api/especialidades/actualizar_especialidad_response.dart';
import '../../models/api/especialidades/eliminar_especialidad_request.dart';
import '../../models/api/especialidades/eliminar_especialidad_response.dart';

class EspecialidadesService {
  const EspecialidadesService(this._http);

  final ServicioBarberia _http;

  Future<ListarEspecialidadesResponse> listarEspecialidades(
    ListarEspecialidadesRequest request,
  ) async {
    return ListarEspecialidadesResponse(
      await _http.listar('/api/Especialidades'),
    );
  }

  Future<CrearEspecialidadResponse> crearEspecialidad(
    CrearEspecialidadRequest request,
  ) async {
    return CrearEspecialidadResponse(
      await _http.solicitar(
        'POST',
        '/api/Especialidades',
        datos: request.toJson(),
      ),
    );
  }

  Future<ConsultarEspecialidadResponse> consultarEspecialidad(
    ConsultarEspecialidadRequest request,
  ) async {
    return ConsultarEspecialidadResponse(
      await _http.solicitar(
        'GET',
        '/api/Especialidades/${Uri.encodeComponent(request.id)}',
      ),
    );
  }

  Future<ActualizarEspecialidadResponse> actualizarEspecialidad(
    ActualizarEspecialidadRequest request,
  ) async {
    return ActualizarEspecialidadResponse(
      await _http.solicitar(
        'PUT',
        '/api/Especialidades/${Uri.encodeComponent(request.id)}',
        datos: request.toJson(),
      ),
    );
  }

  Future<EliminarEspecialidadResponse> eliminarEspecialidad(
    EliminarEspecialidadRequest request,
  ) async {
    return EliminarEspecialidadResponse(
      await _http.solicitar(
        'DELETE',
        '/api/Especialidades/${Uri.encodeComponent(request.id)}',
      ),
    );
  }
}
