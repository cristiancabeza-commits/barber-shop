import 'package:flutter/material.dart';

import '../../models/datos_barberia.dart';
import '../../widgets/formulario_catalogo.dart';

class PantallaEditarProfesional extends StatelessWidget {
  const PantallaEditarProfesional({super.key});
  @override
  Widget build(BuildContext context) =>
      const FormularioCatalogo(Modulo.profesionales, editar: true);
}
