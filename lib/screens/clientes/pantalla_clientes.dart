import 'package:flutter/material.dart';

import '../../models/datos_barberia.dart';
import '../../widgets/catalogo_modulo.dart';

class PantallaClientes extends StatelessWidget {
  const PantallaClientes({super.key});
  @override
  Widget build(BuildContext context) => const CatalogoModulo(Modulo.clientes);
}
