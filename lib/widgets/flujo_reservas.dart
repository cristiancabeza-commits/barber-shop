import 'package:flutter/material.dart';

import '../repositories/repositorio_remoto.dart';
import '../models/datos_barberia.dart';
import '../controllers/estado_aplicacion.dart';
import '../controllers/disponibilidad_local.dart';
import 'componentes.dart';
import 'selector_busqueda.dart';
import 'catalogo_modulo.dart';
import 'campo_formulario.dart';

Reserva? reservaActual(BuildContext context, {String? estado}) {
  final arg = ModalRoute.of(context)?.settings.arguments;
  final id = arg is String ? arg : EstadoAplicacion.ultimaReservaId;
  final lista = EstadoAplicacion.repositorio.reservas;
  if (lista.isEmpty) return null;
  if (id != null && !lista.any((r) => r.id == id)) return null;
  return lista.firstWhere(
    (r) => r.id == id,
    orElse: () => estado == null
        ? lista.first
        : lista.firstWhere(
            (r) => r.estado == estado,
            orElse: () => lista.first,
          ),
  );
}

List<Widget> datosReserva(Reserva r) {
  final cliente = EstadoAplicacion.registro(Modulo.clientes, r.clienteId);
  final servicio = EstadoAplicacion.registro(Modulo.servicios, r.servicioId);
  final profesional = EstadoAplicacion.registro(
    Modulo.profesionales,
    r.profesionalId,
  );
  return [
    DatoVista('Cliente', cliente.nombre),
    DatoVista('Documento', cliente.valor('documento')),
    DatoVista('Celular', cliente.valor('celular')),
    DatoVista('Correo', cliente.valor('correo')),
    DatoVista('Servicio', servicio.nombre),
    DatoVista('Precio', dinero(r.precio)),
    DatoVista('Duración', '${r.duracion} minutos'),
    DatoVista('Profesional', profesional.nombre),
    DatoVista('Fecha', fechaTexto(r.fecha)),
    DatoVista('Hora', r.hora),
    DatoVista('Medio de pago', r.medioPago),
    DatoVista('Fecha de creación', fechaTexto(r.creada)),
    if (r.motivo.isNotEmpty) DatoVista('Motivo de cancelación', r.motivo),
  ];
}

class FormularioReserva extends StatefulWidget {
  const FormularioReserva({super.key, this.editar = false});
  final bool editar;
  @override
  State<FormularioReserva> createState() => _EstadoReserva();
}

class _EstadoReserva extends State<FormularioReserva> {
  final clave = GlobalKey<FormState>();
  final fecha = TextEditingController(
    text: fechaTexto(DateUtils.dateOnly(EstadoAplicacion.ahora())),
  );
  String? cliente, especialidad, servicio, profesional, hora;
  Reserva? original;
  bool iniciado = false, guardando = false;
  @override
  void dispose() {
    fecha.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (iniciado) return;
    original = widget.editar ? reservaActual(context) : null;
    if (!widget.editar) EstadoAplicacion.borrador = null;
    if (original != null) {
      cliente = original!.clienteId;
      servicio = original!.servicioId;
      profesional = original!.profesionalId;
      fecha.text = fechaTexto(original!.fecha);
      hora = original!.hora;
    }
    fecha.addListener(() {
      setState(() => hora = null);
      cargarHoras();
    });
    iniciado = true;
    if (original != null) {
      cargarProfesionales();
      cargarHoras();
    }
  }

  List<Registro> profesionalesRemotos = [];
  int consultaProfesionales = 0;

  Future<void> cargarProfesionales() async {
    final repositorio = EstadoAplicacion.repositorio;
    if (repositorio is! RepositorioRemoto) return;
    final consulta = ++consultaProfesionales;
    final id = servicio;
    if (id == null) return;
    try {
      final filas = await repositorio.profesionalesPorServicio(id);
      if (mounted && consulta == consultaProfesionales && servicio == id) {
        setState(() => profesionalesRemotos = filas);
      }
    } catch (_) {
      if (mounted && consulta == consultaProfesionales && servicio == id) {
        mostrarAviso(context, 'No se pudieron consultar los profesionales.');
      }
    }
  }

  List<String> horasRemotas = [];
  int consultaHoras = 0;
  bool consultandoHoras = false;

  Future<void> cargarHoras() async {
    final repositorio = EstadoAplicacion.repositorio;
    if (repositorio is! RepositorioRemoto) return;
    final consulta = ++consultaHoras;
    final dia = leerFecha(fecha.text);
    final servicioId = servicio;
    final profesionalId = profesional;
    setState(() {
      horasRemotas = [];
      consultandoHoras =
          dia != null &&
          servicioId != null &&
          (!widget.editar || profesionalId != null);
    });
    if (!consultandoHoras || dia == null || servicioId == null) return;
    try {
      final filas = await repositorio.horasAgenda(
        dia,
        servicioId,
        profesional: widget.editar ? profesionalId ?? '' : '',
      );
      if (mounted && consulta == consultaHoras)
        setState(() => horasRemotas = filas);
    } catch (_) {
      if (mounted && consulta == consultaHoras) {
        mostrarAviso(context, 'No se pudieron consultar los horarios.');
      }
    } finally {
      if (mounted && consulta == consultaHoras)
        setState(() => consultandoHoras = false);
    }
  }

  List<Registro> get profesionales {
    if (servicio == null) return [];
    if (EstadoAplicacion.repositorio is RepositorioRemoto) {
      return profesionalesRemotos.where((p) => p.activo).toList();
    }
    final e = EstadoAplicacion.registro(
      Modulo.servicios,
      servicio!,
    ).valor('especialidad');
    return EstadoAplicacion.repositorio
        .listar(Modulo.profesionales)
        .where((p) => p.activo && p.valor('especialidad') == e)
        .toList();
  }

  int get duracion => original != null && widget.editar
      ? original!.duracion
      : int.tryParse(
              EstadoAplicacion.registro(
                Modulo.servicios,
                servicio ?? '',
              ).valor('duracion'),
            ) ??
            0;
  List<String> horas(String id) => leerFecha(fecha.text) == null
      ? []
      : horasDisponibles(
          id,
          leerFecha(fecha.text)!,
          duracion,
          ignorar: widget.editar ? original?.id : null,
        );
  Future<void> continuar() async {
    if (guardando) return;
    if (!clave.currentState!.validate()) return;
    final fechaElegida = leerFecha(fecha.text)!;
    if (fechaElegida.isBefore(DateUtils.dateOnly(EstadoAplicacion.ahora()))) {
      mostrarAviso(context, 'Selecciona una fecha de hoy en adelante.');
      return;
    }
    final remoto = EstadoAplicacion.repositorio is RepositorioRemoto;
    final elegibles = profesionales
        .where(
          (p) =>
              (profesional == 'cualquiera' || p.id == profesional) &&
              (remoto ? horasRemotas : horas(p.id)).contains(hora),
        )
        .toList();
    if (elegibles.isEmpty) {
      mostrarAviso(context, 'Selecciona un horario disponible.');
      return;
    }
    final asignado = elegibles.first;
    final s = EstadoAplicacion.registro(Modulo.servicios, servicio!);
    final reserva = Reserva(
      id: widget.editar ? original!.id : '',
      clienteId: cliente!,
      servicioId: servicio!,
      profesionalId: asignado.id,
      fecha: fechaElegida,
      hora: hora!,
      creada: original?.creada ?? EstadoAplicacion.ahora(),
      precio: widget.editar ? original!.precio : int.parse(s.valor('precio')),
      duracion: duracion,
      comision: double.tryParse(asignado.valor('comision')) ?? 0,
      medioPago: original?.medioPago ?? 'Efectivo',
    );
    if (!widget.editar) {
      EstadoAplicacion.borrador = reserva;
      Navigator.pushNamed(context, '/confirmar-reserva');
      return;
    }
    setState(() => guardando = true);
    try {
      await EstadoAplicacion.repositorio.guardarReserva(reserva);
      if (!mounted) return;
      EstadoAplicacion.ultimaReservaId = reserva.id;
      mostrarAviso(context, 'Reserva actualizada.');
      Navigator.pop(context);
    } catch (_) {
      if (mounted) mostrarAviso(context, 'No se pudo actualizar la reserva.');
    } finally {
      if (mounted) setState(() => guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.editar && (original == null || original!.estado != 'Programada'))
      return const EstructuraPantalla(
        title: 'Reagendar reserva',
        children: [Text('La reserva no está disponible para reagendar.')],
      );
    final servicios = EstadoAplicacion.repositorio
        .listar(Modulo.servicios)
        .where(
          (s) =>
              s.activo &&
              (especialidad == null ||
                  especialidad!.isEmpty ||
                  s.valor('especialidad') == especialidad),
        );
    final remoto = EstadoAplicacion.repositorio is RepositorioRemoto;
    final disponibles = remoto
        ? horasRemotas
        : (<String>{
            for (final p in profesionales)
              if (profesional == 'cualquiera' || p.id == profesional)
                ...horas(p.id),
          }.toList()..sort());
    return Form(
      key: clave,
      child: EstructuraPantalla(
        title: widget.editar ? 'Reagendar reserva' : 'Nueva reserva',
        active: widget.editar ? 1 : 2,
        children: [
          if (widget.editar && original != null)
            Tarjeta(
              children: [
                DatoVista(
                  'Cliente',
                  EstadoAplicacion.registro(Modulo.clientes, cliente!).nombre,
                ),
                DatoVista(
                  'Servicio',
                  EstadoAplicacion.registro(Modulo.servicios, servicio!).nombre,
                ),
              ],
            )
          else ...[
            SelectorBusqueda(
              etiqueta: 'Cliente *',
              opciones: opcionesModulo(Modulo.clientes),
              valor: cliente,
              obligatorio: true,
              onChanged: (v) => setState(() => cliente = v),
            ),
            OutlinedButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(
                    context,
                    '/nuevo-cliente',
                    arguments: const {'volver': true},
                  ).then((_) {
                    if (mounted) setState(() {});
                  }),
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Crear cliente'),
            ),
            SelectorBusqueda(
              etiqueta: 'Especialidad',
              opciones: [
                const OpcionBusqueda('', 'Todas'),
                ...opcionesModulo(Modulo.especialidades, soloActivos: true),
              ],
              valor: especialidad ?? '',
              onChanged: (v) => setState(() {
                especialidad = v;
                servicio = null;
                profesional = null;
                hora = null;
                cargarHoras();
              }),
            ),
            SelectorBusqueda(
              etiqueta: 'Servicio *',
              opciones: servicios
                  .map(
                    (s) => OpcionBusqueda(
                      s.id,
                      s.nombre,
                      detalle:
                          '${dinero(int.parse(s.valor('precio')))} · ${s.valor('duracion')} min',
                    ),
                  )
                  .toList(),
              valor: servicio,
              obligatorio: true,
              onChanged: (v) => setState(() {
                servicio = v;
                profesional = remoto ? 'cualquiera' : null;
                hora = null;
                profesionalesRemotos = [];
                cargarProfesionales();
                cargarHoras();
              }),
            ),
          ],
          if (!remoto || widget.editar)
            SelectorBusqueda(
              etiqueta: 'Profesional',
              opciones: [
                if (!remoto) const OpcionBusqueda('cualquiera', 'Cualquiera'),
                ...profesionales.map(
                  (p) => OpcionBusqueda(
                    p.id,
                    p.nombre,
                    detalle: 'Documento: ${p.valor('documento')}',
                  ),
                ),
              ],
              valor: profesional,
              obligatorio: true,
              onChanged: (v) => setState(() {
                profesional = v;
                hora = null;
                cargarHoras();
              }),
            ),
          CampoFormulario(
            widget.editar ? 'Nueva fecha *' : 'Fecha *',
            fecha,
            tipo: 'fecha',
            validar: (v) => leerFecha(v ?? '') == null
                ? 'Selecciona una fecha válida'
                : null,
          ),
          const TituloSeccion('Hora disponible'),
          if (consultandoHoras) const LinearProgressIndicator(),
          FormField<String>(
            key: ValueKey('hora:$hora:${disponibles.join()}'),
            initialValue: hora,
            validator: (_) => hora == null || !disponibles.contains(hora)
                ? 'Selecciona una hora disponible'
                : null,
            builder: (campo) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (disponibles.isEmpty)
                  Text(
                    servicio == null || profesional == null
                        ? 'Selecciona servicio y profesional para consultar horarios.'
                        : 'No hay horarios para esta selección. Cambia fecha, servicio o profesional.',
                  ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: disponibles
                      .map(
                        (h) => ChoiceChip(
                          label: Text(h),
                          selected: h == hora,
                          onSelected: (_) => setState(() => hora = h),
                        ),
                      )
                      .toList(),
                ),
                if (campo.errorText != null)
                  Text(
                    campo.errorText!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
              ],
            ),
          ),
          FilledButton(
            onPressed: guardando ? null : continuar,
            child: Text(widget.editar ? 'GUARDAR CAMBIOS' : 'CONTINUAR'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCELAR'),
          ),
        ],
      ),
    );
  }
}

class ConfirmacionReserva extends StatefulWidget {
  const ConfirmacionReserva({super.key});
  @override
  State<ConfirmacionReserva> createState() => _EstadoConfirmacion();
}

class _EstadoConfirmacion extends State<ConfirmacionReserva> {
  String medio = 'Efectivo';
  bool guardando = false;
  Future<void> confirmar() async {
    if (guardando) return;
    final borrador = EstadoAplicacion.borrador;
    if (borrador == null) return;
    if (EstadoAplicacion.repositorio is! RepositorioRemoto &&
        !horasDisponibles(
          borrador.profesionalId,
          borrador.fecha,
          borrador.duracion,
        ).contains(borrador.hora)) {
      mostrarAviso(
        context,
        'Ese horario ya no está disponible. Regresa y selecciona otro.',
      );
      return;
    }
    setState(() => guardando = true);
    try {
      final r = borrador.copiar(
        id: EstadoAplicacion.nuevoId('R'),
        medioPago: medio,
      );
      await EstadoAplicacion.repositorio.guardarReserva(r);
      final repositorio = EstadoAplicacion.repositorio;
      EstadoAplicacion.ultimaReservaId = repositorio is RepositorioRemoto
          ? repositorio.ultimoIdReserva
          : r.id;
      EstadoAplicacion.borrador = null;
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/reserva-creada',
        arguments: EstadoAplicacion.ultimaReservaId,
      );
    } catch (_) {
      if (mounted)
        mostrarAviso(
          context,
          'No se pudo crear la reserva. Inténtalo de nuevo.',
        );
    } finally {
      if (mounted) setState(() => guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = EstadoAplicacion.borrador;
    return EstructuraPantalla(
      title: 'Confirmar reserva',
      active: 2,
      children: [
        if (r == null) ...[
          const Text('No hay una reserva pendiente de confirmar.'),
          const BotonVista('Nueva reserva', route: '/nueva-reserva'),
        ] else ...[
          Tarjeta(children: datosReserva(r.copiar(medioPago: medio))),
          const TituloSeccion('Medio de pago'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Efectivo', 'Transferencia']
                .map(
                  (v) => ChoiceChip(
                    label: Text(v),
                    selected: medio == v,
                    onSelected: (_) => setState(() => medio = v),
                  ),
                )
                .toList(),
          ),
          FilledButton(
            onPressed: guardando ? null : confirmar,
            child: Text(guardando ? 'Confirmando…' : 'CONFIRMAR RESERVA'),
          ),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('VOLVER A EDITAR'),
          ),
        ],
      ],
    );
  }
}

class DetalleReserva extends StatefulWidget {
  const DetalleReserva({super.key, this.estado, this.exito = false});
  final String? estado;
  final bool exito;
  @override
  State<DetalleReserva> createState() => _EstadoDetalleReserva();
}

class _EstadoDetalleReserva extends State<DetalleReserva> {
  bool consultada = false;
  Future<Reserva>? detalle;
  Reserva? reservaRemota;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (consultada) return;
    consultada = true;
    final repositorio = EstadoAplicacion.repositorio;
    final reserva = reservaActual(context, estado: widget.estado);
    if (repositorio is RepositorioRemoto && reserva != null) {
      reservaRemota = reserva;
      detalle = repositorio.consultarReserva(reserva);
    }
  }

  Future<void> cancelar(BuildContext context, Reserva r) async {
    final controlador = TextEditingController();
    final clave = GlobalKey<FormState>();
    final motivo = await showDialog<String>(
      context: context,
      builder: (dialogo) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        scrollable: true,
        title: const Text('Cancelar reserva'),
        content: Form(
          key: clave,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¿Quieres cancelar la reserva de ${EstadoAplicacion.registro(Modulo.clientes, r.clienteId).nombre}?',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controlador,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Motivo de cancelación *',
                ),
                validator: requerido,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogo),
            child: const Text('No, Volver'),
          ),
          FilledButton(
            onPressed: () {
              if (clave.currentState!.validate())
                Navigator.pop(dialogo, controlador.text.trim());
            },
            child: const Text('Sí, Cancelar'),
          ),
        ],
      ),
    );
    // El diálogo mantiene sus campos hasta terminar la animación de salida.
    Future<void>.delayed(
      const Duration(milliseconds: 400),
      controlador.dispose,
    );
    if (motivo == null || !context.mounted) return;
    try {
      await EstadoAplicacion.repositorio.guardarReserva(
        r.copiar(estado: 'Cancelada', motivo: motivo),
      );
      if (context.mounted) {
        final repositorio = EstadoAplicacion.repositorio;
        final cancelada = repositorio.reservas.any(
          (reserva) => reserva.id == r.id && reserva.estado == 'Cancelada',
        );
        mostrarAviso(
          context,
          cancelada
              ? 'Reserva cancelada.'
              : 'Solicitud de cancelación enviada.',
        );
      }
    } catch (_) {
      if (context.mounted)
        mostrarAviso(context, 'No se pudo cancelar la reserva.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final consulta = detalle;
    if (consulta == null) return contenido();
    return FutureBuilder<Reserva>(
      future: consulta,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const EstructuraPantalla(
            title: 'Detalle de Reserva',
            children: [Center(child: CircularProgressIndicator())],
          );
        }
        if (snapshot.hasError) {
          return EstructuraPantalla(
            title: 'Detalle de Reserva',
            children: [
              TextButton(
                onPressed: () {
                  final repositorio = EstadoAplicacion.repositorio;
                  final reserva = reservaActual(context, estado: widget.estado);
                  if (repositorio is RepositorioRemoto && reserva != null) {
                    setState(() {
                      reservaRemota = reserva;
                      detalle = repositorio.consultarReserva(reserva);
                    });
                  }
                },
                child: const Text('No se pudo consultar. Reintentar'),
              ),
            ],
          );
        }
        return contenido(snapshot.data);
      },
    );
  }

  Widget contenido([Reserva? obtenida]) => ListenableBuilder(
    listenable: EstadoAplicacion.repositorio,
    builder: (context, _) {
      final actual = reservaActual(context, estado: widget.estado);
      final r = actual == null
          ? null
          : identical(actual, reservaRemota)
          ? obtenida ?? actual
          : actual;
      return EstructuraPantalla(
        title: widget.exito ? 'Reserva creada' : 'Detalle de Reserva',
        active: 1,
        children: [
          if (widget.exito) const Text('Reserva creada correctamente.'),
          if (r == null)
            const Text('No se encontró la reserva.')
          else ...[
            TituloSeccion('Reserva #${r.id}'),
            EtiquetaEstado(r.estado),
            Tarjeta(children: datosReserva(r)),
            if (r.estado == 'Programada') ...[
              FilledButton(
                onPressed: () async {
                  try {
                    await EstadoAplicacion.repositorio.guardarReserva(
                      r.copiar(estado: 'Atendida'),
                    );
                    if (context.mounted)
                      mostrarAviso(context, 'Servicio marcado como atendido.');
                  } catch (_) {
                    if (context.mounted)
                      mostrarAviso(
                        context,
                        'No se pudo confirmar la asistencia.',
                      );
                  }
                },
                child: const Text('CONFIRMAR ASISTENCIA'),
              ),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/reagendar-reserva',
                  arguments: r.id,
                ),
                child: const Text('REAGENDAR'),
              ),
              OutlinedButton(
                onPressed: () => cancelar(context, r),
                child: const Text('CANCELAR RESERVA'),
              ),
            ],
            if (widget.exito)
              OutlinedButton(
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  '/detalle-reserva',
                  arguments: r.id,
                ),
                child: const Text('VER DETALLE'),
              ),
          ],
          if (widget.exito && r != null) ...[
            OutlinedButton(
              onPressed: () => Navigator.of(context)
                  .pushNamedAndRemoveUntil('/inicio-principal', (_) => false),
              child: const Text('IR AL INICIO'),
            ),
            OutlinedButton(
              onPressed: () => Navigator.pushReplacementNamed(
                context,
                '/agenda',
                arguments: r.fecha,
              ),
              child: const Text('VOLVER A AGENDA'),
            ),
          ] else
            const BotonVista(
              'VOLVER A AGENDA',
              route: '/agenda',
              secondary: true,
            ),
        ],
      );
    },
  );
}
