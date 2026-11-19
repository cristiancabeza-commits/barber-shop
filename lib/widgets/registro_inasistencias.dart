import 'package:flutter/material.dart';

import '../controllers/estado_aplicacion.dart';
import '../repositories/repositorio_remoto.dart';
import '../models/datos_barberia.dart';
import 'componentes.dart';
import 'selector_busqueda.dart';
import 'catalogo_modulo.dart';
import 'campo_formulario.dart';

class RegistroInasistencias extends StatefulWidget {
  const RegistroInasistencias({super.key, this.rango = false});
  final bool rango;
  @override
  State<RegistroInasistencias> createState() => _EstadoInasistencias();
}

class _EstadoInasistencias extends State<RegistroInasistencias> {
  final clave = GlobalKey<FormState>();
  final desde = TextEditingController(),
      hasta = TextEditingController(),
      motivo = TextEditingController();
  String? profesional;
  bool guardando = false, cargando = false, iniciado = false;
  Registro? original;
  List<Registro>? filtro;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (iniciado) return;
    iniciado = true;
    final argumento = ModalRoute.of(context)?.settings.arguments;
    final repositorio = EstadoAplicacion.repositorio;
    if (argumento is Registro && repositorio is RepositorioRemoto) {
      original = argumento;
      cargarDetalle(repositorio, argumento);
    }
  }

  Future<void> cargarDetalle(
    RepositorioRemoto repositorio,
    Registro registro,
  ) async {
    setState(() => cargando = true);
    try {
      final detalle = await repositorio.consultarRegistro(
        Modulo.inasistencias,
        registro,
      );
      if (!mounted) return;
      setState(() {
        original = detalle;
        profesional = detalle.valor('profesional');
        desde.text = detalle.valor('desde');
        hasta.text = detalle.valor('hasta');
        motivo.text = detalle.valor('motivo');
      });
    } catch (_) {
      if (mounted)
        mostrarAviso(context, 'No se pudo consultar la inasistencia.');
    } finally {
      if (mounted) setState(() => cargando = false);
    }
  }

  Future<void> seleccionarProfesional(String? id) async {
    setState(() {
      profesional = id;
      filtro = null;
    });
    final repositorio = EstadoAplicacion.repositorio;
    if (id == null || widget.rango || repositorio is! RepositorioRemoto) return;
    try {
      final filas = await repositorio.consultarPorProfesional(
        Modulo.inasistencias,
        id,
      );
      if (mounted && profesional == id) setState(() => filtro = filas);
    } catch (_) {
      if (mounted && profesional == id)
        mostrarAviso(context, 'No se pudo actualizar la lista.');
    }
  }

  Future<void> eliminar(
    RepositorioRemoto repositorio,
    Registro registro,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: const Text('¿Eliminar inasistencia?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogo, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogo, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (!mounted || confirmar != true || guardando) return;
    setState(() => guardando = true);
    try {
      await repositorio.eliminar(Modulo.inasistencias, registro.id);
      if (mounted) setState(() => filtro = null);
    } catch (_) {
      if (mounted)
        mostrarAviso(context, 'No se pudo eliminar la inasistencia.');
    } finally {
      if (mounted) setState(() => guardando = false);
    }
  }

  @override
  void dispose() {
    desde.dispose();
    hasta.dispose();
    motivo.dispose();
    super.dispose();
  }

  Future<void> guardar() async {
    if (guardando) return;
    if (!clave.currentState!.validate()) return;
    setState(() => guardando = true);
    try {
      await EstadoAplicacion.repositorio.guardar(
        Modulo.inasistencias,
        Registro(original?.id ?? EstadoAplicacion.nuevoId('I'), {
          'motivoId': original?.valor('motivoId') ?? '',
          'nombre': EstadoAplicacion.registro(
            Modulo.profesionales,
            profesional!,
          ).nombre,
          'profesional': profesional!,
          'desde': desde.text,
          'hasta': widget.rango ? hasta.text : desde.text,
          'motivo': motivo.text.trim(),
        }),
      );
      if (!mounted) return;
      setState(() => filtro = null);
      mostrarAviso(
        context,
        original == null
            ? 'Inasistencia registrada.'
            : 'Inasistencia actualizada.',
      );
      desde.clear();
      hasta.clear();
      motivo.clear();
      clave.currentState!.reset();
      if (widget.rango) regresarAlModulo(context, '/inasistencias');
    } catch (_) {
      if (mounted) mostrarAviso(context, 'No se pudo guardar la inasistencia.');
    } finally {
      if (mounted) setState(() => guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: EstadoAplicacion.repositorio,
    builder: (context, _) {
      final repositorio = EstadoAplicacion.repositorio;
      final registros = (filtro ?? repositorio.listar(Modulo.inasistencias))
          .where(
            (r) => profesional == null || r.valor('profesional') == profesional,
          );
      return Form(
        key: clave,
        child: EstructuraPantalla(
          title: original != null
              ? 'Editar inasistencia'
              : widget.rango
              ? 'Inasistencia por rango'
              : 'Inasistencias',
          children: [
            if (cargando) const LinearProgressIndicator(),
            if (original == null)
              SelectorBusqueda(
                etiqueta: 'Profesional *',
                opciones: opcionesModulo(Modulo.profesionales),
                valor: profesional,
                obligatorio: true,
                onChanged: seleccionarProfesional,
              ),
            if (!widget.rango) ...[
              const TituloSeccion('Registro de inasistencias'),
              if (registros.isEmpty)
                const Text(
                  'No hay inasistencias registradas para esta selección.',
                ),
              ...registros.map(
                (r) => Column(
                  children: [
                    TarjetaRegistro(
                      r.nombre.isEmpty
                          ? EstadoAplicacion.registro(
                              Modulo.profesionales,
                              r.valor('profesional'),
                            ).nombre
                          : r.nombre,
                      '${r.valor('desde')}–${r.valor('hasta')}\n${r.valor('motivo')}',
                      route: repositorio is RepositorioRemoto
                          ? '/inasistencia-rango'
                          : null,
                      argumentos: r,
                    ),
                    if (repositorio is RepositorioRemoto)
                      TextButton(
                        onPressed: guardando
                            ? null
                            : () => eliminar(repositorio, r),
                        child: const Text('Eliminar inasistencia'),
                      ),
                  ],
                ),
              ),
              const TituloSeccion('Nueva Inasistencia'),
              const BotonVista(
                'Rango de fechas',
                route: '/inasistencia-rango',
                secondary: true,
              ),
            ],
            CampoFormulario(
              widget.rango ? 'Fecha inicial *' : 'Fecha *',
              desde,
              tipo: 'fecha',
              validar: (v) => leerFecha(v ?? '') == null
                  ? 'Selecciona una fecha válida'
                  : null,
            ),
            if (widget.rango)
              CampoFormulario(
                'Fecha final *',
                hasta,
                tipo: 'fecha',
                validar: (v) {
                  final a = leerFecha(desde.text), b = leerFecha(v ?? '');
                  return a == null || b == null || b.isBefore(a)
                      ? 'La fecha final debe ser igual o posterior a la inicial'
                      : null;
                },
              ),
            CampoFormulario('Motivo *', motivo, lineas: 3, validar: requerido),
            FilledButton(
              onPressed: guardando || cargando || profesional == null
                  ? null
                  : guardar,
              child: Text(guardando ? 'Guardando…' : 'REGISTRAR INASISTENCIA'),
            ),
          ],
        ),
      );
    },
  );
}
