import 'package:flutter/material.dart';

import '../../widgets/acceso_local.dart';

class PantallaErrorInicioSesion extends StatelessWidget {
  const PantallaErrorInicioSesion({super.key});
  @override
  Widget build(BuildContext context) => const AccesoLocal(errorInicial: true);
}
