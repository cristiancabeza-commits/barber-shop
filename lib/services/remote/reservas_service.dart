import 'servicio_barberia.dart';
import '../../models/api/reservas/crear_reserva_request.dart';
import '../../models/api/reservas/crear_reserva_response.dart';
import '../../models/api/reservas/listar_reservas_request.dart';
import '../../models/api/reservas/listar_reservas_response.dart';
import '../../models/api/reservas/cancelar_reserva_request.dart';
import '../../models/api/reservas/cancelar_reserva_response.dart';
import '../../models/api/reservas/consultar_reserva_request.dart';
import '../../models/api/reservas/consultar_reserva_response.dart';
import '../../models/api/reservas/actualizar_reserva_request.dart';
import '../../models/api/reservas/actualizar_reserva_response.dart';

class ReservasService {
  const ReservasService(this._http);

  final ServicioBarberia _http;

  Future<CrearReservaResponse> crearReserva(CrearReservaRequest request) async {
    return CrearReservaResponse(
      await _http.solicitar('POST', '/api/Reservas', datos: request.toJson()),
    );
  }

  Future<ListarReservasResponse> listarReservas(
    ListarReservasRequest request,
  ) async {
    return ListarReservasResponse.fromJson(
      await _http.listar('/api/Reservas', filtros: request.filtros),
    );
  }

  Future<CancelarReservaResponse> cancelarReserva(
    CancelarReservaRequest request,
  ) async {
    return CancelarReservaResponse(
      await _http.solicitar(
        'DELETE',
        '/api/Reservas/${Uri.encodeComponent(request.id)}',
        datos: request.toJson(),
      ),
    );
  }

  Future<ConsultarReservaResponse> consultarReserva(
    ConsultarReservaRequest request,
  ) async {
    return ConsultarReservaResponse.fromJson(
      await _http.solicitar(
        'GET',
        '/api/Reservas/${Uri.encodeComponent(request.id)}',
      ),
    );
  }

  Future<ActualizarReservaResponse> actualizarReserva(
    ActualizarReservaRequest request,
  ) async {
    return ActualizarReservaResponse(
      await _http.solicitar(
        'PUT',
        '/api/Reservas/${Uri.encodeComponent(request.id)}',
        datos: request.toJson(),
      ),
    );
  }
}
