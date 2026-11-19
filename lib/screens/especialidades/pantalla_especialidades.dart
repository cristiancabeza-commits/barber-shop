import 'package:flutter/material.dart';

import '../../models/datos_barberia.dart';
import '../../widgets/catalogo_modulo.dart';

class PantallaEspecialidades extends StatelessWidget {
  const PantallaEspecialidades({super.key});
  @override
  Widget build(BuildContext context) =>
      const CatalogoModulo(Modulo.especialidades);
}
