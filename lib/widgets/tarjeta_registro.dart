import 'package:flutter/material.dart';

import 'tarjeta.dart';
import 'etiqueta_estado.dart';

class TarjetaRegistro extends StatelessWidget {
  const TarjetaRegistro(
    this.title,
    this.subtitle, {
    super.key,
    this.status,
    this.route,
    this.trailing,
    this.argumentos,
  });
  final String title, subtitle;
  final String? status, route, trailing;
  final Object? argumentos;
  @override
  Widget build(BuildContext context) => Semantics(
    button: route != null,
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: route == null
          ? null
          : () =>
                Navigator.of(context).pushNamed(route!, arguments: argumentos),
      child: Tarjeta(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              if (route != null) const Icon(Icons.chevron_right),
            ],
          ),
          Text(subtitle),
          if (trailing != null)
            Text(
              trailing!,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          if (status != null) EtiquetaEstado(status!),
        ],
      ),
    ),
  );
}
