import '../models/datos_barberia.dart';
import 'repositorio_catalogo.dart';
import 'formato_repositorio.dart';
import '../services/remote/horarios_service.dart';
import '../models/api/horarios/actualizar_horario_request.dart';
import '../models/api/horarios/consultar_horario_request.dart';
import '../models/api/horarios/crear_horario_request.dart';
import '../models/api/horarios/crear_horarios_masivos_request.dart';
import '../models/api/horarios/eliminar_horario_request.dart';
import '../models/api/horarios/listar_horarios_request.dart';
import '../models/api/horarios/listar_horarios_por_profesional_request.dart';
import '../services/remote/servicio_barberia.dart';

/// Datos y operaciones de horarios. Las peticiones HTTP están en HorariosService.
class RepositorioHorarios extends RepositorioCatalogo {
  RepositorioHorarios(ServicioBarberia conexion)
    : _servicio = HorariosService(conexion);
  final HorariosService _servicio;

  @override
  Future<List<Registro>> consultarTodos() async {
    final respuesta = await _servicio.listarHorarios(
      const ListarHorariosRequest(),
    );
    return respuesta.datos
        .map((fila) => registroApi(Modulo.horarios, fila))
        .toList();
  }

  @override
  Future<void> guardar(Registro r) async {
    final editar = registros.any((fila) => fila.id == r.id);

    if (editar) {
      await _servicio.actualizarHorario(
        ActualizarHorarioRequest(
          id: r.id,
          horaInicio: horaApi(r.valor('inicio'))!,
          horaFin: horaApi(r.valor('fin'))!,
          tieneAlmuerzo: r.valor('almuerzo') == 'sí',
          horaInicioAlmuerzo: r.valor('almuerzo') == 'sí'
              ? horaApi(r.valor('inicioAlmuerzo'))
              : null,
          horaFinAlmuerzo: r.valor('almuerzo') == 'sí'
              ? horaApi(r.valor('finAlmuerzo'))
              : null,
        ),
      );
    } else {
      await _servicio.crearHorario(
        CrearHorarioRequest(
          profesionalId: int.parse(r.valor('profesional')),
          diaSemana: diasSemana.indexOf(r.nombre),
          horaInicio: horaApi(r.valor('inicio'))!,
          horaFin: horaApi(r.valor('fin'))!,
          tieneAlmuerzo: r.valor('almuerzo') == 'sí',
          horaInicioAlmuerzo: r.valor('almuerzo') == 'sí'
              ? horaApi(r.valor('inicioAlmuerzo'))
              : null,
          horaFinAlmuerzo: r.valor('almuerzo') == 'sí'
              ? horaApi(r.valor('finAlmuerzo'))
              : null,
        ),
      );
    }

    await cargar();
  }

  @override
  Future<void> eliminar(String id) async {
    await _servicio.eliminarHorario(EliminarHorarioRequest(id: id));
    await cargar();
  }

  @override
  Future<Registro> consultar(Registro registro) async {
    final datos = (await _servicio.consultarHorario(
      ConsultarHorarioRequest(id: registro.id),
    )).datos;
    final fila = datos is List ? datos.firstOrNull : datos;
    if (fila is! Map) throw const FormatException('Registro no disponible');
    final detalle = registroApi(Modulo.horarios, {
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
    final filas = (await _servicio.listarHorariosPorProfesional(
      ListarHorariosPorProfesionalRequest(profesionalId: id),
    )).datos;
    return filas
        .map(
          (fila) =>
              registroApi(Modulo.horarios, {'profesionalId': id, ...fila}),
        )
        .toList();
  }

  Future<void> guardarHorarios(
    Registro jornada,
    Set<String> diasElegidos,
  ) async {
    final almuerzo = jornada.valor('almuerzo') == 'sí';
    await _servicio.crearHorariosMasivos(
      CrearHorariosMasivosRequest(
        profesionalId: int.parse(jornada.valor('profesional')),
        dias: diasElegidos.map(diasSemana.indexOf).toList(),
        horaInicio: horaApi(jornada.valor('inicio'))!,
        horaFin: horaApi(jornada.valor('fin'))!,
        tieneAlmuerzo: almuerzo,
        horaInicioAlmuerzo: almuerzo
            ? horaApi(jornada.valor('inicioAlmuerzo'))
            : null,
        horaFinAlmuerzo: almuerzo
            ? horaApi(jornada.valor('finAlmuerzo'))
            : null,
      ),
    );
    await cargar();
  }
}
