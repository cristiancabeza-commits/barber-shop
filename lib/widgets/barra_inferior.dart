import 'package:flutter/material.dart';

import 'navegacion_vistas.dart';

class BarraInferior extends StatelessWidget {
  const BarraInferior({super.key, this.activo = 3});
  final int activo;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.surface,
      child: SafeArea(
        top: false,
        child: Align(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 412),
            child: SizedBox(
              height: 72,
              child: Row(
                children: List.generate(4, (i) {
                  final color = i == activo
                      ? scheme.secondary
                      : scheme.onSurfaceVariant;
                  return Expanded(
                    child: InkWell(
                      onTap: () => i == 3
                          ? mostrarModulos(context)
                          : irSeccion(
                              context,
                              [
                                '/inicio-principal',
                                '/agenda',
                                '/nueva-reserva',
                              ][i],
                            ),
                      child: Semantics(
                        selected: i == activo,
                        button: true,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              [
                                Icons.home_outlined,
                                Icons.calendar_month_outlined,
                                Icons.content_cut,
                                Icons.menu,
                              ][i],
                              color: color,
                              size: 22,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ['Inicio', 'Agenda', 'Reservar', 'Más'][i],
                              style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: i == activo
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
