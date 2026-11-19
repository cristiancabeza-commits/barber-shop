import 'package:flutter/material.dart';

import '../../models/datos_barberia.dart';
import '../../widgets/catalogo_modulo.dart';

class PantallaProfesionales extends StatelessWidget {
  const PantallaProfesionales({super.key});
  @override
  Widget build(BuildContext context) =>
      const CatalogoModulo(Modulo.profesionales);
}
