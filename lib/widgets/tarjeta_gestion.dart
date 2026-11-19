import 'package:flutter/material.dart';

import 'etiqueta_estado.dart';

/// La tarjeta completa y los botones de 48 px permiten abrir o editar un registro.
class TarjetaGestion extends StatelessWidget {
  const TarjetaGestion(
    this.titulo,
    this.detalle, {
    super.key,
    required this.ruta,
    this.estado,
    this.imagen,
    this.rutaHorario,
    this.argumentos,
    this.alEliminar,
  });
  final String titulo, detalle, ruta;
  final String? estado, imagen, rutaHorario;
  final Object? argumentos;
  final VoidCallback? alEliminar;
  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: Theme.of(context).dividerColor),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.of(context).pushNamed(ruta, arguments: argumentos),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (imagen != null) ...[
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage(imagen!),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    titulo,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: 'Editar $titulo',
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  onPressed: () =>
                      Navigator.of(context)
                          .pushNamed(ruta, arguments: argumentos),
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
            Text(detalle, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (alEliminar != null)
                  TextButton.icon(
                    onPressed: alEliminar,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Eliminar'),
                  ),
                if (estado != null) EtiquetaEstado(estado!),
                if (rutaHorario != null)
                  TextButton.icon(
                    onPressed: () =>
                        Navigator.of(context)
                            .pushNamed(rutaHorario!, arguments: argumentos),
                    icon: const Icon(Icons.schedule),
                    label: const Text('Ver Horarios'),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
