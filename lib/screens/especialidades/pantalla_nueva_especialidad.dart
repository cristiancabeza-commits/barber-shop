import 'package:flutter/material.dart';

import '../../models/datos_barberia.dart';
import '../../widgets/formulario_catalogo.dart';

class PantallaNuevaEspecialidad extends StatelessWidget {
  const PantallaNuevaEspecialidad({super.key});
  @override
  Widget build(BuildContext context) =>
      const FormularioCatalogo(Modulo.especialidades);
}
