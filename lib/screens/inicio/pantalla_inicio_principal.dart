import 'package:flutter/material.dart';

import '../../controllers/estado_aplicacion.dart';
import '../../repositories/repositorio_remoto.dart';

import '../../widgets/componentes.dart';
import '../../widgets/resumen_agenda.dart';
import '../../models/datos_barberia.dart';

/// Prioriza las citas próximas y la creación de reservas sobre los catálogos.
class PantallaInicioPrincipal extends StatelessWidget {
  const PantallaInicioPrincipal({super.key});
  List<Reserva> proximasCitas() {
    final hoy = DateUtils.dateOnly(EstadoAplicacion.ahora());
    final reservas = EstadoAplicacion.repositorio.reservas
        .where((r) => r.estado == 'Programada' && !r.fecha.isBefore(hoy))
        .toList();
    reservas.sort((a, b) {
      final fecha = a.fecha.compareTo(b.fecha);
      return fecha != 0 ? fecha : a.hora.compareTo(b.hora);
    });
    return reservas.take(3).toList();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: EstadoAplicacion.repositorio,
    builder: (context, _) => EstructuraPantalla(
      title: 'Barrber Shop',
      active: 0,
      back: false,
      children: [
        Row(
          children: [
            const Logotipo(size: 56),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('¡Buen día!'),
                  Text(
                    'Hola, Admin',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
        Text(
          EstadoAplicacion.repositorio is RepositorioRemoto
              ? 'Panel de gestión'
              : 'Prototipo · datos de ejemplo',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        TituloSeccion(
          EstadoAplicacion.repositorio is RepositorioRemoto
              ? 'Reservas desde hoy'
              : 'Resumen de la agenda',
        ),
        const ResumenAgenda(),
        if (EstadoAplicacion.repositorio is RepositorioRemoto)
          const Text('Incluye hoy y todas las próximas fechas.'),
        const BotonVista('Nueva Reserva', route: '/nueva-reserva'),
        const TituloSeccion('Próximas citas'),
        ...proximasCitas().map(
          (r) => TarjetaRegistro(
            EstadoAplicacion.registro(Modulo.clientes, r.clienteId).nombre,
            '${EstadoAplicacion.registro(Modulo.servicios, r.servicioId).nombre} · ${EstadoAplicacion.registro(Modulo.profesionales, r.profesionalId).nombre}\n${fechaTexto(r.fecha)} · ${r.hora}',
            status: r.estado,
            route: '/detalle-reserva',
            argumentos: r.id,
          ),
        ),
        const BotonVista('Ver agenda', route: '/agenda', secondary: true),
        const TituloSeccion('Gestión del centro'),
        LayoutBuilder(
          builder: (context, constraints) {
            final columnas = constraints.maxWidth >= 600 ? 3 : 2;
            final ancho =
                (constraints.maxWidth - 12 * (columnas - 1)) / columnas;
            const modulos = [
              ('Agenda', Icons.calendar_month_outlined, '/agenda'),
              ('Especialidades', Icons.category_outlined, '/especialidades'),
              ('Servicios', Icons.content_cut, '/servicios'),
              ('Profesionales', Icons.badge_outlined, '/profesionales'),
              ('Clientes', Icons.people_outline, '/clientes'),
              ('Cierres', Icons.point_of_sale_outlined, '/cierres-caja'),
              ('Comisiones', Icons.payments_outlined, '/consulta-comisiones'),
              ('Horarios', Icons.schedule, '/horarios'),
            ];
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: modulos
                  .map(
                    (m) => SizedBox(
                      width: ancho,
                      child: Material(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => abrirVista(context, m.$3),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  m.$2,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  m.$1,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    ),
  );
}
