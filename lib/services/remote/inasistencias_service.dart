import 'servicio_barberia.dart';
import '../../models/api/inasistencias/listar_inasistencias_request.dart';
import '../../models/api/inasistencias/listar_inasistencias_response.dart';
import '../../models/api/inasistencias/consultar_inasistencia_request.dart';
import '../../models/api/inasistencias/consultar_inasistencia_response.dart';
import '../../models/api/inasistencias/actualizar_inasistencia_request.dart';
import '../../models/api/inasistencias/actualizar_inasistencia_response.dart';
import '../../models/api/inasistencias/eliminar_inasistencia_request.dart';
import '../../models/api/inasistencias/eliminar_inasistencia_response.dart';
import '../../models/api/inasistencias/crear_inasistencias_masivas_request.dart';
import '../../models/api/inasistencias/crear_inasistencias_masivas_response.dart';

class InasistenciasService {
  const InasistenciasService(this._http);

  final ServicioBarberia _http;

  Future<ListarInasistenciasResponse> listarInasistencias(
    ListarInasistenciasRequest request,
  ) async {
    return ListarInasistenciasResponse(
      await _http.listar('/api/eventualidades', filtros: request.filtros),
    );
  }

  Future<ConsultarInasistenciaResponse> consultarInasistencia(
    ConsultarInasistenciaRequest request,
  ) async {
    return ConsultarInasistenciaResponse(
      await _http.solicitar(
        'GET',
        '/api/eventualidades/${Uri.encodeComponent(request.id)}',
      ),
    );
  }

  Future<ActualizarInasistenciaResponse> actualizarInasistencia(
    ActualizarInasistenciaRequest request,
  ) async {
    return ActualizarInasistenciaResponse(
      await _http.solicitar(
        'PUT',
        '/api/eventualidades/${Uri.encodeComponent(request.id)}',
        datos: request.toJson(),
      ),
    );
  }

  Future<EliminarInasistenciaResponse> eliminarInasistencia(
    EliminarInasistenciaRequest request,
  ) async {
    return EliminarInasistenciaResponse(
      await _http.solicitar(
        'DELETE',
        '/api/eventualidades/${Uri.encodeComponent(request.id)}',
      ),
    );
  }

  Future<CrearInasistenciasMasivasResponse> crearInasistenciasMasivas(
    CrearInasistenciasMasivasRequest request,
  ) async {
    return CrearInasistenciasMasivasResponse(
      await _http.solicitar(
        'POST',
        '/api/eventualidades/masivo',
        datos: request.toJson(),
      ),
    );
  }
}
