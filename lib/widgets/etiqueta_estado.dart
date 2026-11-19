import 'package:flutter/material.dart';

class EtiquetaEstado extends StatelessWidget {
  const EtiquetaEstado(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final color = switch (text) {
      'Cancelada' ||
      'Inactivo' ||
      'Inactiva' => dark ? const Color(0xFFFFA5A5) : const Color(0xFF9D1921),
      'Atendida' ||
      'Activo' ||
      'Activa' => dark ? const Color(0xFF71DEC3) : const Color(0xFF006D53),
      _ => Theme.of(context).colorScheme.secondary,
    };
    return Semantics(
      label: 'Estado: $text',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
