import 'package:flutter/material.dart';

import '../../models/datos_barberia.dart';
import '../../widgets/formulario_catalogo.dart';

class PantallaAgregarHorario extends StatelessWidget {
  const PantallaAgregarHorario({super.key});
  @override
  Widget build(BuildContext context) =>
      const FormularioCatalogo(Modulo.horarios);
}
