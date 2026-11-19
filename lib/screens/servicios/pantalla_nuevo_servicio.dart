import 'package:flutter/material.dart';

import '../../models/datos_barberia.dart';
import '../../widgets/formulario_catalogo.dart';

class PantallaNuevoServicio extends StatelessWidget {
  const PantallaNuevoServicio({super.key});
  @override
  Widget build(BuildContext context) =>
      const FormularioCatalogo(Modulo.servicios);
}
