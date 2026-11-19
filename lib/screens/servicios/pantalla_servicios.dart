import 'package:flutter/material.dart';

import '../../models/datos_barberia.dart';
import '../../widgets/catalogo_modulo.dart';

class PantallaServicios extends StatelessWidget {
  const PantallaServicios({super.key});
  @override
  Widget build(BuildContext context) => const CatalogoModulo(Modulo.servicios);
}
