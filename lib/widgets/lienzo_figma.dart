import 'package:flutter/material.dart';

import 'barra_inferior.dart';

class LienzoFigma extends StatelessWidget {
  const LienzoFigma({
    super.key,
    required this.contenido,
    this.conBarra = true,
    this.cabecera,
  });
  final Widget contenido;
  final bool conBarra;
  final WidgetBuilder? cabecera;
  @override
  Widget build(BuildContext context) {
    final ruta = ModalRoute.of(context)?.settings.name;
    return Scaffold(
      appBar: cabecera == null
          ? null
          : AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: 72,
              titleSpacing: 16,
              title: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: SizedBox(width: 380, child: cabecera!(context)),
                  ),
                ),
              ),
            ),
      bottomNavigationBar: !conBarra
          ? null
          : BarraInferior(
              activo: ruta == '/inicio-principal'
                  ? 0
                  : ruta == '/agenda'
                  ? 1
                  : ruta == '/nueva-reserva'
                  ? 2
                  : 3,
            ),
      body: SafeArea(
        bottom: false,
        top: cabecera == null,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final ancho = constraints.maxWidth < 412
                ? constraints.maxWidth
                : 412.0;
            return Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                child: SizedBox(
                  width: ancho,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: 412,
                      child: MediaQuery(
                        data: MediaQuery.of(context)
                            .copyWith(textScaler: TextScaler.noScaling),
                        child: contenido,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
