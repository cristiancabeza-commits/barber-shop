import 'package:flutter/material.dart';

import '../controllers/estado_aplicacion.dart';
import '../repositories/repositorio_remoto.dart';
import '../models/datos_barberia.dart';
import 'componentes.dart';
import 'selector_busqueda.dart';
import 'catalogo_modulo.dart';
import 'campo_formulario.dart';

Cierre? cierreActual(BuildContext context) {
  final arg = ModalRoute.of(context)?.settings.arguments;
  final id = arg is String
      ? arg
      : arg is Map
      ? arg['cierre']
      : EstadoAplicacion.ultimoCierreId;
  final lista = EstadoAplicacion.repositorio.cierres;
  if (lista.isEmpty) return null;
  if (id != null && !lista.any((c) => c.id == id)) return null;
  return lista.firstWhere((c) => c.id == id, orElse: () => lista.last);
}

List<Widget> datosCierre(Cierre c) => [
  TituloSeccion('Cierre #${c.id}'),
  DatoVista('Periodo', '${fechaTexto(c.desde)}–${fechaTexto(c.hasta)}'),
  DatoVista('Servicios', '${c.reservas.length}'),
  DatoVista(
    'Profesionales',
    c.profesionales
        .map((id) => EstadoAplicacion.registro(Modulo.profesionales, id).nombre)
        .join(', '),
  ),
  DatoVista('Total', dinero(c.total)),
  DatoVista('Comisiones', dinero(c.comisiones)),
  DatoVista('Total centro', dinero(c.total - c.comisiones)),
];

class HistorialCierres extends StatefulWidget {
  const HistorialCierres({super.key});
  @override
  State<HistorialCierres> createState() => _EstadoHistorial();
}

class _EstadoHistorial extends State<HistorialCierres> {
  String ano = '', mes = '';
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: EstadoAplicacion.repositorio,
    builder: (context, _) {
      final todos = EstadoAplicacion.repositorio.cierres;
      final registros = todos.where(
        (c) =>
            (ano.isEmpty || c.desde.year.toString() == ano) &&
            (mes.isEmpty || c.desde.month.toString() == mes),
      );
      final anos = todos.map((c) => c.desde.year).toSet().toList()..sort();
      return EstructuraPantalla(
        title: 'Cierre de caja',
        children: [
          SelectorBusqueda(
            etiqueta: 'Año',
            opciones: [
              const OpcionBusqueda('', 'Todos'),
              ...anos.map((a) => OpcionBusqueda('$a', '$a')),
            ],
            valor: ano,
            onChanged: (v) => setState(() => ano = v ?? ''),
          ),
          SelectorBusqueda(
            etiqueta: 'Mes',
            opciones: [
              const OpcionBusqueda('', 'Todos'),
              for (var m = 1; m <= 12; m++)
                OpcionBusqueda(
                  '$m',
                  [
                    'Enero',
                    'Febrero',
                    'Marzo',
                    'Abril',
                    'Mayo',
                    'Junio',
                    'Julio',
                    'Agosto',
                    'Septiembre',
                    'Octubre',
                    'Noviembre',
                    'Diciembre',
                  ][m - 1],
                ),
            ],
            valor: mes,
            onChanged: (v) => setState(() => mes = v ?? ''),
          ),
          const BotonVista('NUEVO CIERRE DE PERIODO', route: '/nuevo-cierre'),
          if (EstadoAplicacion.repositorio
              case final RepositorioRemoto repositorio)
            OutlinedButton(
              onPressed: () async {
                try {
                  final cierre = await repositorio.ultimoCierre();
                  if (!context.mounted) return;
                  if (cierre == null) {
                    mostrarAviso(context, 'Aún no hay cierres.');
                  } else {
                    Navigator.pushNamed(
                      context,
                      '/detalle-cierre',
                      arguments: cierre.id,
                    );
                  }
                } catch (_) {
                  if (context.mounted)
                    mostrarAviso(
                      context,
                      'No se pudo consultar el último cierre.',
                    );
                }
              },
              child: const Text('Ver último cierre'),
            ),

          if (registros.isEmpty)
            const Text('No encontramos resultados para ese periodo.'),
          TextButton(
            onPressed: () => setState(() {
              ano = '';
              mes = '';
            }),
            child: const Text('Limpiar filtros'),
          ),
          ...registros.map(
            (c) => TarjetaRegistro(
              'Cierre #${c.id}',
              EstadoAplicacion.repositorio is RepositorioRemoto
                  ? '${fechaTexto(c.desde)}–${fechaTexto(c.hasta)} · Total ${dinero(c.total)}'
                  : '${fechaTexto(c.desde)}–${fechaTexto(c.hasta)} · ${c.reservas.length} servicios\nTotal: ${dinero(c.total)}\nProfesionales: ${c.profesionales.map((id) => EstadoAplicacion.registro(Modulo.profesionales, id).nombre).join(', ')}',
              route: '/detalle-cierre',
              argumentos: c.id,
            ),
          ),
        ],
      );
    },
  );
}

class CrearCierre extends StatefulWidget {
  const CrearCierre({super.key});
  @override
  State<CrearCierre> createState() => _EstadoCrearCierre();
}

class _EstadoCrearCierre extends State<CrearCierre> {
  final clave = GlobalKey<FormState>();
  final desde = TextEditingController(
        text: fechaTexto(DateUtils.dateOnly(EstadoAplicacion.ahora())),
      ),
      hasta = TextEditingController(
        text: fechaTexto(DateUtils.dateOnly(EstadoAplicacion.ahora())),
      );
  @override
  void dispose() {
    desde.dispose();
    hasta.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Form(
    key: clave,
    child: EstructuraPantalla(
      title: 'Nuevo cierre de periodo',
      children: [
        CampoFormulario(
          'Fecha inicial *',
          desde,
          tipo: 'fecha',
          validar: (v) =>
              leerFecha(v ?? '') == null ? 'Selecciona una fecha válida' : null,
        ),
        CampoFormulario(
          'Fecha final *',
          hasta,
          tipo: 'fecha',
          validar: (v) {
            final a = leerFecha(desde.text), b = leerFecha(v ?? '');
            return b == null || a == null || b.isBefore(a)
                ? 'La fecha final debe ser igual o posterior a la inicial'
                : null;
          },
        ),
        Text(
          EstadoAplicacion.repositorio is RepositorioRemoto
              ? 'La liquidación se calcula al confirmar el periodo.'
              : 'Solo se incluyen servicios atendidos que no pertenecen a otro cierre.',
        ),
        FilledButton(
          onPressed: () {
            if (!clave.currentState!.validate()) return;
            final a = leerFecha(desde.text)!, b = leerFecha(hasta.text)!;
            final cerradas = EstadoAplicacion.repositorio.cierres
                .expand((c) => c.reservas)
                .map((r) => r.id)
                .toSet();
            final reservas = EstadoAplicacion.repositorio.reservas
                .where(
                  (r) =>
                      r.estado == 'Atendida' &&
                      !r.fecha.isBefore(a) &&
                      !r.fecha.isAfter(b) &&
                      !cerradas.contains(r.id),
                )
                .toList();
            if (reservas.isEmpty &&
                EstadoAplicacion.repositorio is! RepositorioRemoto) {
              mostrarAviso(
                context,
                'No hay servicios atendidos sin cerrar en ese periodo.',
              );
              return;
            }
            EstadoAplicacion.borradorCierre = Cierre('', a, b, reservas);
            Navigator.pushNamed(context, '/confirmar-cierre');
          },
          child: const Text('Revisar resumen'),
        ),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
      ],
    ),
  );
}

class ResumenCierre extends StatefulWidget {
  const ResumenCierre({super.key, this.confirmar = false});
  final bool confirmar;
  @override
  State<ResumenCierre> createState() => _EstadoResumenCierre();
}

class _EstadoResumenCierre extends State<ResumenCierre> {
  bool guardando = false;
  Future<void> confirmar(Cierre c) async {
    if (guardando) return;
    setState(() => guardando = true);
    try {
      final nuevo = Cierre(
        EstadoAplicacion.nuevoId('C'),
        c.desde,
        c.hasta,
        c.reservas,
      );
      await EstadoAplicacion.repositorio.guardarCierre(nuevo);
      final repositorio = EstadoAplicacion.repositorio;
      final id = repositorio is RepositorioRemoto
          ? repositorio.ultimoIdCierre
          : nuevo.id;
      EstadoAplicacion.ultimoCierreId = id;
      EstadoAplicacion.borradorCierre = null;
      if (!mounted) return;
      mostrarAviso(context, 'Cierre guardado.');
      Navigator.pushReplacementNamed(context, '/detalle-cierre', arguments: id);
    } catch (e) {
      if (mounted)
        mostrarAviso(
          context,
          e is StateError
              ? e.message.toString()
              : 'No se pudo guardar el cierre.',
        );
    } finally {
      if (mounted) setState(() => guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.confirmar
        ? EstadoAplicacion.borradorCierre
        : cierreActual(context);
    return EstructuraPantalla(
      title: widget.confirmar ? 'Confirmar cierre' : 'Detalle del cierre',
      children: [
        if (c == null)
          const Text('No hay un cierre para mostrar.')
        else ...[
          Tarjeta(
            children: EstadoAplicacion.repositorio is RepositorioRemoto
                ? [
                    if (!widget.confirmar) TituloSeccion('Cierre #${c.id}'),
                    DatoVista(
                      'Periodo',
                      '${fechaTexto(c.desde)}–${fechaTexto(c.hasta)}',
                    ),
                    if (!widget.confirmar) ...[
                      DatoVista('Total facturado', dinero(c.total)),
                      DatoVista('Comisiones', dinero(c.comisiones)),
                      DatoVista('Total centro', dinero(c.total - c.comisiones)),
                    ],
                  ]
                : datosCierre(c),
          ),
          if (widget.confirmar) ...[
            FilledButton(
              onPressed: guardando ? null : () => confirmar(c),
              child: Text(guardando ? 'Guardando…' : 'Confirmar cierre'),
            ),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Corregir periodo'),
            ),
          ] else
            FilledButton(
              onPressed: () => Navigator.pushNamed(
                context,
                '/consulta-comisiones',
                arguments: c.id,
              ),
              child: const Text('Consultar comisiones'),
            ),
        ],
        const BotonVista(
          'Volver al historial',
          route: '/cierres-caja',
          secondary: true,
        ),
      ],
    );
  }
}

class ConsultaComisiones extends StatefulWidget {
  const ConsultaComisiones({super.key, this.detalle = false});
  final bool detalle;
  @override
  State<ConsultaComisiones> createState() => _EstadoComisiones();
}

class _EstadoComisiones extends State<ConsultaComisiones> {
  String? cierre;
  String profesional = '';
  bool iniciado = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (iniciado) return;
    cierre = cierreActual(context)?.id;
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is Map) profesional = arg['profesional'] as String? ?? '';
    iniciado = true;
  }

  Future<List<Map<String, dynamic>>>? consulta;

  void consultar(RepositorioRemoto repositorio) {
    final arg = ModalRoute.of(context)?.settings.arguments;
    final id = arg is Map ? arg['comision'] : null;
    consulta = id is String && widget.detalle
        ? repositorio.serviciosComision(id)
        : repositorio.comisiones(cierre: cierre, profesional: profesional);
  }

  Widget comisionesRemotas(RepositorioRemoto repositorio) {
    if (consulta == null) consultar(repositorio);
    return EstructuraPantalla(
      title: widget.detalle ? 'Detalle de comisión' : 'Consulta de Comisiones',
      children: [
        if (!widget.detalle) ...[
          SelectorBusqueda(
            etiqueta: 'Cierre',
            opciones: [
              const OpcionBusqueda('', 'Todos'),
              ...repositorio.cierres.map(
                (c) => OpcionBusqueda(c.id, 'Cierre #${c.id}'),
              ),
            ],
            valor: cierre ?? '',
            onChanged: (v) => setState(() {
              cierre = v;
              consultar(repositorio);
            }),
          ),
          SelectorBusqueda(
            etiqueta: 'Profesional',
            opciones: [
              const OpcionBusqueda('', 'Todos'),
              ...opcionesModulo(Modulo.profesionales),
            ],
            valor: profesional,
            onChanged: (v) => setState(() {
              profesional = v ?? '';
              consultar(repositorio);
            }),
          ),
        ],
        FutureBuilder<List<Map<String, dynamic>>>(
          future: consulta,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return TextButton(
                onPressed: () => setState(() => consultar(repositorio)),
                child: const Text('No se pudo consultar. Reintentar'),
              );
            }
            final filas = snapshot.data ?? [];
            if (filas.isEmpty) return const Text('No encontramos resultados.');
            return Column(
              children: filas.map((fila) {
                final id = (fila['id'] ?? fila['comisionId'])?.toString();
                final profesionalDatos = fila['profesional'];
                final servicioDatos = fila['servicio'];
                final profesionalId =
                    (fila['profesionalId'] ??
                            (profesionalDatos is Map
                                ? profesionalDatos['id']
                                : null))
                        ?.toString() ??
                    '';
                final nombreProfesional = profesionalDatos is Map
                    ? [
                        profesionalDatos['nombres'],
                        profesionalDatos['apellidos'],
                      ].whereType<String>().join(' ')
                    : null;
                final nombre =
                    (servicioDatos is Map ? servicioDatos['nombre'] : null) ??
                    nombreProfesional ??
                    fila['servicioNombre'] ??
                    fila['nombreServicio'] ??
                    fila['profesionalNombre'] ??
                    fila['nombreProfesional'] ??
                    (profesionalId.isNotEmpty
                        ? EstadoAplicacion.registro(
                            Modulo.profesionales,
                            profesionalId,
                          ).nombre
                        : null);
                final valor =
                    fila['valorComision'] ??
                    fila['totalComision'] ??
                    fila['comision'] ??
                    fila['total'];
                final importe = num.tryParse(valor?.toString() ?? '');
                return TarjetaRegistro(
                  nombre?.toString() ??
                      (widget.detalle ? 'Servicio' : 'Comisión #${id ?? ''}'),
                  [
                    if (fila['cantidadServicios'] != null)
                      '${fila['cantidadServicios']} servicios',
                    if (fila['porcentaje'] != null)
                      'Tarifa ${fila['porcentaje']}%',
                    if (num.tryParse(
                          (fila['subTotal'] ?? fila['precio'])?.toString() ??
                              '',
                        )
                        case final num base)
                      'Base ${dinero(base)}',
                    if (importe != null) 'Comisión: ${dinero(importe)}',
                  ].join(' · '),
                  route: !widget.detalle && id != null
                      ? '/detalle-comision'
                      : null,
                  argumentos: {'comision': id},
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: EstadoAplicacion.repositorio,
    builder: (context, _) {
      final repositorio = EstadoAplicacion.repositorio;
      if (repositorio is RepositorioRemoto)
        return comisionesRemotas(repositorio);
      final lista = EstadoAplicacion.repositorio.cierres.where(
        (c) => c.id == cierre,
      );
      final c = lista.isEmpty ? null : lista.first;
      final reservas =
          c?.reservas
              .where(
                (r) => profesional.isEmpty || r.profesionalId == profesional,
              )
              .toList() ??
          <Reserva>[];
      final total = reservas.fold<int>(0, (s, r) => s + r.precio),
          comision = reservas.fold<double>(
            0,
            (s, r) => s + r.precio * r.comision / 100,
          );
      return EstructuraPantalla(
        title: widget.detalle
            ? 'Detalle de comisión'
            : 'Consulta de Comisiones',
        children: [
          SelectorBusqueda(
            etiqueta: 'Cierre',
            opciones: EstadoAplicacion.repositorio.cierres
                .map(
                  (c) => OpcionBusqueda(
                    c.id,
                    'Cierre #${c.id}',
                    detalle: '${fechaTexto(c.desde)}–${fechaTexto(c.hasta)}',
                  ),
                )
                .toList(),
            valor: cierre,
            onChanged: (v) => setState(() => cierre = v),
          ),
          SelectorBusqueda(
            etiqueta: 'Profesional',
            opciones: [
              const OpcionBusqueda('', 'Todos'),
              ...opcionesModulo(Modulo.profesionales),
            ],
            valor: profesional,
            onChanged: (v) => setState(() => profesional = v ?? ''),
          ),
          Tarjeta(
            children: [
              DatoVista('Total periodo', dinero(total)),
              DatoVista('Comisiones', dinero(comision)),
              DatoVista('Total centro', dinero(total - comision)),
            ],
          ),
          if (reservas.isEmpty)
            const Text(
              'No encontramos resultados para este cierre y profesional.',
            ),
          if (!widget.detalle)
            ...reservas.map((r) => r.profesionalId).toSet().map((id) {
              final grupo = reservas
                  .where((r) => r.profesionalId == id)
                  .toList();
              final base = grupo.fold<int>(0, (s, r) => s + r.precio),
                  valor = grupo.fold<double>(
                    0,
                    (s, r) => s + r.precio * r.comision / 100,
                  );
              final porcentajes = grupo
                  .map((r) => r.comision)
                  .toSet()
                  .map((v) => '$v%')
                  .join(', ');
              return TarjetaRegistro(
                EstadoAplicacion.registro(Modulo.profesionales, id).nombre,
                '${grupo.length} servicios · Base ${dinero(base)}\nTarifa $porcentajes · A pagar ${dinero(valor)}',
                route: '/detalle-comision',
                argumentos: {'cierre': cierre, 'profesional': id},
              );
            }),
          if (widget.detalle)
            ...reservas.map(
              (r) => TarjetaRegistro(
                EstadoAplicacion.registro(Modulo.clientes, r.clienteId).nombre,
                '${EstadoAplicacion.registro(Modulo.servicios, r.servicioId).nombre} · ${fechaTexto(r.fecha)}\nBase ${dinero(r.precio)} · ${r.comision}% · Comisión ${dinero(r.precio * r.comision / 100)}',
              ),
            ),
        ],
      );
    },
  );
}
