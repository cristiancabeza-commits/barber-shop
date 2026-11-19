import 'package:flutter/material.dart';

import '../controllers/estado_aplicacion.dart';
import '../repositories/repositorio_remoto.dart';
import '../models/datos_barberia.dart';
import 'componentes.dart';
import 'selector_busqueda.dart';
import 'busqueda_por_nombre.dart';

String tituloModulo(Modulo m) => switch (m) {
  Modulo.clientes => 'Clientes',
  Modulo.especialidades => 'Especialidad',
  Modulo.servicios => 'Servicios',
  Modulo.profesionales => 'Profesionales',
  Modulo.horarios => 'Horarios',
  Modulo.inasistencias => 'Inasistencias',
};
String rutaModulo(Modulo m) => '/${m.name}';
String rutaAlta(Modulo m) => switch (m) {
  Modulo.clientes => '/nuevo-cliente',
  Modulo.especialidades => '/nueva-especialidad',
  Modulo.servicios => '/nuevo-servicio',
  Modulo.profesionales => '/nuevo-profesional',
  Modulo.horarios => '/agregar-horario',
  Modulo.inasistencias => '/inasistencia-rango',
};
String rutaEditar(Modulo m) => switch (m) {
  Modulo.clientes => '/editar-cliente',
  Modulo.especialidades => '/editar-especialidad',
  Modulo.servicios => '/editar-servicio',
  Modulo.profesionales => '/editar-profesional',
  Modulo.horarios => '/editar-horario',
  Modulo.inasistencias => '/inasistencia-rango',
};
List<OpcionBusqueda> opcionesModulo(
  Modulo modulo, {
  bool soloActivos = false,
  String? conservar,
}) => EstadoAplicacion.repositorio
    .listar(modulo)
    .where((r) => !soloActivos || r.activo || r.id == conservar)
    .map(
      (r) => OpcionBusqueda(
        r.id,
        r.nombre,
        detalle: switch (modulo) {
          Modulo.clientes ||
          Modulo.profesionales => 'Documento: ${r.valor('documento')}',
          Modulo.servicios =>
            '${dinero(int.tryParse(r.valor('precio')) ?? 0)} · ${r.valor('duracion')} min',
          _ => r.id,
        },
      ),
    )
    .toList();

class CatalogoModulo extends StatefulWidget {
  const CatalogoModulo(this.modulo, {super.key});
  final Modulo modulo;
  @override
  State<CatalogoModulo> createState() => _EstadoCatalogo();
}

class _EstadoCatalogo extends State<CatalogoModulo> {
  final busqueda = TextEditingController();
  String especialidad = '', estado = 'Todos', profesional = '';
  bool iniciado = false;
  @override
  void dispose() {
    busqueda.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!iniciado) {
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (widget.modulo == Modulo.horarios &&
          arg is String &&
          EstadoAplicacion.repositorio
              .listar(Modulo.profesionales)
              .any((p) => p.id == arg))
        profesional = arg;
      iniciado = true;
      if (widget.modulo == Modulo.horarios && profesional.isNotEmpty) {
        seleccionarProfesional(profesional);
      }
    }
  }

  bool eliminando = false;
  List<Registro>? jornadas;
  Future<void> seleccionarProfesional(String id) async {
    setState(() {
      profesional = id;
      jornadas = null;
    });
    final repositorio = EstadoAplicacion.repositorio;
    if (id.isEmpty || repositorio is! RepositorioRemoto) return;
    try {
      final filas = await repositorio.consultarPorProfesional(
        Modulo.horarios,
        id,
      );
      if (mounted && profesional == id) setState(() => jornadas = filas);
    } catch (_) {
      if (mounted && profesional == id)
        mostrarAviso(context, 'No se pudieron consultar los horarios.');
    }
  }

  Future<void> eliminar(
    RepositorioRemoto repositorio,
    Modulo modulo,
    Registro registro,
  ) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogo) => AlertDialog(
        title: const Text('Eliminar registro'),
        content: Text('¿Quieres eliminar ${registro.nombre}?'),
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
    if (!mounted || confirmado != true || eliminando) return;
    setState(() => eliminando = true);
    try {
      await repositorio.eliminar(modulo, registro.id);
      if (mounted) {
        setState(() => jornadas = null);
        mostrarAviso(context, 'Registro eliminado.');
      }
    } catch (_) {
      if (mounted) mostrarAviso(context, 'No se pudo eliminar el registro.');
    } finally {
      if (mounted) setState(() => eliminando = false);
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: EstadoAplicacion.repositorio,
    builder: (context, _) {
      final m = widget.modulo;
      final consulta = normalizarNombre(busqueda.text);
      final repositorio = EstadoAplicacion.repositorio;
      final registros = (jornadas ?? repositorio.listar(m)).where((r) {
        final texto =
            '${r.nombre} ${[Modulo.clientes, Modulo.profesionales].contains(m) ? r.valor('documento') : ''} ${m == Modulo.clientes ? '${r.valor('celular')} ${r.valor('celular').replaceAll(RegExp(r'\D'), '')}' : ''}';
        return normalizarNombre(texto).contains(consulta) &&
            (especialidad.isEmpty || r.valor('especialidad') == especialidad) &&
            (profesional.isEmpty || r.valor('profesional') == profesional) &&
            (estado == 'Todos' || r.activo == (estado == 'Activos'));
      }).toList();
      return EstructuraPantalla(
        title: tituloModulo(m),
        fabRoute: m == Modulo.horarios ? null : rutaAlta(m),
        children: [
          if (m != Modulo.horarios)
            TextField(
              controller: busqueda,
              decoration: InputDecoration(
                hintText: m == Modulo.clientes
                    ? 'Nombre, documento o celular'
                    : m == Modulo.profesionales
                    ? 'Nombre o documento'
                    : 'Buscar por nombre',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Limpiar búsqueda',
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    busqueda.clear();
                    setState(() {});
                  },
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          if ([Modulo.servicios, Modulo.profesionales].contains(m))
            SelectorBusqueda(
              etiqueta: 'Especialidad',
              opciones: [
                const OpcionBusqueda('', 'Todas'),
                ...opcionesModulo(Modulo.especialidades),
              ],
              valor: especialidad,
              onChanged: (v) => setState(() => especialidad = v ?? ''),
            ),
          if (m == Modulo.horarios) ...[
            SelectorBusqueda(
              etiqueta: 'Profesional',
              opciones: [
                const OpcionBusqueda('', 'Todos'),
                ...opcionesModulo(Modulo.profesionales),
              ],
              valor: profesional,
              onChanged: (v) => seleccionarProfesional(v ?? ''),
            ),
            FilledButton.icon(
              onPressed: () async {
                await Navigator.pushNamed(
                  context,
                  rutaAlta(m),
                  arguments: profesional,
                );
                if (mounted && profesional.isNotEmpty)
                  await seleccionarProfesional(profesional);
              },
              icon: const Icon(Icons.add),
              label: const Text('Agregar horario'),
            ),
          ],
          if ([
            Modulo.servicios,
            Modulo.especialidades,
            Modulo.profesionales,
          ].contains(m))
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Todos', 'Activos', 'Inactivos']
                  .map(
                    (v) => ChoiceChip(
                      label: Text(v),
                      selected: estado == v,
                      onSelected: (_) => setState(() => estado = v),
                    ),
                  )
                  .toList(),
            ),
          if (registros.isEmpty) ...[
            const Text('No encontramos resultados. Prueba con otros datos.'),
            TextButton(
              onPressed: () => setState(() {
                busqueda.clear();
                especialidad = '';
                estado = 'Todos';
                profesional = '';
              }),
              child: const Text('Limpiar filtros'),
            ),
          ],
          ...registros.map(
            (r) => TarjetaGestion(
              r.nombre,
              detalleRegistro(m, r),
              ruta: rutaEditar(m),
              argumentos: r.id,
              estado: m == Modulo.clientes
                  ? null
                  : r.activo
                  ? (m == Modulo.especialidades ? 'Activa' : 'Activo')
                  : (m == Modulo.especialidades ? 'Inactiva' : 'Inactivo'),
              alEliminar: repositorio is RepositorioRemoto && !eliminando
                  ? () => eliminar(repositorio, m, r)
                  : null,
              rutaHorario: m == Modulo.profesionales ? '/horarios' : null,
            ),
          ),
          if (m == Modulo.horarios)
            const BotonVista(
              'Inasistencias',
              route: '/inasistencias',
              secondary: true,
            ),
        ],
      );
    },
  );
}

String detalleRegistro(Modulo m, Registro r) => switch (m) {
  Modulo.clientes =>
    'CC: ${r.valor('documento')}\n${r.valor('celular')} · ${r.valor('correo')}',
  Modulo.profesionales =>
    'ID ${r.id} · CC: ${r.valor('documento')}\n${EstadoAplicacion.registro(Modulo.especialidades, r.valor('especialidad')).nombre}\nNacimiento: ${r.valor('nacimiento').isEmpty ? 'No registrado' : r.valor('nacimiento')}',
  Modulo.servicios =>
    'ID ${r.id} · ${EstadoAplicacion.registro(Modulo.especialidades, r.valor('especialidad')).nombre}\n${dinero(int.tryParse(r.valor('precio')) ?? 0)} · ${r.valor('duracion')} minutos',
  Modulo.horarios =>
    '${EstadoAplicacion.registro(Modulo.profesionales, r.valor('profesional')).nombre}\n${r.activo ? '${r.valor('inicio')}–${r.valor('fin')}' : 'Libre'}${r.valor('almuerzo') == 'sí' ? '\nAlmuerzo: ${r.valor('inicioAlmuerzo')}–${r.valor('finAlmuerzo')}' : ''}',
  Modulo.inasistencias =>
    '${r.valor('desde')}–${r.valor('hasta')} · ${r.valor('motivo')}',
  _ => 'ID ${r.id}',
};
