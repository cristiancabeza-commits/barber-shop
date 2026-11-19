import 'package:flutter/material.dart';

import '../../models/datos_barberia.dart';
import '../../widgets/formulario_catalogo.dart';

class PantallaEditarEspecialidad extends StatelessWidget {
  const PantallaEditarEspecialidad({super.key});
  @override
  Widget build(BuildContext context) =>
      const FormularioCatalogo(Modulo.especialidades, editar: true);
}
