import '../models/datos_barberia.dart';
import 'repositorio_catalogo.dart';
import 'formato_repositorio.dart';
import '../models/api/clientes/cliente_api.dart';
import '../services/remote/clientes_service.dart';
import '../models/api/clientes/actualizar_cliente_request.dart';
import '../models/api/clientes/consultar_cliente_request.dart';
import '../models/api/clientes/crear_cliente_request.dart';
import '../models/api/clientes/eliminar_cliente_request.dart';
import '../models/api/clientes/listar_clientes_request.dart';
import '../services/remote/servicio_barberia.dart';

class RepositorioClientes extends RepositorioCatalogo {
  RepositorioClientes(ServicioBarberia conexion)
    : _servicio = ClientesService(conexion);
  final ClientesService _servicio;

  @override
  Future<List<Registro>> consultarTodos() async {
    final respuesta = await _servicio.listarClientes(
      const ListarClientesRequest(),
    );
    return respuesta.datos.map(_cliente).toList();
  }

  @override
  Future<void> guardar(Registro r) async {
    final editar = registros.any((fila) => fila.id == r.id);

    if (editar) {
      await _servicio.actualizarCliente(
        ActualizarClienteRequest(
          id: r.id,
          documento: r.valor('documento'),
          nombres: r.valor('nombre'),
          apellidos: r.valor('apellidos'),
          fechaNacimiento: fechaApi(r.valor('nacimiento')),
          celular: r.valor('celular'),
          correo: r.valor('correo'),
        ),
      );
    } else {
      await _servicio.crearCliente(
        CrearClienteRequest(
          documento: r.valor('documento'),
          nombres: r.valor('nombre'),
          apellidos: r.valor('apellidos'),
          fechaNacimiento: fechaApi(r.valor('nacimiento')),
          celular: r.valor('celular'),
          correo: r.valor('correo'),
        ),
      );
    }

    await cargar();
  }

  @override
  Future<void> eliminar(String id) async {
    await _servicio.eliminarCliente(EliminarClienteRequest(id: id));
    await cargar();
  }

  @override
  Future<Registro> consultar(Registro registro) async {
    final respuesta = await _servicio.consultarCliente(
      ConsultarClienteRequest(documento: registro.valor('documento')),
    );
    return _cliente(respuesta.datos, registro);
  }

  Registro _cliente(ClienteApi cliente, [Registro? anterior]) {
    final nacimiento = cliente.fechaNacimiento;
    final id = cliente.id ?? anterior?.id;
    if (id == null || id.isEmpty)
      throw const FormatException('Cliente sin identificador');
    final datos = {
      'documento': cliente.documento,
      'nombre': cliente.nombres,
      'apellidos': cliente.apellidos,
      'celular': cliente.celular,
      'correo': cliente.correo,
      'nacimiento': nacimiento == null ? '' : fechaTexto(nacimiento),
    };
    return Registro(id, {
      for (final campo in datos.entries)
        campo.key: campo.value.isEmpty
            ? anterior?.valor(campo.key) ?? ''
            : campo.value,
    });
  }
}
