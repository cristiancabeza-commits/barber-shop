import 'package:flutter/material.dart';

class TituloSeccion extends StatelessWidget {
  const TituloSeccion(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: Theme.of(context).colorScheme.secondary,
    ),
  );
}
