import 'package:flutter/material.dart';

class OpcionesVista extends StatefulWidget {
  const OpcionesVista(this.options, {super.key});
  final List<String> options;
  @override
  State<OpcionesVista> createState() => _EstadoOpciones();
}

class _EstadoOpciones extends State<OpcionesVista> {
  int index = 0;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 6,
    children: List.generate(
      widget.options.length,
      (i) => ChoiceChip(
        label: Text(widget.options[i]),
        selected: index == i,
        onSelected: (_) => setState(() => index = i),
      ),
    ),
  );
}
