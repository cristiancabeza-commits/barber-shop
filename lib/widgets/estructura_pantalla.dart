import 'package:flutter/material.dart';

import 'barra_inferior.dart';
import 'navegacion_vistas.dart';
import 'buscador_vista.dart';
import 'tarjeta_gestion.dart';
import 'tarjeta_registro.dart';
import 'busqueda_por_nombre.dart';

class EstructuraPantalla extends StatefulWidget {
  const EstructuraPantalla({
    super.key,
    required this.title,
    required this.children,
    this.active = 3,
    this.bottom = true,
    this.fabRoute,
    this.back = true,
  });
  final String title;
  final List<Widget> children;
  final int active;
  final bool bottom, back;
  final String? fabRoute;
  @override
  State<EstructuraPantalla> createState() => _EstadoEstructura();
}

class _EstadoEstructura extends State<EstructuraPantalla> {
  String consulta = '';
  String get title => widget.title;
  bool get back => widget.back;
  bool get bottom => widget.bottom;
  int get active => widget.active;
  String? get fabRoute => widget.fabRoute;
  List<Widget> get children {
    final resultado = <Widget>[];
    var registros = 0;
    for (final child in widget.children) {
      if (child is BuscadorVista && child.onChanged == null) {
        resultado.add(
          BuscadorVista(
            child.hint,
            onChanged: (value) =>
                setState(() => consulta = normalizarNombre(value)),
          ),
        );
      } else if (child is TarjetaGestion || child is TarjetaRegistro) {
        final texto = child is TarjetaGestion
            ? child.titulo
            : (child as TarjetaRegistro).title;
        if (consulta.isEmpty || normalizarNombre(texto).contains(consulta)) {
          resultado.add(child);
          registros++;
        }
      } else {
        resultado.add(child);
      }
    }
    if (consulta.isNotEmpty && registros == 0)
      resultado.add(
        const Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.search_off, size: 40),
              SizedBox(height: 12),
              Text(
                'No encontramos resultados. Prueba con otro nombre.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    return resultado;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      leading: back
          ? IconButton(
              tooltip: 'Regresar',
              icon: const Icon(Icons.arrow_back),
              onPressed: () => regresarVista(context),
            )
          : null,
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
    ),
    body: SafeArea(
      top: false,
      bottom: !bottom,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth < 360 ? 12 : 20,
            vertical: 20,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...children.expand(
                    (child) => [child, const SizedBox(height: 16)],
                  ),
                  SizedBox(height: fabRoute == null ? 8 : 72),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    floatingActionButton: fabRoute == null
        ? null
        : FloatingActionButton(
            tooltip: 'Agregar',
            onPressed: () => abrirVista(context, fabRoute!),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          ),
    bottomNavigationBar: bottom ? BarraInferior(activo: active) : null,
  );
}
