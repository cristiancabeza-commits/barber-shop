import 'package:flutter/material.dart';

class BuscadorVista extends StatelessWidget {
  const BuscadorVista(this.hint, {super.key, this.onChanged});
  final String hint;
  final ValueChanged<String>? onChanged;
  @override
  Widget build(BuildContext context) => TextField(
    decoration: InputDecoration(
      hintText: hint,
      prefixIcon: const Icon(Icons.search),
    ),
    onChanged: onChanged,
  );
}
