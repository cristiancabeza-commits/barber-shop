import '../services/remote/comisiones_service.dart';
import '../models/api/comisiones/listar_comisiones_request.dart';
import '../models/api/comisiones/listar_servicios_de_comision_request.dart';
import '../services/remote/api_service.dart';
import '../services/remote/servicio_barberia.dart';

class RepositorioComisiones {
  RepositorioComisiones(ServicioBarberia conexion)
    : _comisiones = ComisionesService(conexion);
  final ComisionesService _comisiones;
  Future<List<Map<String, dynamic>>> comisiones({
    String? cierre,
    String? profesional,
  }) async => (await _comisiones.listarComisiones(
    ListarComisionesRequest(
      liquidacionComisionId: cierre?.isNotEmpty == true ? cierre : null,
      profesionalId: profesional?.isNotEmpty == true ? profesional : null,
    ),
  )).datos;

  Future<List<Map<String, dynamic>>> serviciosComision(String id) async {
    try {
      return (await _comisiones.listarServiciosDeComision(
        ListarServiciosDeComisionRequest(comisionId: id),
      )).datos;
    } on ErrorApi catch (error) {
      if (error.estado != 404) rethrow;
      return [];
    }
  }
}
