import 'package:flutter/material.dart';

import '../controllers/estado_aplicacion.dart';
import '../repositories/repositorio_remoto.dart';
import '../models/datos_barberia.dart';
import 'componentes.dart';
import 'catalogo_modulo.dart';
import 'selector_busqueda.dart';
import 'campo_formulario.dart';

class FormularioCatalogo extends StatefulWidget {
  const FormularioCatalogo(this.modulo, {super.key, this.editar = false});
  final Modulo modulo;
  final bool editar;
  @override
  State<FormularioCatalogo> createState() => _EstadoFormulario();
}

class _EstadoFormulario extends State<FormularioCatalogo> {
  final clave = GlobalKey<FormState>();
  final campos = <String, TextEditingController>{};
  final seleccion = <String, String?>{};
  bool iniciado = false, activo = true, almuerzo = true, guardando = false;
  bool noEncontrado = false;
  Registro? original;
  bool cargandoDetalle = false, detalleFallido = false;
  final diasAdicionales = <String>{};

  Future<void> cargarDetalle(
    RepositorioRemoto repositorio,
    Registro registro,
  ) async {
    setState(() {
      cargandoDetalle = true;
      detalleFallido = false;
    });
    try {
      final detalle = await repositorio.consultarRegistro(
        widget.modulo,
        registro,
      );
      if (!mounted) return;
      setState(() {
        original = detalle;
        activo = detalle.activo;
        almuerzo = detalle.valor('almuerzo') == 'sí';
        seleccion['especialidad'] = detalle.valor('especialidad');
        seleccion['profesional'] = detalle.valor('profesional');
        if (widget.modulo == Modulo.horarios)
          seleccion['nombre'] = detalle.nombre;
      });
    } catch (_) {
      if (mounted) setState(() => detalleFallido = true);
    } finally {
      if (mounted) setState(() => cargandoDetalle = false);
    }
  }

  TextEditingController c(String campo) => campos.putIfAbsent(
    campo,
    () => TextEditingController(text: original?.valor(campo) ?? ''),
  );
  @override
  void dispose() {
    for (final c in campos.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (iniciado) return;
    final arg = ModalRoute.of(context)?.settings.arguments;
    final lista = EstadoAplicacion.repositorio.listar(widget.modulo);
    if (widget.editar) {
      final encontrados = lista.where((r) => r.id == arg);
      original = arg == null && lista.isNotEmpty
          ? lista.first
          : encontrados.isEmpty
          ? null
          : encontrados.first;
      noEncontrado = original == null;
    }
    activo = original?.activo ?? true;
    almuerzo = original == null || original!.valor('almuerzo') == 'sí';
    seleccion['especialidad'] = original?.valor('especialidad');
    seleccion['profesional'] = original?.valor('profesional');
    if (widget.modulo == Modulo.horarios)
      seleccion['nombre'] = original?.valor('nombre');
    if (widget.modulo == Modulo.horarios &&
        arg is String &&
        EstadoAplicacion.repositorio
            .listar(Modulo.profesionales)
            .any((p) => p.id == arg))
      seleccion['profesional'] = arg;
    iniciado = true;
    final repositorio = EstadoAplicacion.repositorio;
    if (repositorio is RepositorioRemoto && original != null) {
      cargarDetalle(repositorio, original!);
    }
  }

  Widget texto(
    String campo,
    String etiqueta, {
    String tipo = 'texto',
    bool obligatorio = false,
    bool bloqueado = false,
    int? maximo,
    FormFieldValidator<String>? extra,
  }) => CampoFormulario(
    etiqueta,
    c(campo),
    tipo: tipo,
    soloLectura: bloqueado,
    maximo: maximo,
    validar: (v) {
      if (obligatorio && requerido(v) != null) return requerido(v);
      return extra?.call(v);
    },
  );
  Widget selector(String campo, String etiqueta, Modulo modulo) =>
      SelectorBusqueda(
        etiqueta: etiqueta,
        opciones: opcionesModulo(
          modulo,
          soloActivos: true,
          conservar: seleccion[campo],
        ),
        valor: seleccion[campo],
        obligatorio: true,
        onChanged: (v) => setState(() => seleccion[campo] = v),
      );
  String? documento(String? v) {
    if (EstadoAplicacion.repositorio
        .listar(widget.modulo)
        .any((r) => r.id != original?.id && r.valor('documento') == v?.trim()))
      return 'Este documento ya está registrado';
    return null;
  }

  String? nacimiento(String? v) {
    if (v == null || v.isEmpty) return null;
    final fecha = leerFecha(v);
    return fecha == null || fecha.isAfter(EstadoAplicacion.ahora())
        ? 'Selecciona una fecha de nacimiento válida'
        : null;
  }

  Future<void> guardar() async {
    if (guardando) return;
    if (!clave.currentState!.validate()) return;
    if (widget.modulo == Modulo.horarios) {
      final inicio = minutos(c('inicio').text), fin = minutos(c('fin').text);
      if (fin <= inicio) {
        mostrarAviso(context, 'La hora final debe ser posterior a la inicial.');
        return;
      }
      if (almuerzo &&
          (minutos(c('inicioAlmuerzo').text) < inicio ||
              minutos(c('finAlmuerzo').text) > fin ||
              minutos(c('finAlmuerzo').text) <=
                  minutos(c('inicioAlmuerzo').text))) {
        mostrarAviso(
          context,
          'El almuerzo debe estar dentro de la jornada y terminar después de iniciar.',
        );
        return;
      }
      if (EstadoAplicacion.repositorio
          .listar(Modulo.horarios)
          .any(
            (r) =>
                r.id != original?.id &&
                r.valor('profesional') == seleccion['profesional'] &&
                (r.nombre == seleccion['nombre'] ||
                    diasAdicionales.contains(r.nombre)),
          )) {
        mostrarAviso(
          context,
          'Este profesional ya tiene una jornada ese día. Edítala desde Horarios.',
        );
        return;
      }
    }
    setState(() => guardando = true);
    try {
      final datos = {
        for (final e in campos.entries) e.key: e.value.text.trim(),
        for (final e in seleccion.entries)
          if (e.value != null) e.key: e.value!,
        if (widget.modulo == Modulo.horarios)
          'almuerzo': almuerzo ? 'sí' : 'no',
      };
      final repositorio = EstadoAplicacion.repositorio;
      final registro = Registro(
        original?.id ?? EstadoAplicacion.nuevoId(widget.modulo.name),
        datos,
        activo: activo,
      );
      final dias = {registro.nombre, ...diasAdicionales};
      if (repositorio is RepositorioRemoto &&
          widget.modulo == Modulo.horarios &&
          !widget.editar &&
          dias.length > 1) {
        await repositorio.guardarHorarios(registro, dias);
      } else {
        await repositorio.guardar(widget.modulo, registro);
      }
      if (!mounted) return;
      mostrarAviso(context, 'Cambios guardados.');
      final argumento = ModalRoute.of(context)?.settings.arguments;
      if (argumento is Map && argumento['volver'] == true) {
        Navigator.pop(context);
      } else {
        regresarAlModulo(context, rutaModulo(widget.modulo));
      }
    } catch (_) {
      if (mounted)
        mostrarAviso(context, 'No se pudo guardar. Inténtalo de nuevo.');
    } finally {
      if (mounted) setState(() => guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (noEncontrado)
      return const EstructuraPantalla(
        title: 'Registro no disponible',
        children: [
          Text(
            'No se encontró el registro. Regresa al listado para seleccionarlo de nuevo.',
          ),
        ],
      );
    final repositorio = EstadoAplicacion.repositorio;
    if (repositorio is RepositorioRemoto &&
        (cargandoDetalle || detalleFallido)) {
      return EstructuraPantalla(
        title: 'Editar registro',
        children: [
          if (cargandoDetalle) const Center(child: CircularProgressIndicator()),
          if (detalleFallido)
            TextButton(
              onPressed: () => cargarDetalle(repositorio, original!),
              child: const Text('No se pudo consultar. Reintentar'),
            ),
        ],
      );
    }
    final m = widget.modulo;
    final personas = [Modulo.clientes, Modulo.profesionales].contains(m);
    final titulos = {
      Modulo.clientes: 'cliente',
      Modulo.profesionales: 'profesional',
      Modulo.especialidades: 'especialidad',
      Modulo.servicios: 'servicio',
      Modulo.horarios: 'horario',
    };
    final titulo = widget.editar
        ? 'Editar ${titulos[m]}'
        : m == Modulo.horarios
        ? 'Agregar horario'
        : m == Modulo.especialidades
        ? 'Nueva especialidad'
        : 'Nuevo ${titulos[m]}';
    return Form(
      key: clave,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: EstructuraPantalla(
        title: titulo,
        children: [
          if (personas) ...[
            texto(
              'documento',
              'Documento *',
              obligatorio: true,
              extra: documento,
            ),
            texto('nombre', 'Nombres *', obligatorio: true),
            texto(
              'apellidos',
              m == Modulo.clientes ? 'Apellidos *' : 'Apellidos',
              obligatorio: m == Modulo.clientes,
            ),
            texto(
              'nacimiento',
              'Fecha de nacimiento',
              tipo: 'nacimiento',
              extra: nacimiento,
            ),
          ],
          if (m == Modulo.clientes) ...[
            texto('celular', 'Celular', tipo: 'telefono'),
            texto(
              'correo',
              'Correo electrónico',
              tipo: 'correo',
              extra: validarCorreo,
            ),
          ],
          if (m == Modulo.profesionales) ...[
            texto(
              'comision',
              'Porcentaje de comisión *',
              tipo: 'numero',
              obligatorio: true,
              extra: (v) => validarEntero(v, maximo: 100),
            ),
            selector('especialidad', 'Especialidad *', Modulo.especialidades),
          ],
          if (m == Modulo.especialidades)
            texto('nombre', 'Nombre *', obligatorio: true),
          if (m == Modulo.servicios) ...[
            texto(
              'nombre',
              'Nombre del servicio *',
              obligatorio: true,
              bloqueado: widget.editar,
              maximo: 50,
            ),
            texto(
              'precio',
              'Precio (COP) *',
              tipo: 'numero',
              obligatorio: true,
              extra: (v) => validarEntero(v),
            ),
            texto(
              'duracion',
              'Duración (min) *',
              tipo: 'numero',
              obligatorio: true,
              extra: (v) => validarEntero(v, minimo: 1),
            ),
            if (widget.editar)
              DatoVista(
                'Especialidad (solo lectura)',
                EstadoAplicacion.registro(
                  Modulo.especialidades,
                  seleccion['especialidad'] ?? '',
                ).nombre,
              )
            else
              selector('especialidad', 'Especialidad *', Modulo.especialidades),
          ],
          if (m == Modulo.horarios) ...[
            selector('profesional', 'Profesional *', Modulo.profesionales),
            SelectorBusqueda(
              etiqueta: 'Día de la semana *',
              opciones: [
                for (final d in [
                  'Lunes',
                  'Martes',
                  'Miércoles',
                  'Jueves',
                  'Viernes',
                  'Sábado',
                  'Domingo',
                ])
                  OpcionBusqueda(d, d),
              ],
              valor: seleccion['nombre'],
              obligatorio: true,
              onChanged: (v) => setState(() {
                seleccion['nombre'] = v;
                diasAdicionales.remove(v);
              }),
            ),
            if (repositorio is RepositorioRemoto && !widget.editar) ...[
              const TituloSeccion('Aplicar también a otros días'),
              Wrap(
                spacing: 8,
                children: RepositorioRemoto.dias
                    .where((dia) => dia != seleccion['nombre'])
                    .map(
                      (dia) => FilterChip(
                        label: Text(dia),
                        selected: diasAdicionales.contains(dia),
                        onSelected: (elegido) => setState(() {
                          if (elegido) {
                            diasAdicionales.add(dia);
                          } else {
                            diasAdicionales.remove(dia);
                          }
                        }),
                      ),
                    )
                    .toList(),
              ),
            ],
            texto(
              'inicio',
              'Hora de inicio *',
              tipo: 'hora',
              obligatorio: true,
            ),
            texto('fin', 'Hora de fin *', tipo: 'hora', obligatorio: true),
            SwitchListTile(
              title: const Text('Tiene almuerzo'),
              value: almuerzo,
              onChanged: (v) => setState(() => almuerzo = v),
            ),
            if (almuerzo) ...[
              texto(
                'inicioAlmuerzo',
                'Inicio almuerzo *',
                tipo: 'hora',
                obligatorio: true,
              ),
              texto(
                'finAlmuerzo',
                'Fin almuerzo *',
                tipo: 'hora',
                obligatorio: true,
              ),
            ],
          ],
          if (m != Modulo.clientes)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                m == Modulo.horarios ? 'Día laborable' : 'Registro activo',
              ),
              value: activo,
              onChanged: (v) => setState(() => activo = v),
            ),
          FilledButton(
            onPressed: guardando ? null : guardar,
            child: Text(
              guardando
                  ? 'Guardando…'
                  : widget.editar
                  ? 'Guardar cambios'
                  : 'GUARDAR',
            ),
          ),
          OutlinedButton(
            onPressed: guardando ? null : () => regresarVista(context),
            child: const Text('CANCELAR'),
          ),
        ],
      ),
    );
  }
}
