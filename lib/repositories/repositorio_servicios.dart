import '../models/datos_barberia.dart';
import 'repositorio_catalogo.dart';
import 'formato_repositorio.dart';
import '../services/remote/servicios_service.dart';
import '../models/api/servicios/actualizar_servicio_request.dart';
import '../models/api/servicios/consultar_servicio_request.dart';
import '../models/api/servicios/crear_servicio_request.dart';
import '../models/api/servicios/eliminar_servicio_request.dart';
import '../models/api/servicios/listar_servicios_request.dart';
import '../services/remote/servicio_barberia.dart';

class RepositorioServicios extends RepositorioCatalogo {
  RepositorioServicios(ServicioBarberia conexion)
    : _servicio = ServiciosService(conexion);
  final ServiciosService _servicio;

  @override
  Future<List<Registro>> consultarTodos() async {
    final respuesta = await _servicio.listarServicios(
      const ListarServiciosRequest(),
    );
    return respuesta.datos
        .map((fila) => registroApi(Modulo.servicios, fila))
        .toList();
  }

  @override
  Future<void> guardar(Registro r) async {
    final editar = registros.any((fila) => fila.id == r.id);

    if (editar) {
      await _servicio.actualizarServicio(
        ActualizarServicioRequest(
          id: r.id,
          nombre: r.nombre,
          precio: int.parse(r.valor('precio')),
          activo: r.activo,
          duracion: int.parse(r.valor('duracion')),
        ),
      );
    } else {
      await _servicio.crearServicio(
        CrearServicioRequest(
          nombre: r.nombre,
          precio: int.parse(r.valor('precio')),
          descripcion: r.valor('descripcion'),
          duracion: int.parse(r.valor('duracion')),
          especialidad: int.parse(r.valor('especialidad')),
        ),
      );
    }

    await cargar();
  }

  @override
  Future<void> eliminar(String id) async {
    await _servicio.eliminarServicio(EliminarServicioRequest(id: id));
    await cargar();
  }

  @override
  Future<Registro> consultar(Registro registro) async {
    final datos = (await _servicio.consultarServicio(
      ConsultarServicioRequest(id: registro.id),
    )).datos;
    final fila = datos is List ? datos.firstOrNull : datos;
    if (fila is! Map) throw const FormatException('Registro no disponible');
    final detalle = registroApi(Modulo.servicios, {
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
