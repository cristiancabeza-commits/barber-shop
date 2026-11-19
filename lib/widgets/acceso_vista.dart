import 'package:flutter/material.dart';

import 'navegacion_vistas.dart';

/// Hace pulsable un elemento original de Figma sin modificar su diseño.
class AccesoVista extends StatelessWidget {
  const AccesoVista({
    super.key,
    required this.ruta,
    required this.etiqueta,
    required this.child,
  });
  final String ruta;
  final String etiqueta;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: etiqueta,
    child: MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (ruta == '@volver') {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              abrirVista(context, '/inicio-principal');
            }
          } else if (ruta == '@mas') {
            mostrarModulos(context);
          } else if (ruta == '@codigo') {
            mostrarAviso(
              context,
              'Vista de demostración: continúa con Verificar código.',
            );
          } else if (ruta == '/inicio-principal' &&
              (ModalRoute.of(context)?.settings.name == '/inicio-sesion' ||
                  ModalRoute.of(context)?.settings.name ==
                      '/error-inicio-sesion')) {
            Navigator.of(context).pushNamedAndRemoveUntil(ruta, (_) => false);
          } else {
            abrirVista(context, ruta);
          }
        },
        child: child,
      ),
    ),
  );
}
