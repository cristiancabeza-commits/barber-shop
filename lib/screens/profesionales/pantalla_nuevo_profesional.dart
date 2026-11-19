import 'package:flutter/material.dart';

import '../../models/datos_barberia.dart';
import '../../widgets/formulario_catalogo.dart';

class PantallaNuevoProfesional extends StatelessWidget {
  const PantallaNuevoProfesional({super.key});
  @override
  Widget build(BuildContext context) =>
      const FormularioCatalogo(Modulo.profesionales);
}
