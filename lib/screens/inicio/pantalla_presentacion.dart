import 'package:flutter/material.dart';

import '../../widgets/logotipo.dart';

/// Identidad de entrada, sin indicadores de sistema simulados.
class PantallaPresentacion extends StatelessWidget {
  const PantallaPresentacion({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Logotipo(size: 160),
              const SizedBox(height: 24),
              Text(
                'Barrber Shop',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              const Text('CARGANDO SISTEMA...'),
            ],
          ),
        ),
      ),
    ),
  );
}
