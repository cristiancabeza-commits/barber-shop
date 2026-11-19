import 'package:flutter/material.dart';

import '../../models/datos_barberia.dart';
import '../../widgets/formulario_catalogo.dart';

class PantallaEditarHorario extends StatelessWidget {
  const PantallaEditarHorario({super.key});
  @override
  Widget build(BuildContext context) =>
      const FormularioCatalogo(Modulo.horarios, editar: true);
}
