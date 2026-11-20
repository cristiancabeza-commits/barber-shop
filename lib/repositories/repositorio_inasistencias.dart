import '../models/datos_barberia.dart';
import 'repositorio_catalogo.dart';
import 'formato_repositorio.dart';
import '../services/remote/inasistencias_service.dart';
import '../models/api/inasistencias/actualizar_inasistencia_request.dart';
import '../models/api/inasistencias/consultar_inasistencia_request.dart';
import '../models/api/inasistencias/crear_inasistencias_masivas_request.dart';
import '../models/api/inasistencias/eliminar_inasistencia_request.dart';
import '../models/api/inasistencias/listar_inasistencias_request.dart';
import '../services/remote/servicio_barberia.dart';

/// Datos y operaciones de inasistencias. Las peticiones HTTP están en InasistenciasService.
class RepositorioInasistencias extends RepositorioCatalogo {
  RepositorioInasistencias(ServicioBarberia conexion)
    : _servicio = InasistenciasService(conexion);
  final InasistenciasService _servicio;

  @override
  Future<List<Registro>> consultarTodos() async {
    final respuesta = await _servicio.listarInasistencias(
      const ListarInasistenciasRequest(),
    );
    return respuesta.datos
        .map((fila) => registroApi(Modulo.inasistencias, fila))
        .toList();
  }

  @override
  Future<void> guardar(Registro r) async {
    final editar = registros.any((fila) => fila.id == r.id);

    if (editar) {
      await _servicio.actualizarInasistencia(
        ActualizarInasistenciaRequest(
          id: r.id,
          fechaInicio: _periodo(r)['fechaInicio']!,
          fechaFin: _periodo(r)['fechaFin']!,
          motivo: int.tryParse(r.valor('motivoId')) ?? 4,
          observacion: r.valor('motivo'),
        ),
      );
    } else {
      await _servicio.crearInasistenciasMasivas(
        CrearInasistenciasMasivasRequest(
          profesionalId: int.parse(r.valor('profesional')),
          motivo: int.tryParse(r.valor('motivoId')) ?? 4,
          observacion: r.valor('motivo'),
          periodos: [_periodo(r)],
        ),
      );
    }
    await cargar();
  }

  @override
  Future<void> eliminar(String id) async {
    await _servicio.eliminarInasistencia(EliminarInasistenciaRequest(id: id));
    await cargar();
  }

  @override
  Future<Registro> consultar(Registro registro) async {
    final datos = (await _servicio.consultarInasistencia(
      ConsultarInasistenciaRequest(id: registro.id),
    )).datos;
    final fila = datos is List ? datos.firstOrNull : datos;
    if (fila is! Map) throw const FormatException('Registro no disponible');
    final detalle = registroApi(Modulo.inasistencias, {
      'id': registro.id,
      ...Map<String, dynamic>.from(fila),
    });
    return Registro(detalle.id, {
      for (final campo in detalle.datos.entries)
        campo.key: campo.value.isEmpty
            ? registro.valor(campo.key)
            : campo.value,
    }, activo: detalle.activo);
  }

  Future<List<Registro>> consultarPorProfesional(String id) async {
    final filas = (await _servicio.listarInasistencias(
      ListarInasistenciasRequest(profesionalId: id),
    )).datos;
    return filas
        .map(
          (fila) =>
              registroApi(Modulo.inasistencias, {'profesionalId': id, ...fila}),
        )
        .toList();
  }

  Map<String, String> _periodo(Registro r) => {
    'fechaInicio': '${fechaApi(r.valor('desde'))}T00:00:00',
    'fechaFin': '${fechaApi(r.valor('hasta'))}T23:59:59',
  };
}
