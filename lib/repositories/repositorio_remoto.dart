import '../config/app_config.dart';
import '../models/api/clientes/cliente_api.dart';
import '../models/api/reservas/reserva_api.dart';
import '../services/remote/clientes_service.dart';
import '../models/api/clientes/actualizar_cliente_request.dart';
import '../models/api/clientes/consultar_cliente_request.dart';
import '../models/api/clientes/crear_cliente_request.dart';
import '../models/api/clientes/eliminar_cliente_request.dart';
import '../models/api/clientes/listar_clientes_request.dart';
import '../services/remote/especialidades_service.dart';
import '../models/api/especialidades/actualizar_especialidad_request.dart';
import '../models/api/especialidades/consultar_especialidad_request.dart';
import '../models/api/especialidades/crear_especialidad_request.dart';
import '../models/api/especialidades/eliminar_especialidad_request.dart';
import '../models/api/especialidades/listar_especialidades_request.dart';
import '../services/remote/servicios_service.dart';
import '../models/api/servicios/actualizar_servicio_request.dart';
import '../models/api/servicios/consultar_servicio_request.dart';
import '../models/api/servicios/crear_servicio_request.dart';
import '../models/api/servicios/eliminar_servicio_request.dart';
import '../models/api/servicios/listar_servicios_request.dart';
import '../services/remote/profesionales_service.dart';
import '../models/api/profesionales/actualizar_profesional_request.dart';
import '../models/api/profesionales/consultar_profesional_request.dart';
import '../models/api/profesionales/crear_profesional_request.dart';
import '../models/api/profesionales/eliminar_profesional_request.dart';
import '../models/api/profesionales/listar_profesionales_request.dart';
import '../models/api/profesionales/listar_profesionales_por_servicio_request.dart';
import '../services/remote/horarios_service.dart';
import '../models/api/horarios/actualizar_horario_request.dart';
import '../models/api/horarios/consultar_horario_request.dart';
import '../models/api/horarios/crear_horario_request.dart';
import '../models/api/horarios/crear_horarios_masivos_request.dart';
import '../models/api/horarios/eliminar_horario_request.dart';
import '../models/api/horarios/listar_horarios_request.dart';
import '../models/api/horarios/listar_horarios_por_profesional_request.dart';
import '../services/remote/inasistencias_service.dart';
import '../models/api/inasistencias/actualizar_inasistencia_request.dart';
import '../models/api/inasistencias/consultar_inasistencia_request.dart';
import '../models/api/inasistencias/crear_inasistencias_masivas_request.dart';
import '../models/api/inasistencias/eliminar_inasistencia_request.dart';
import '../models/api/inasistencias/listar_inasistencias_request.dart';
import '../services/remote/reservas_service.dart';
import '../models/api/reservas/actualizar_reserva_request.dart';
import '../models/api/reservas/cancelar_reserva_request.dart';
import '../models/api/reservas/consultar_reserva_request.dart';
import '../models/api/reservas/crear_reserva_request.dart';
import '../models/api/reservas/listar_reservas_request.dart';
import '../services/remote/agenda_service.dart';
import '../models/api/agenda/consultar_agenda_diaria_request.dart';
import '../models/api/agenda/consultar_disponibilidad_request.dart';
import '../services/remote/liquidaciones_service.dart';
import '../models/api/liquidaciones/crear_liquidacion_request.dart';
import '../models/api/liquidaciones/listar_liquidaciones_request.dart';
import '../services/remote/comisiones_service.dart';
import '../models/api/comisiones/listar_comisiones_request.dart';
import '../models/api/comisiones/listar_servicios_de_comision_request.dart';
import '../services/local/datos_reserva_local.dart';
import '../models/datos_barberia.dart';
import '../services/remote/api_service.dart';
import '../services/remote/servicio_barberia.dart';
import '../services/remote/servicio_sesion.dart';
import 'repositorio_barberia.dart';

class RepositorioRemoto extends RepositorioBarberia {
  RepositorioRemoto(ServicioBarberia servicio) : _servicio = servicio;

  factory RepositorioRemoto.produccion() => RepositorioRemoto(
    ServicioBarberia(
      ApiService(baseUrl: AppConfig.apiBaseUrl),
      ServicioSesion.instancia,
    ),
  );

  final ServicioBarberia _servicio;
  late final _clientes = ClientesService(_servicio);
  late final _especialidades = EspecialidadesService(_servicio);
  late final _servicios = ServiciosService(_servicio);
  late final _profesionales = ProfesionalesService(_servicio);
  late final _horarios = HorariosService(_servicio);
  late final _inasistencias = InasistenciasService(_servicio);
  late final _apiReservas = ReservasService(_servicio);
  late final _agenda = AgendaService(_servicio);
  late final _liquidaciones = LiquidacionesService(_servicio);
  late final _comisiones = ComisionesService(_servicio);
  final _registros = <Modulo, List<Registro>>{};
  List<Reserva> _reservas = [];
  List<Cierre> _cierres = [];
  final _local = DatosReservaLocal();

  static const dias = [
    'Domingo',
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
  ];

  @override
  List<Registro> listar(Modulo modulo) =>
      List.unmodifiable(_registros[modulo] ?? []);
  @override
  List<Reserva> get reservas => List.unmodifiable(_reservas);
  @override
  List<Cierre> get cierres => List.unmodifiable(_cierres);

  Future<void> cargar() async {
    await Future.wait(Modulo.values.map(_cargarModulo));
    await Future.wait([_cargarReservas(), _cargarCierres()]);
  }

  Future<void> _cargarModulo(Modulo modulo) async {
    if (modulo == Modulo.clientes) {
      final respuesta = await _clientes.listarClientes(
        const ListarClientesRequest(),
      );
      _registros[modulo] = respuesta.datos.map(_cliente).toList();
      notifyListeners();
      return;
    }
    final filas = switch (modulo) {
      Modulo.clientes => throw StateError('Los clientes usan un modelo tipado'),
      Modulo.especialidades => (await _especialidades.listarEspecialidades(
        const ListarEspecialidadesRequest(),
      )).datos,
      Modulo.servicios => (await _servicios.listarServicios(
        const ListarServiciosRequest(),
      )).datos,
      Modulo.profesionales => (await _profesionales.listarProfesionales(
        const ListarProfesionalesRequest(),
      )).datos,
      Modulo.horarios => (await _horarios.listarHorarios(
        const ListarHorariosRequest(),
      )).datos,
      Modulo.inasistencias => (await _inasistencias.listarInasistencias(
        const ListarInasistenciasRequest(),
      )).datos,
    };
    _registros[modulo] = filas.map((fila) => _registro(modulo, fila)).toList();
    notifyListeners();
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

  String _texto(Object? valor) =>
      (valor is Map ? valor['id'] : valor)?.toString() ?? '';
  String _fechaVista(Object? valor) {
    final fecha = DateTime.tryParse(_texto(valor));
    return fecha == null ? '' : fechaTexto(fecha);
  }

  String _hora(Object? valor) {
    final texto = _texto(valor);
    return texto.length >= 5 ? texto.substring(0, 5) : texto;
  }

  String _iso(DateTime fecha) => fecha.toIso8601String().split('T').first;
  String? _fechaApi(String valor) {
    final fecha = leerFecha(valor);
    return fecha == null ? null : _iso(fecha);
  }

  String? _horaApi(String valor) => valor.isEmpty ? null : '$valor:00';
  bool _activo(Object? valor) => ![
    false,
    0,
    '0',
    'false',
    'inactivo',
  ].contains(valor?.toString().toLowerCase() ?? valor);

  Registro _registro(Modulo modulo, Map<String, dynamic> fila) {
    final dia = int.tryParse(_texto(fila['diaSemana']));
    final id = _texto(
      fila['id'] ??
          fila[switch (modulo) {
            Modulo.clientes => 'clienteId',
            Modulo.especialidades => 'especialidadId',
            Modulo.servicios => 'servicioId',
            Modulo.profesionales => 'profesionalId',
            Modulo.horarios => 'horarioLaboralId',
            Modulo.inasistencias => 'eventualidadId',
          }],
    );
    if (id.isEmpty) throw const FormatException('Registro sin identificador');
    return Registro(id, {
      'nombre': dia != null && dia >= 0 && dia < dias.length
          ? dias[dia]
          : _texto(
              fila['nombres'] ??
                  fila['nombre'] ??
                  fila['diaSemana'] ??
                  fila['profesionalNombre'],
            ),
      for (final campo in [
        'documento',
        'apellidos',
        'celular',
        'correo',
        'precio',
        'duracion',
        'descripcion',
      ])
        campo: _texto(fila[campo]),
      'nacimiento': _fechaVista(fila['fechaNacimiento']),
      'comision': _texto(fila['porcentaje']),
      'especialidad': _texto(fila['especialidadId'] ?? fila['especialidad']),
      'profesional': _texto(fila['profesionalId'] ?? fila['profesional']),
      'inicio': _hora(fila['horaInicio']),
      'fin': _hora(fila['horaFin']),
      'almuerzo': fila['tieneAlmuerzo'] == true ? 'sí' : 'no',
      'inicioAlmuerzo': _hora(fila['horaInicioAlmuerzo']),
      'finAlmuerzo': _hora(fila['horaFinAlmuerzo']),
      'desde': _fechaVista(fila['fechaInicio']),
      'hasta': _fechaVista(fila['fechaFin']),
      'motivo': _texto(fila['observacion'] ?? fila['motivo']),
      'motivoId': _texto(fila['motivo']),
    }, activo: _activo(fila['activo'] ?? fila['activa'] ?? fila['estado']));
  }

  @override
  Future<void> guardar(Modulo modulo, Registro r) async {
    final editar = listar(modulo).any((fila) => fila.id == r.id);
    switch (modulo) {
      case Modulo.clientes:
        if (editar) {
          await _clientes.actualizarCliente(
            ActualizarClienteRequest(
              id: r.id,
              documento: r.valor('documento'),
              nombres: r.valor('nombre'),
              apellidos: r.valor('apellidos'),
              fechaNacimiento: _fechaApi(r.valor('nacimiento')),
              celular: r.valor('celular'),
              correo: r.valor('correo'),
            ),
          );
        } else {
          await _clientes.crearCliente(
            CrearClienteRequest(
              documento: r.valor('documento'),
              nombres: r.valor('nombre'),
              apellidos: r.valor('apellidos'),
              fechaNacimiento: _fechaApi(r.valor('nacimiento')),
              celular: r.valor('celular'),
              correo: r.valor('correo'),
            ),
          );
        }
      case Modulo.especialidades:
        if (editar) {
          await _especialidades.actualizarEspecialidad(
            ActualizarEspecialidadRequest(id: r.id, nombre: r.nombre),
          );
        } else {
          await _especialidades.crearEspecialidad(
            CrearEspecialidadRequest(nombre: r.nombre),
          );
        }
      case Modulo.servicios:
        if (editar) {
          await _servicios.actualizarServicio(
            ActualizarServicioRequest(
              id: r.id,
              nombre: r.nombre,
              precio: int.parse(r.valor('precio')),
              activo: r.activo,
              duracion: int.parse(r.valor('duracion')),
            ),
          );
        } else {
          await _servicios.crearServicio(
            CrearServicioRequest(
              nombre: r.nombre,
              precio: int.parse(r.valor('precio')),
              descripcion: r.valor('descripcion'),
              duracion: int.parse(r.valor('duracion')),
              especialidad: int.parse(r.valor('especialidad')),
            ),
          );
        }
      case Modulo.profesionales:
        if (editar) {
          await _profesionales.actualizarProfesional(
            ActualizarProfesionalRequest(
              id: r.id,
              documento: r.valor('documento'),
              nombres: r.valor('nombre'),
              apellidos: r.valor('apellidos'),
              fechaNacimiento: _fechaApi(r.valor('nacimiento')),
              porcentaje: num.parse(r.valor('comision')),
              estado: r.activo,
            ),
          );
        } else {
          await _profesionales.crearProfesional(
            CrearProfesionalRequest(
              documento: r.valor('documento'),
              nombres: r.valor('nombre'),
              apellidos: r.valor('apellidos'),
              fechaNacimiento: _fechaApi(r.valor('nacimiento')),
              porcentaje: num.parse(r.valor('comision')),
              estado: r.activo,
              especialidad: int.parse(r.valor('especialidad')),
            ),
          );
        }
      case Modulo.horarios:
        if (editar) {
          await _horarios.actualizarHorario(
            ActualizarHorarioRequest(
              id: r.id,
              horaInicio: _horaApi(r.valor('inicio'))!,
              horaFin: _horaApi(r.valor('fin'))!,
              tieneAlmuerzo: r.valor('almuerzo') == 'sí',
              horaInicioAlmuerzo: r.valor('almuerzo') == 'sí'
                  ? _horaApi(r.valor('inicioAlmuerzo'))
                  : null,
              horaFinAlmuerzo: r.valor('almuerzo') == 'sí'
                  ? _horaApi(r.valor('finAlmuerzo'))
                  : null,
            ),
          );
        } else {
          await _horarios.crearHorario(
            CrearHorarioRequest(
              profesionalId: int.parse(r.valor('profesional')),
              diaSemana: dias.indexOf(r.nombre),
              horaInicio: _horaApi(r.valor('inicio'))!,
              horaFin: _horaApi(r.valor('fin'))!,
              tieneAlmuerzo: r.valor('almuerzo') == 'sí',
              horaInicioAlmuerzo: r.valor('almuerzo') == 'sí'
                  ? _horaApi(r.valor('inicioAlmuerzo'))
                  : null,
              horaFinAlmuerzo: r.valor('almuerzo') == 'sí'
                  ? _horaApi(r.valor('finAlmuerzo'))
                  : null,
            ),
          );
        }
      case Modulo.inasistencias:
        if (editar) {
          await _inasistencias.actualizarInasistencia(
            ActualizarInasistenciaRequest(
              id: r.id,
              fechaInicio: _periodo(r)['fechaInicio']!,
              fechaFin: _periodo(r)['fechaFin']!,
              motivo: int.tryParse(r.valor('motivoId')) ?? 4,
              observacion: r.valor('motivo'),
            ),
          );
        } else {
          await _inasistencias.crearInasistenciasMasivas(
            CrearInasistenciasMasivasRequest(
              profesionalId: int.parse(r.valor('profesional')),
              motivo: int.tryParse(r.valor('motivoId')) ?? 4,
              observacion: r.valor('motivo'),
              periodos: [_periodo(r)],
            ),
          );
        }
    }
    await _cargarModulo(modulo);
  }

  Map<String, String> _periodo(Registro r) => {
    'fechaInicio': '${_fechaApi(r.valor('desde'))}T00:00:00',
    'fechaFin': '${_fechaApi(r.valor('hasta'))}T23:59:59',
  };

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

  Future<List<Registro>> profesionalesPorServicio(String servicio) async {
    final filas = (await _profesionales.listarProfesionalesPorServicio(
      ListarProfesionalesPorServicioRequest(id: servicio),
    )).datos;
    return filas.map((fila) => _registro(Modulo.profesionales, fila)).toList();
  }

  Future<Registro> consultarRegistro(Modulo modulo, Registro registro) async {
    if (modulo == Modulo.clientes) {
      final respuesta = await _clientes.consultarCliente(
        ConsultarClienteRequest(documento: registro.valor('documento')),
      );
      return _cliente(respuesta.datos, registro);
    }
    final datos = switch (modulo) {
      Modulo.clientes => throw StateError('Los clientes usan un modelo tipado'),
      Modulo.especialidades => (await _especialidades.consultarEspecialidad(
        ConsultarEspecialidadRequest(id: registro.id),
      )).datos,
      Modulo.servicios => (await _servicios.consultarServicio(
        ConsultarServicioRequest(id: registro.id),
      )).datos,
      Modulo.profesionales => (await _profesionales.consultarProfesional(
        ConsultarProfesionalRequest(id: registro.id),
      )).datos,
      Modulo.horarios => (await _horarios.consultarHorario(
        ConsultarHorarioRequest(id: registro.id),
      )).datos,
      Modulo.inasistencias => (await _inasistencias.consultarInasistencia(
        ConsultarInasistenciaRequest(id: registro.id),
      )).datos,
    };
    final fila = datos is List ? datos.firstOrNull : datos;
    if (fila is! Map) throw const FormatException('Registro no disponible');
    final detalle = _registro(modulo, {
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

  Future<List<Registro>> consultarPorProfesional(
    Modulo modulo,
    String id,
  ) async {
    final filas = modulo == Modulo.horarios
        ? (await _horarios.listarHorariosPorProfesional(
            ListarHorariosPorProfesionalRequest(profesionalId: id),
          )).datos
        : (await _inasistencias.listarInasistencias(
            ListarInasistenciasRequest(profesionalId: id),
          )).datos;
    return filas
        .map((fila) => _registro(modulo, {'profesionalId': id, ...fila}))
        .toList();
  }

  Future<void> guardarHorarios(
    Registro jornada,
    Set<String> diasElegidos,
  ) async {
    final almuerzo = jornada.valor('almuerzo') == 'sí';
    await _horarios.crearHorariosMasivos(
      CrearHorariosMasivosRequest(
        profesionalId: int.parse(jornada.valor('profesional')),
        dias: diasElegidos.map(dias.indexOf).toList(),
        horaInicio: _horaApi(jornada.valor('inicio'))!,
        horaFin: _horaApi(jornada.valor('fin'))!,
        tieneAlmuerzo: almuerzo,
        horaInicioAlmuerzo: almuerzo
            ? _horaApi(jornada.valor('inicioAlmuerzo'))
            : null,
        horaFinAlmuerzo: almuerzo
            ? _horaApi(jornada.valor('finAlmuerzo'))
            : null,
      ),
    );
    await _cargarModulo(Modulo.horarios);
  }

  Future<Reserva> consultarReserva(Reserva actual) async {
    final datos = (await _apiReservas.consultarReserva(
      ConsultarReservaRequest(id: actual.id),
    )).datos;
    return _reserva(datos, anterior: actual);
  }

  Future<Object?> consultarAgenda(
    DateTime fecha, {
    String servicio = '',
    String profesional = '',
  }) async {
    if (servicio.isEmpty && profesional.isEmpty) return agendaDiaria(fecha);
    return (await _agenda.consultarDisponibilidad(
      ConsultarDisponibilidadRequest(
        fecha: _iso(fecha),
        servicioId: servicio.isEmpty ? null : servicio,
        profesionalId: profesional.isEmpty ? null : profesional,
      ),
    )).datos;
  }

  Future<List<String>> horasAgenda(
    DateTime fecha,
    String servicio, {
    String profesional = '',
  }) async {
    final datos = await consultarAgenda(
      fecha,
      servicio: servicio,
      profesional: profesional,
    );
    if (datos is! List) throw const FormatException('Disponibilidad inválida');
    return datos
        .map((fila) {
          final marca = DateTime.parse((fila as Map)['fecha'] as String);
          return _hora(marca.toIso8601String().split('T').last);
        })
        .toSet()
        .toList()
      ..sort();
  }

  Future<List<Map<String, dynamic>>> agendaDiaria(DateTime fecha) async =>
      (await _agenda.consultarAgendaDiaria(
        ConsultarAgendaDiariaRequest(fecha: _iso(fecha)),
      )).datos;

  Future<Cierre?> ultimoCierre() async {
    try {
      final datos = (await _liquidaciones.listarLiquidaciones(
        const ListarLiquidacionesRequest(ultimo: 'true'),
      )).datos;
      final fila = datos is List ? datos.firstOrNull : datos;
      if (fila == null) return null;
      final cierre = _cierre(Map<String, dynamic>.from(fila as Map));
      if (!_cierres.any((c) => c.id == cierre.id)) {
        _cierres = [..._cierres, cierre];
        notifyListeners();
      }
      return cierre;
    } on ErrorApi catch (error) {
      if (error.estado != 404) rethrow;
      return null;
    }
  }

  Future<void> eliminar(Modulo modulo, String id) async {
    await switch (modulo) {
      Modulo.clientes => _clientes.eliminarCliente(
        EliminarClienteRequest(id: id),
      ),
      Modulo.especialidades => _especialidades.eliminarEspecialidad(
        EliminarEspecialidadRequest(id: id),
      ),
      Modulo.servicios => _servicios.eliminarServicio(
        EliminarServicioRequest(id: id),
      ),
      Modulo.profesionales => _profesionales.eliminarProfesional(
        EliminarProfesionalRequest(id: id),
      ),
      Modulo.horarios => _horarios.eliminarHorario(
        EliminarHorarioRequest(id: id),
      ),
      Modulo.inasistencias => _inasistencias.eliminarInasistencia(
        EliminarInasistenciaRequest(id: id),
      ),
    };
    await _cargarModulo(modulo);
  }

  Future<List<Reserva>> consultarReservas({
    DateTime? desde,
    DateTime? hasta,
    String cliente = '',
    String servicio = '',
    String profesional = '',
  }) async {
    final filas = (await _apiReservas.listarReservas(
      ListarReservasRequest(
        fechaInicio: desde == null ? null : _iso(desde),
        fechaFin: hasta == null ? null : '${_iso(hasta)}T23:59:59',
        clienteId: cliente.isEmpty ? null : cliente,
        servicioId: servicio.isEmpty ? null : servicio,
        profesionalId: profesional.isEmpty ? null : profesional,
      ),
    )).datos;
    return filas.map(_reserva).toList();
  }

  Future<void> _cargarReservas() async {
    _reservas = await consultarReservas();
    notifyListeners();
  }

  Reserva _reserva(ReservaApi fila, {Reserva? anterior}) {
    final id = fila.id.isEmpty ? anterior?.id ?? '' : fila.id;
    final fecha = fila.fecha ?? anterior?.fecha;
    if (fecha == null || id.isEmpty)
      throw const FormatException('Reserva incompleta');
    final servicioId = fila.servicioId.isEmpty
        ? anterior?.servicioId ?? ''
        : fila.servicioId;
    final profesionalId = fila.profesionalId.isEmpty
        ? anterior?.profesionalId ?? ''
        : fila.profesionalId;
    final servicio = _registros[Modulo.servicios]
        ?.where((r) => r.id == servicioId)
        .firstOrNull;
    final profesional = _registros[Modulo.profesionales]
        ?.where((r) => r.id == profesionalId)
        .firstOrNull;
    final estado = fila.estado ?? anterior?.estado ?? '';
    return Reserva(
      id: id,
      clienteId: fila.clienteId.isEmpty
          ? anterior?.clienteId ?? ''
          : fila.clienteId,
      servicioId: servicioId,
      profesionalId: profesionalId,
      fecha: DateTime(fecha.year, fecha.month, fecha.day),
      hora: _hora(
        fila.horaInicio ??
            anterior?.hora ??
            fecha.toIso8601String().split('T').last,
      ),
      creada: fila.fechaCreacion ?? anterior?.creada ?? fecha,
      precio:
          (fila.precio ?? num.tryParse(servicio?.valor('precio') ?? '') ?? 0)
              .round(),
      duracion: int.tryParse(servicio?.valor('duracion') ?? '') ?? 0,
      comision: double.tryParse(profesional?.valor('comision') ?? '') ?? 0,
      estado: estado == '1' || estado.toLowerCase().startsWith('cancel')
          ? 'Cancelada'
          : _local.atendidas.contains(id)
          ? 'Atendida'
          : (estado.isEmpty || estado == '0')
          ? 'Programada'
          : estado,
      medioPago: _local.mediosPago[id] ?? '',
      motivo: fila.motivo,
    );
  }

  @override
  Future<void> guardarReserva(Reserva reserva) async {
    final id = int.tryParse(reserva.id);
    if (id != null && reserva.estado == 'Atendida') {
      _local.atendidas.add(reserva.id);
      _reservas = [for (final r in _reservas) r.id == reserva.id ? reserva : r];
      notifyListeners();
      return;
    }
    if (id != null && reserva.estado == 'Cancelada') {
      await _apiReservas.cancelarReserva(
        CancelarReservaRequest(id: '$id', motivoOtro: reserva.motivo),
      );
    } else {
      final fecha = '${_iso(reserva.fecha)}T${reserva.hora}:00';
      final servicioId = int.parse(reserva.servicioId);
      final clienteId = int.parse(reserva.clienteId);
      final datos = id == null
          ? (await _apiReservas.crearReserva(
              CrearReservaRequest(
                fecha: fecha,
                servicioId: servicioId,
                clienteId: clienteId,
              ),
            )).datos
          : (await _apiReservas.actualizarReserva(
              ActualizarReservaRequest(
                id: '$id',
                fecha: fecha,
                servicioId: servicioId,
                clienteId: clienteId,
                profesionalId: int.tryParse(reserva.profesionalId),
              ),
            )).datos;
      final nuevoId = id?.toString() ?? _idCreado(datos, 'reservaId');
      _local.mediosPago[nuevoId] = reserva.medioPago;
      ultimoIdReserva = nuevoId;
    }
    await _cargarReservas();
  }

  String? ultimoIdReserva;
  String? ultimoIdCierre;

  String _idCreado(Object? datos, String clave) {
    if (datos is List) datos = datos.firstOrNull;
    final id = _texto(
      datos is Map ? datos['id'] ?? datos[clave] ?? datos['reserva'] : datos,
    );
    if (int.tryParse(id) == null)
      throw const FormatException('Falta identificador creado');
    return id;
  }

  Future<void> _cargarCierres() async {
    List<Map<String, dynamic>> filas;
    try {
      final datos = (await _liquidaciones.listarLiquidaciones(
        const ListarLiquidacionesRequest(),
      )).datos;
      if (datos is! List) throw const FormatException('Se esperaba una lista');
      filas = datos
          .map((fila) => Map<String, dynamic>.from(fila as Map))
          .toList();
    } on ErrorApi catch (error) {
      if (error.estado != 404) rethrow;
      filas = [];
    }
    _cierres = filas.map(_cierre).toList();
    notifyListeners();
  }

  Cierre _cierre(Map<String, dynamic> fila) => Cierre(
    _texto(fila['id'] ?? fila['liquidacionComisionId']),
    DateTime.parse(_texto(fila['fechaInicio'])),
    DateTime.parse(_texto(fila['fechaFin'])),
    [],
    totalFacturado: num.tryParse(_texto(fila['totalFacturado']))?.round(),
    totalComisionesProfesionales: double.tryParse(
      _texto(fila['subtotalComisionProfesionales']),
    ),
  );

  @override
  Future<void> guardarCierre(Cierre cierre) async {
    final datos = (await _liquidaciones.crearLiquidacion(
      CrearLiquidacionRequest(
        fechaInicio: _iso(cierre.desde),
        fechaFin: _iso(cierre.hasta),
      ),
    )).datos;
    ultimoIdCierre = _idCreado(datos, 'liquidacionComisionId');
    await _cargarCierres();
  }
}
