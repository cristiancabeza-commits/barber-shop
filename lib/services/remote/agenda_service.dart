import 'servicio_barberia.dart';
import '../../models/api/agenda/consultar_disponibilidad_request.dart';
import '../../models/api/agenda/consultar_disponibilidad_response.dart';
import '../../models/api/agenda/consultar_agenda_diaria_request.dart';
import '../../models/api/agenda/consultar_agenda_diaria_response.dart';

class AgendaService {
  const AgendaService(this._http);

  final ServicioBarberia _http;

  Future<ConsultarDisponibilidadResponse> consultarDisponibilidad(
    ConsultarDisponibilidadRequest request,
  ) async {
    return ConsultarDisponibilidadResponse(
      await _http.listar('/api/agenda', filtros: request.filtros),
    );
  }

  Future<ConsultarAgendaDiariaResponse> consultarAgendaDiaria(
    ConsultarAgendaDiariaRequest request,
  ) async {
    return ConsultarAgendaDiariaResponse(
      await _http.listar('/api/agenda/${Uri.encodeComponent(request.fecha)}'),
    );
  }
}
