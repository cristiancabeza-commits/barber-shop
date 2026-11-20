import '../models/datos_barberia.dart';
import 'repositorio_catalogo.dart';
import 'formato_repositorio.dart';
import '../services/remote/especialidades_service.dart';
import '../models/api/especialidades/actualizar_especialidad_request.dart';
import '../models/api/especialidades/consultar_especialidad_request.dart';
import '../models/api/especialidades/crear_especialidad_request.dart';
import '../models/api/especialidades/eliminar_especialidad_request.dart';
import '../models/api/especialidades/listar_especialidades_request.dart';
import '../services/remote/servicio_barberia.dart';

/// Datos y operaciones de especialidades. Las peticiones HTTP están en EspecialidadesService.
class RepositorioEspecialidades extends RepositorioCatalogo {
  RepositorioEspecialidades(ServicioBarberia conexion)
    : _servicio = EspecialidadesService(conexion);
  final EspecialidadesService _servicio;

  @override
  Future<List<Registro>> consultarTodos() async {
    final respuesta = await _servicio.listarEspecialidades(
      const ListarEspecialidadesRequest(),
    );
    return respuesta.datos
        .map((fila) => registroApi(Modulo.especialidades, fila))
        .toList();
  }

  @override
  Future<void> guardar(Registro r) async {
    final editar = registros.any((fila) => fila.id == r.id);

    if (editar) {
      await _servicio.actualizarEspecialidad(
        ActualizarEspecialidadRequest(id: r.id, nombre: r.nombre),
      );
    } else {
      await _servicio.crearEspecialidad(
        CrearEspecialidadRequest(nombre: r.nombre),
      );
    }

    await cargar();
  }

  @override
  Future<void> eliminar(String id) async {
    await _servicio.eliminarEspecialidad(EliminarEspecialidadRequest(id: id));
    await cargar();
  }

  @override
  Future<Registro> consultar(Registro registro) async {
    final datos = (await _servicio.consultarEspecialidad(
      ConsultarEspecialidadRequest(id: registro.id),
    )).datos;
    final fila = datos is List ? datos.firstOrNull : datos;
    if (fila is! Map) throw const FormatException('Registro no disponible');
    final detalle = registroApi(Modulo.especialidades, {
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
}
