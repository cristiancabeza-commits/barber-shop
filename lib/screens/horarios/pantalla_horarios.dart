import 'package:flutter/material.dart';

import '../../models/datos_barberia.dart';
import '../../widgets/catalogo_modulo.dart';

class PantallaHorarios extends StatelessWidget {
  const PantallaHorarios({super.key});
  @override
  Widget build(BuildContext context) => const CatalogoModulo(Modulo.horarios);
}
