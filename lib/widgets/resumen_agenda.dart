import 'package:flutter/material.dart';

import 'tarjeta.dart';
import '../controllers/estado_aplicacion.dart';

/// Mantiene las etiquetas completas y adapta las columnas al tamaño del texto.
class ResumenAgenda extends StatelessWidget {
  const ResumenAgenda({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: EstadoAplicacion.repositorio,
    builder: (context, _) => _contenido(context),
  );

  Widget _contenido(BuildContext context) {
    final hoy = DateUtils.dateOnly(EstadoAplicacion.ahora());
    final reservas = EstadoAplicacion.repositorio.reservas
        .where((r) => !DateUtils.dateOnly(r.fecha).isBefore(hoy))
        .toList();
    final datos = [
      ('Reservas', '${reservas.length}'),
      (
        'Pendientes',
        '${reservas.where((r) => r.estado == "Programada").length}',
      ),
      ('Atendidos', '${reservas.where((r) => r.estado == "Atendida").length}'),
    ];
    final estilo = Theme.of(context).textTheme.bodySmall;
    final escala = MediaQuery.textScalerOf(context);
    final direccion = Directionality.of(context);
    var anchoTexto = 0.0;
    for (final dato in datos) {
      final medida = TextPainter(
        text: TextSpan(text: dato.$1, style: estilo),
        textScaler: escala,
        textDirection: direccion,
        maxLines: 1,
      )..layout();
      if (medida.width > anchoTexto) anchoTexto = medida.width;
      medida.dispose();
    }
    // 32 px de relleno y 2 px adicionales de margen para el texto.
    final minimo = anchoTexto + 34;
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnas = ((constraints.maxWidth + 12) / (minimo + 12))
            .floor()
            .clamp(1, 3);
        final ancho = (constraints.maxWidth - 12 * (columnas - 1)) / columnas;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: datos
              .map(
                (dato) => SizedBox(
                  width: ancho,
                  child: Tarjeta(
                    children: [
                      Text(
                        dato.$2,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        dato.$1,
                        style: estilo,
                        maxLines: 1,
                        softWrap: false,
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
