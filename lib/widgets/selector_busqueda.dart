import 'package:flutter/material.dart';

import 'busqueda_por_nombre.dart';

class OpcionBusqueda {
  const OpcionBusqueda(this.id, this.nombre, {this.detalle = ''});
  final String id, nombre, detalle;
}

/// Selecciona por identificador; el texto visible no se utiliza como clave.
class SelectorBusqueda extends StatelessWidget {
  const SelectorBusqueda({
    super.key,
    required this.etiqueta,
    required this.opciones,
    required this.valor,
    required this.onChanged,
    this.obligatorio = false,
    this.habilitado = true,
  });
  final String etiqueta;
  final List<OpcionBusqueda> opciones;
  final String? valor;
  final ValueChanged<String?> onChanged;
  final bool obligatorio, habilitado;
  @override
  Widget build(BuildContext context) {
    final coincidencias = opciones.where((o) => o.id == valor);
    final seleccion = coincidencias.isEmpty ? null : coincidencias.first;
    return FormField<String>(
      key: ValueKey('$etiqueta:$valor'),
      initialValue: valor,
      validator: (_) =>
          obligatorio && seleccion == null ? 'Selecciona una opción' : null,
      builder: (campo) => Semantics(
        button: true,
        label: etiqueta,
        child: InkWell(
          onTap: !habilitado
              ? null
              : () async {
                  final elegida = await showModalBottomSheet<OpcionBusqueda>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    useSafeArea: true,
                    builder: (_) =>
                        _PanelBusqueda(etiqueta: etiqueta, opciones: opciones),
                  );
                  if (!context.mounted || elegida == null) return;
                  campo.didChange(elegida.id);
                  onChanged(elegida.id);
                },
          borderRadius: BorderRadius.circular(12),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: etiqueta,
              errorText: campo.errorText,
              suffixIcon: Icon(habilitado ? Icons.search : Icons.lock_outline),
            ),
            child: Text(
              seleccion?.nombre ?? 'Seleccionar',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

class _PanelBusqueda extends StatefulWidget {
  const _PanelBusqueda({required this.etiqueta, required this.opciones});
  final String etiqueta;
  final List<OpcionBusqueda> opciones;
  @override
  State<_PanelBusqueda> createState() => _EstadoPanel();
}

class _EstadoPanel extends State<_PanelBusqueda> {
  final controlador = TextEditingController();
  String consulta = '';
  @override
  void dispose() {
    controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final resultados = widget.opciones
        .where(
          (o) =>
              normalizarNombre('${o.nombre} ${o.detalle}')
                  .contains(normalizarNombre(consulta)),
        )
        .toList();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .7,
        child: Column(
          children: [
            ListTile(
              title: Text(widget.etiqueta),
              trailing: IconButton(
                tooltip: 'Cerrar',
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: controlador,
                decoration: InputDecoration(
                  hintText:
                      widget.opciones.any(
                        (o) => o.detalle.startsWith('Documento:'),
                      )
                      ? 'Nombre o documento'
                      : 'Buscar por nombre',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    tooltip: 'Limpiar búsqueda',
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      controlador.clear();
                      setState(() => consulta = '');
                    },
                  ),
                ),
                onChanged: (valor) => setState(() => consulta = valor),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: resultados.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'No encontramos resultados. Prueba con otro nombre o documento.',
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: resultados.length,
                      itemBuilder: (context, i) {
                        final opcion = resultados[i];
                        return ListTile(
                          title: Text(opcion.nombre),
                          subtitle: opcion.detalle.isEmpty
                              ? null
                              : Text(opcion.detalle),
                          onTap: () => Navigator.pop(context, opcion),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
