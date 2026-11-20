import '../models/datos_barberia.dart';
import 'repositorio_catalogo.dart';
import 'formato_repositorio.dart';
import '../services/remote/profesionales_service.dart';
import '../models/api/profesionales/actualizar_profesional_request.dart';
import '../models/api/profesionales/consultar_profesional_request.dart';
import '../models/api/profesionales/crear_profesional_request.dart';
import '../models/api/profesionales/eliminar_profesional_request.dart';
import '../models/api/profesionales/listar_profesionales_request.dart';
import '../models/api/profesionales/listar_profesionales_por_servicio_request.dart';
import '../services/remote/servicio_barberia.dart';

class RepositorioProfesionales extends RepositorioCatalogo {
  RepositorioProfesionales(ServicioBarberia conexion)
    : _servicio = ProfesionalesService(conexion);
  final ProfesionalesService _servicio;

  @override
  Future<List<Registro>> consultarTodos() async {
    final respuesta = await _servicio.listarProfesionales(
      const ListarProfesionalesRequest(),
    );
    return respuesta.datos
        .map((fila) => registroApi(Modulo.profesionales, fila))
        .toList();
  }

  @override
  Future<void> guardar(Registro r) async {
    final editar = registros.any((fila) => fila.id == r.id);

    if (editar) {
      await _servicio.actualizarProfesional(
        ActualizarProfesionalRequest(
          id: r.id,
          documento: r.valor('documento'),
          nombres: r.valor('nombre'),
          apellidos: r.valor('apellidos'),
          fechaNacimiento: fechaApi(r.valor('nacimiento')),
          porcentaje: num.parse(r.valor('comision')),
          estado: r.activo,
        ),
      );
    } else {
      await _servicio.crearProfesional(
        CrearProfesionalRequest(
          documento: r.valor('documento'),
          nombres: r.valor('nombre'),
          apellidos: r.valor('apellidos'),
          fechaNacimiento: fechaApi(r.valor('nacimiento')),
          porcentaje: num.parse(r.valor('comision')),
          estado: r.activo,
          especialidad: int.parse(r.valor('especialidad')),
        ),
      );
    }

    await cargar();
  }

  @override
  Future<void> eliminar(String id) async {
    await _servicio.eliminarProfesional(EliminarProfesionalRequest(id: id));
    await cargar();
  }

  @override
  Future<Registro> consultar(Registro registro) async {
    final datos = (await _servicio.consultarProfesional(
      ConsultarProfesionalRequest(id: registro.id),
    )).datos;
    final fila = datos is List ? datos.firstOrNull : datos;
    if (fila is! Map) throw const FormatException('Registro no disponible');
    final detalle = registroApi(Modulo.profesionales, {
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

  Future<List<Registro>> profesionalesPorServicio(String servicio) async {
    final filas = (await _servicio.listarProfesionalesPorServicio(
      ListarProfesionalesPorServicioRequest(id: servicio),
    )).datos;
    return filas
        .map((fila) => registroApi(Modulo.profesionales, fila))
        .toList();
  }
}
