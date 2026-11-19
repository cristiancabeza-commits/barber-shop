import 'package:flutter/material.dart';

import 'navegacion_vistas.dart';

class BotonVista extends StatelessWidget {
  const BotonVista(
    this.text, {
    super.key,
    this.route,
    this.secondary = false,
    this.message,
  });
  final String text;
  final String? route, message;
  final bool secondary;
  @override
  Widget build(BuildContext context) {
    void action() {
      if (route != null) {
        final etiqueta = text.toLowerCase();
        final volver =
            etiqueta.startsWith('guardar') ||
            etiqueta.startsWith('registrar') ||
            etiqueta == 'cancelar' ||
            etiqueta == 'cancelar edición' ||
            etiqueta.startsWith('volver') ||
            etiqueta == 'no, volver' ||
            etiqueta == 'ir a agenda';
        if (volver) {
          final messenger = ScaffoldMessenger.of(context);
          regresarAlModulo(context, route!);
          if (etiqueta.startsWith('guardar') ||
              etiqueta.startsWith('registrar')) {
            messenger.hideCurrentSnackBar();
            messenger.showSnackBar(
              const SnackBar(
                content: Text('Cambios confirmados en esta demostración.'),
              ),
            );
          }
        } else {
          abrirVista(context, route!);
          if (message != null) {
            mostrarAviso(context, message!);
          } else if (etiqueta == 'confirmar cierre') {
            mostrarAviso(context, 'Cierre confirmado en esta demostración.');
          }
        }
      } else {
        mostrarAviso(
          context,
          message ?? 'Vista de demostración: no se guardan datos.',
        );
      }
    }

    return secondary
        ? OutlinedButton(onPressed: action, child: Text(text))
        : FilledButton(onPressed: action, child: Text(text));
  }
}
