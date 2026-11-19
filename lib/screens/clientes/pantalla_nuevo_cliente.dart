import 'package:flutter/material.dart';

import '../../models/datos_barberia.dart';
import '../../widgets/formulario_catalogo.dart';

class PantallaNuevoCliente extends StatelessWidget {
  const PantallaNuevoCliente({super.key});
  @override
  Widget build(BuildContext context) =>
      const FormularioCatalogo(Modulo.clientes);
}
