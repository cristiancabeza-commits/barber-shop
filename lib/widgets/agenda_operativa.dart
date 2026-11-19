import 'package:flutter/material.dart';

import '../controllers/estado_aplicacion.dart';
import '../repositories/repositorio_remoto.dart';
import '../repositories/repositorio_barberia.dart';
import '../models/datos_barberia.dart';
import 'componentes.dart';
import 'catalogo_modulo.dart';
import 'selector_busqueda.dart';
import 'campo_formulario.dart';

class AgendaOperativa extends StatefulWidget {
  const AgendaOperativa({
    super.key,
    this.calendario = false,
    this.misServicios = false,
  });
  final bool calendario, misServicios;
  @override
  State<AgendaOperativa> createState() => _EstadoAgenda();
}

class _EstadoAgenda extends State<AgendaOperativa> {
  final desde = TextEditingController(), hasta = TextEditingController();
  String cliente = '', servicio = '', profesional = '', estado = 'Todas';
  late bool calendario;
  DateTime? dia;
  late final RepositorioBarberia repositorioActual;
  int versionConsulta = 0;
  bool argumentosLeidos = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (argumentosLeidos) return;
    argumentosLeidos = true;
    final fecha = ModalRoute.of(context)?.settings.arguments;
    if (fecha is DateTime) {
      desde.text = fechaTexto(fecha);
      hasta.text = fechaTexto(fecha);
    }
  }

  void invalidarConsulta() {
    versionConsulta++;
    consulta = null;
    consultando = false;
  }

  void actualizarRepositorio() => setState(invalidarConsulta);
  Future<List<Map<String, dynamic>>>? agendaDelDia;

  void seleccionarDia(DateTime fecha) {
    final repositorio = EstadoAplicacion.repositorio;
    setState(() {
      dia = fecha;
      agendaDelDia = repositorio is RepositorioRemoto
          ? repositorio.agendaDiaria(fecha)
          : null;
    });
  }

  Widget bloquesAgenda() => FutureBuilder<List<Map<String, dynamic>>>(
    future: agendaDelDia,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const LinearProgressIndicator();
      }
      if (snapshot.hasError) {
        return TextButton(
          onPressed: () => seleccionarDia(dia!),
          child: const Text('No se pudo consultar el día. Reintentar'),
        );
      }
      final grupos = (snapshot.data ?? []).where(
        (fila) =>
            profesional.isEmpty ||
            fila['profesionalId'].toString() == profesional,
      );
      if (grupos.isEmpty) return const Text('No hay jornadas para este día.');
      return Column(
        children: [
          for (final grupo in grupos)
            TarjetaRegistro(
              grupo['profesionalNombre']?.toString() ?? 'Profesional',
              '${grupo['totalDisponibles']} bloques disponibles · ${grupo['totalOcupados']} ocupados',
            ),
        ],
      );
    },
  );
  List<Reserva>? consulta;
  bool consultando = false;

  Future<void> consultar(RepositorioRemoto repositorio) async {
    final inicio = leerFecha(desde.text), fin = leerFecha(hasta.text);
    if (inicio == null || fin == null || fin.isBefore(inicio)) return;
    final version = ++versionConsulta;
    setState(() => consultando = true);
    try {
      final filas = await repositorio.consultarReservas(
        desde: inicio,
        hasta: fin,
        cliente: cliente,
        servicio: servicio,
        profesional: profesional,
      );
      if (mounted && version == versionConsulta)
        setState(() => consulta = filas);
    } catch (_) {
      if (mounted && version == versionConsulta)
        mostrarAviso(context, 'No se pudo consultar la agenda.');
    } finally {
      if (mounted && version == versionConsulta)
        setState(() => consultando = false);
    }
  }

  @override
  void initState() {
    super.initState();
    repositorioActual = EstadoAplicacion.repositorio;
    repositorioActual.addListener(actualizarRepositorio);
    final hoy = EstadoAplicacion.ahora();
    desde.text = fechaTexto(DateTime(hoy.year, hoy.month, 1));
    hasta.text = fechaTexto(DateTime(hoy.year, hoy.month + 1, 0));
    calendario = widget.calendario;
    if (widget.misServicios) {
      if (EstadoAplicacion.repositorio is! RepositorioRemoto)
        profesional = 'P-001';
      estado = 'Atendida';
    }
    desde.addListener(actualizar);
    hasta.addListener(actualizar);
  }

  void actualizar() => setState(() {
    dia = null;
    invalidarConsulta();
  });
  @override
  void dispose() {
    repositorioActual.removeListener(actualizarRepositorio);
    desde.dispose();
    hasta.dispose();
    super.dispose();
  }

  Widget filtro(
    String nombre,
    Modulo modulo,
    String valor,
    ValueChanged<String> cambiar,
  ) => SelectorBusqueda(
    etiqueta: nombre,
    opciones: [const OpcionBusqueda('', 'Todos'), ...opcionesModulo(modulo)],
    valor: valor,
    onChanged: (v) => setState(() {
      cambiar(v ?? '');
      invalidarConsulta();
    }),
  );
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: EstadoAplicacion.repositorio,
    builder: (context, _) {
      final inicio = leerFecha(desde.text), fin = leerFecha(hasta.text);
      final rangoValido =
          inicio != null && fin != null && !fin.isBefore(inicio);
      final repositorio = EstadoAplicacion.repositorio;
      final registros =
          (consulta ?? repositorio.reservas)
              .where(
                (r) =>
                    rangoValido &&
                    !r.fecha.isBefore(inicio) &&
                    !r.fecha.isAfter(fin) &&
                    (dia == null || DateUtils.isSameDay(dia, r.fecha)) &&
                    (cliente.isEmpty || cliente == r.clienteId) &&
                    (servicio.isEmpty || servicio == r.servicioId) &&
                    (profesional.isEmpty || profesional == r.profesionalId) &&
                    (estado == 'Todas' || estado == r.estado),
              )
              .toList()
            ..sort(
              (a, b) => a.fecha.compareTo(b.fecha) != 0
                  ? a.fecha.compareTo(b.fecha)
                  : a.hora.compareTo(b.hora),
            );
      final atendidas = registros.where((r) => r.estado == 'Atendida');
      final base = atendidas.fold<int>(0, (s, r) => s + r.precio);
      final comision = atendidas.fold<double>(
        0,
        (s, r) => s + r.precio * r.comision / 100,
      );
      return EstructuraPantalla(
        title: widget.misServicios
            ? 'Mis servicios y comisiones'
            : calendario
            ? 'Agenda · Calendario'
            : 'Agenda',
        active: widget.misServicios ? 3 : 1,
        children: [
          if (!widget.misServicios)
            const BotonVista('+ Nueva Reserva', route: '/nueva-reserva'),
          OutlinedButton(
            onPressed: () => setState(() {
              calendario = !calendario;
              dia = null;
            }),
            child: Text(calendario ? 'Ver lista' : 'Calendario'),
          ),
          CampoFormulario('Fecha inicial', desde, tipo: 'fecha'),
          CampoFormulario('Fecha final', hasta, tipo: 'fecha'),
          if (!rangoValido)
            Text(
              'La fecha final debe ser igual o posterior a la inicial.',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          filtro('Cliente', Modulo.clientes, cliente, (v) => cliente = v),
          filtro('Servicio', Modulo.servicios, servicio, (v) => servicio = v),
          filtro(
            'Profesional',
            Modulo.profesionales,
            profesional,
            (v) => profesional = v,
          ),
          if (repositorio is RepositorioRemoto)
            OutlinedButton(
              onPressed: !rangoValido || consultando
                  ? null
                  : () => consultar(repositorio),
              child: Text(consultando ? 'Consultando…' : 'Consultar agenda'),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Todas', 'Programada', 'Atendida', 'Cancelada']
                .map(
                  (v) => ChoiceChip(
                    label: Text(v),
                    selected: estado == v,
                    onSelected: (_) => setState(() => estado = v),
                  ),
                )
                .toList(),
          ),
          TextButton(
            onPressed: () => setState(() {
              final hoy = EstadoAplicacion.ahora();
              desde.text = fechaTexto(DateTime(hoy.year, hoy.month, 1));
              hasta.text = fechaTexto(DateTime(hoy.year, hoy.month + 1, 0));
              cliente = '';
              servicio = '';
              profesional = '';
              estado = 'Todas';
              consulta = null;
              dia = null;
            }),
            child: const Text('Limpiar filtros'),
          ),
          if (calendario)
            CalendarDatePicker(
              initialDate: dia ?? DateUtils.dateOnly(EstadoAplicacion.ahora()),
              firstDate: DateTime(1900),
              lastDate: DateTime(2035, 12, 31),
              onDateChanged: seleccionarDia,
            ),
          if (calendario && dia != null)
            TituloSeccion('Reservas del ${fechaTexto(dia!)}'),
          if (calendario && dia != null && agendaDelDia != null)
            bloquesAgenda(),
          if (widget.misServicios)
            Tarjeta(
              children: [
                DatoVista('Servicios realizados', '${atendidas.length}'),
                DatoVista('Base del periodo', dinero(base)),
                DatoVista('Comisión del periodo', dinero(comision)),
              ],
            ),
          if (registros.isEmpty)
            const Text('No encontramos resultados para estos filtros.'),
          ...registros.map(
            (r) => TarjetaRegistro(
              EstadoAplicacion.registro(Modulo.clientes, r.clienteId).nombre,
              '${EstadoAplicacion.registro(Modulo.servicios, r.servicioId).nombre} · ${EstadoAplicacion.registro(Modulo.profesionales, r.profesionalId).nombre}\n${fechaTexto(r.fecha)} · ${r.hora}${widget.misServicios ? '\nValor ${dinero(r.precio)} · Comisión ${dinero(r.precio * r.comision / 100)}' : ''}',
              status: r.estado,
              route: '/detalle-reserva',
              argumentos: r.id,
            ),
          ),
        ],
      );
    },
  );
}
