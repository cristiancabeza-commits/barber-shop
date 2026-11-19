import 'package:flutter/material.dart';

class InterruptorVista extends StatefulWidget {
  const InterruptorVista(
    this.label, {
    super.key,
    this.initial = true,
    this.detail,
  });
  final String label;
  final String? detail;
  final bool initial;
  @override
  State<InterruptorVista> createState() => _EstadoInterruptor();
}

class _EstadoInterruptor extends State<InterruptorVista> {
  late bool value = widget.initial;
  @override
  Widget build(BuildContext context) => SwitchListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(widget.label),
    subtitle: widget.detail == null ? null : Text(widget.detail!),
    value: value,
    onChanged: (v) => setState(() => value = v),
  );
}
