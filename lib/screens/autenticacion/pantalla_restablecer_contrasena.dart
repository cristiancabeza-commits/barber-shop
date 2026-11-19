import 'package:flutter/material.dart';

import '../../widgets/acceso_local.dart';

class PantallaRestablecerContrasena extends StatelessWidget {
  const PantallaRestablecerContrasena({super.key});
  @override
  Widget build(BuildContext context) => const AccesoLocal(recuperar: true);
}
