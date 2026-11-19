import 'servicio_barberia.dart';
import '../../models/api/liquidaciones/crear_liquidacion_request.dart';
import '../../models/api/liquidaciones/crear_liquidacion_response.dart';
import '../../models/api/liquidaciones/listar_liquidaciones_request.dart';
import '../../models/api/liquidaciones/listar_liquidaciones_response.dart';

class LiquidacionesService {
  const LiquidacionesService(this._http);

  final ServicioBarberia _http;

  Future<CrearLiquidacionResponse> crearLiquidacion(
    CrearLiquidacionRequest request,
  ) async {
    return CrearLiquidacionResponse(
      await _http.solicitar(
        'POST',
        '/api/liquidaciones-comisiones',
        datos: request.toJson(),
      ),
    );
  }

  Future<ListarLiquidacionesResponse> listarLiquidaciones(
    ListarLiquidacionesRequest request,
  ) async {
    return ListarLiquidacionesResponse(
      await _http.solicitar(
        'GET',
        '/api/liquidaciones-comisiones',
        filtros: request.filtros,
      ),
    );
  }
}
