import 'servicio_barberia.dart';
import '../../models/api/horarios/listar_horarios_request.dart';
import '../../models/api/horarios/listar_horarios_response.dart';
import '../../models/api/horarios/crear_horario_request.dart';
import '../../models/api/horarios/crear_horario_response.dart';
import '../../models/api/horarios/consultar_horario_request.dart';
import '../../models/api/horarios/consultar_horario_response.dart';
import '../../models/api/horarios/actualizar_horario_request.dart';
import '../../models/api/horarios/actualizar_horario_response.dart';
import '../../models/api/horarios/eliminar_horario_request.dart';
import '../../models/api/horarios/eliminar_horario_response.dart';
import '../../models/api/horarios/listar_horarios_por_profesional_request.dart';
import '../../models/api/horarios/listar_horarios_por_profesional_response.dart';
import '../../models/api/horarios/crear_horarios_masivos_request.dart';
import '../../models/api/horarios/crear_horarios_masivos_response.dart';

class HorariosService {
  const HorariosService(this._http);

  final ServicioBarberia _http;

  Future<ListarHorariosResponse> listarHorarios(
    ListarHorariosRequest request,
  ) async {
    return ListarHorariosResponse(await _http.listar('/api/horarios-laboral'));
  }

  Future<CrearHorarioResponse> crearHorario(CrearHorarioRequest request) async {
    return CrearHorarioResponse(
      await _http.solicitar(
        'POST',
        '/api/horarios-laboral',
        datos: request.toJson(),
      ),
    );
  }

  Future<ConsultarHorarioResponse> consultarHorario(
    ConsultarHorarioRequest request,
  ) async {
    return ConsultarHorarioResponse(
      await _http.solicitar(
        'GET',
        '/api/horarios-laboral/${Uri.encodeComponent(request.id)}',
      ),
    );
  }

  Future<ActualizarHorarioResponse> actualizarHorario(
    ActualizarHorarioRequest request,
  ) async {
    return ActualizarHorarioResponse(
      await _http.solicitar(
        'PUT',
        '/api/horarios-laboral/${Uri.encodeComponent(request.id)}',
        datos: request.toJson(),
      ),
    );
  }

  Future<EliminarHorarioResponse> eliminarHorario(
    EliminarHorarioRequest request,
  ) async {
    return EliminarHorarioResponse(
      await _http.solicitar(
        'DELETE',
        '/api/horarios-laboral/${Uri.encodeComponent(request.id)}',
      ),
    );
  }

  Future<ListarHorariosPorProfesionalResponse> listarHorariosPorProfesional(
    ListarHorariosPorProfesionalRequest request,
  ) async {
    return ListarHorariosPorProfesionalResponse(
      await _http.listar(
        '/api/horarios-laboral/profesional/${Uri.encodeComponent(request.profesionalId)}',
      ),
    );
  }

  Future<CrearHorariosMasivosResponse> crearHorariosMasivos(
    CrearHorariosMasivosRequest request,
  ) async {
    return CrearHorariosMasivosResponse(
      await _http.solicitar(
        'POST',
        '/api/horarios-laboral/masivo',
        datos: request.toJson(),
      ),
    );
  }
}
