import 'servicio_barberia.dart';
import '../../models/api/comisiones/listar_comisiones_request.dart';
import '../../models/api/comisiones/listar_comisiones_response.dart';
import '../../models/api/comisiones/listar_servicios_de_comision_request.dart';
import '../../models/api/comisiones/listar_servicios_de_comision_response.dart';

class ComisionesService {
  const ComisionesService(this._http);

  final ServicioBarberia _http;

  Future<ListarComisionesResponse> listarComisiones(
    ListarComisionesRequest request,
  ) async {
    return ListarComisionesResponse(
      await _http.listar('/api/Comisiones', filtros: request.filtros),
    );
  }

  Future<ListarServiciosDeComisionResponse> listarServiciosDeComision(
    ListarServiciosDeComisionRequest request,
  ) async {
    return ListarServiciosDeComisionResponse.fromJson(
      await _http.solicitar(
        'GET',
        '/api/Comisiones/${Uri.encodeComponent(request.comisionId)}/servicios',
      ),
    );
  }
}
