import 'package:flutter/material.dart';

import '../../models/datos_barberia.dart';
import '../../widgets/formulario_catalogo.dart';

class PantallaEditarServicio extends StatelessWidget {
  const PantallaEditarServicio({super.key});
  @override
  Widget build(BuildContext context) =>
      const FormularioCatalogo(Modulo.servicios, editar: true);
}
