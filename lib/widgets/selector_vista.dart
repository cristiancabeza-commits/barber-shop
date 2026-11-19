import 'package:flutter/material.dart';

import 'selector_busqueda.dart';

class SelectorVista extends StatefulWidget {
  const SelectorVista(this.label, this.options, {super.key});
  final String label;
  final List<String> options;
  @override
  State<SelectorVista> createState() => _EstadoSelector();
}

class _EstadoSelector extends State<SelectorVista> {
  String? selected;
  @override
  Widget build(BuildContext context) {
    if ([
      'cliente',
      'servicio',
      'profesional',
      'especialidad',
      'cierre',
    ].any((palabra) => widget.label.toLowerCase().contains(palabra))) {
      return SelectorBusqueda(
        etiqueta: widget.label,
        opciones: widget.options.map((o) => OpcionBusqueda(o, o)).toList(),
        valor: selected ?? widget.options.first,
        onChanged: (v) => setState(() => selected = v),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: selected ?? widget.options.first,
          isExpanded: true,
          isDense: false,
          menuMaxHeight: 320,
          itemHeight: null,
          selectedItemBuilder: (context) => widget.options
              .map(
                (s) => Align(
                  alignment: Alignment.centerLeft,
                  child: Text(s, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          items: widget.options
              .map(
                (s) => DropdownMenuItem(
                  value: s,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(s),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() => selected = v),
        ),
      ],
    );
  }
}
