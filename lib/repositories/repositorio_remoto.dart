import '../config/app_config.dart';
import '../models/datos_barberia.dart';
import '../services/remote/api_service.dart';
import '../services/remote/servicio_barberia.dart';
import '../services/remote/servicio_sesion.dart';
import 'repositorio_barberia.dart';
import 'repositorio_catalogo.dart';
import 'formato_repositorio.dart';
import 'repositorio_clientes.dart';
import 'repositorio_especialidades.dart';
import 'repositorio_servicios.dart';
import 'repositorio_profesionales.dart';
import 'repositorio_horarios.dart';
import 'repositorio_inasistencias.dart';
import 'repositorio_reservas.dart';
import 'repositorio_agenda.dart';
import 'repositorio_comisiones.dart';
import 'repositorio_liquidaciones.dart';

class RepositorioRemoto extends RepositorioBarberia {
  RepositorioRemoto(ServicioBarberia conexion) {
    clientes = RepositorioClientes(conexion);
    especialidades = RepositorioEspecialidades(conexion);
    servicios = RepositorioServicios(conexion);
    profesionales = RepositorioProfesionales(conexion);
    horarios = RepositorioHorarios(conexion);
    inasistencias = RepositorioInasistencias(conexion);
    agenda = RepositorioAgenda(conexion);
    moduloComisiones = RepositorioComisiones(conexion);
    liquidaciones = RepositorioLiquidaciones(conexion);
    moduloReservas = RepositorioReservas(conexion, listar);

    for (final catalogo in _catalogos.values) {
      catalogo.addListener(notifyListeners);
    }
    moduloReservas.addListener(notifyListeners);
    liquidaciones.addListener(notifyListeners);
  }

  factory RepositorioRemoto.produccion() => RepositorioRemoto(
    ServicioBarberia(
      ApiService(baseUrl: AppConfig.apiBaseUrl),
      ServicioSesion.instancia,
    ),
  );

  late final RepositorioClientes clientes;
  late final RepositorioEspecialidades especialidades;
  late final RepositorioServicios servicios;
  late final RepositorioProfesionales profesionales;
  late final RepositorioHorarios horarios;
  late final RepositorioInasistencias inasistencias;
  late final RepositorioAgenda agenda;
  late final RepositorioComisiones moduloComisiones;
  late final RepositorioLiquidaciones liquidaciones;
  late final RepositorioReservas moduloReservas;
  static const dias = diasSemana;

  Map<Modulo, RepositorioCatalogo> get _catalogos => {
    Modulo.clientes: clientes,
    Modulo.especialidades: especialidades,
    Modulo.servicios: servicios,
    Modulo.profesionales: profesionales,
    Modulo.horarios: horarios,
    Modulo.inasistencias: inasistencias,
  };

  @override
  List<Registro> listar(Modulo modulo) => _catalogos[modulo]!.registros;
  @override
  List<Reserva> get reservas => moduloReservas.reservas;
  @override
  List<Cierre> get cierres => liquidaciones.cierres;
  String? get ultimoIdReserva => moduloReservas.ultimoIdReserva;
  String? get ultimoIdCierre => liquidaciones.ultimoIdCierre;

  Future<void> cargar() async {
    await Future.wait(
      _catalogos.values.map((repositorio) => repositorio.cargar()),
    );
    await Future.wait([moduloReservas.cargar(), liquidaciones.cargar()]);
  }

  @override
  Future<void> guardar(Modulo modulo, Registro registro) =>
      _catalogos[modulo]!.guardar(registro);
  Future<void> eliminar(Modulo modulo, String id) =>
      _catalogos[modulo]!.eliminar(id);
  Future<Registro> consultarRegistro(Modulo modulo, Registro registro) =>
      _catalogos[modulo]!.consultar(registro);
  Future<List<Registro>> profesionalesPorServicio(String servicio) =>
      profesionales.profesionalesPorServicio(servicio);
  Future<List<Registro>> consultarPorProfesional(Modulo modulo, String id) =>
      modulo == Modulo.horarios
      ? horarios.consultarPorProfesional(id)
      : inasistencias.consultarPorProfesional(id);
  Future<void> guardarHorarios(Registro jornada, Set<String> diasElegidos) =>
      horarios.guardarHorarios(jornada, diasElegidos);

  @override
  Future<void> guardarReserva(Reserva reserva) =>
      moduloReservas.guardarReserva(reserva);
  Future<Reserva> consultarReserva(Reserva reserva) =>
      moduloReservas.consultarReserva(reserva);
  Future<List<Reserva>> consultarReservas({
    DateTime? desde,
    DateTime? hasta,
    String cliente = '',
    String servicio = '',
    String profesional = '',
  }) => moduloReservas.consultarReservas(
    desde: desde,
    hasta: hasta,
    cliente: cliente,
    servicio: servicio,
    profesional: profesional,
  );
  Future<Object?> consultarAgenda(
    DateTime fecha, {
    String servicio = '',
    String profesional = '',
  }) => agenda.consultarAgenda(
    fecha,
    servicio: servicio,
    profesional: profesional,
  );
  Future<List<String>> horasAgenda(
    DateTime fecha,
    String servicio, {
    String profesional = '',
  }) => agenda.horasAgenda(fecha, servicio, profesional: profesional);
  Future<List<Map<String, dynamic>>> agendaDiaria(DateTime fecha) =>
      agenda.agendaDiaria(fecha);

  @override
  Future<void> guardarCierre(Cierre cierre) =>
      liquidaciones.guardarCierre(cierre);
  Future<Cierre?> ultimoCierre() => liquidaciones.ultimoCierre();
  Future<List<Map<String, dynamic>>> comisiones({
    String? cierre,
    String? profesional,
  }) => moduloComisiones.comisiones(cierre: cierre, profesional: profesional);
  Future<List<Map<String, dynamic>>> serviciosComision(String id) =>
      moduloComisiones.serviciosComision(id);

  @override
  void dispose() {
    for (final catalogo in _catalogos.values) {
      catalogo.removeListener(notifyListeners);
      catalogo.dispose();
    }
    moduloReservas.removeListener(notifyListeners);
    moduloReservas.dispose();
    liquidaciones.removeListener(notifyListeners);
    liquidaciones.dispose();
    super.dispose();
  }
}
