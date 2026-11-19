import 'package:flutter/material.dart';

import '../../widgets/registro_inasistencias.dart';

class PantallaInasistenciaRango extends StatelessWidget {
  const PantallaInasistenciaRango({super.key});
  @override
  Widget build(BuildContext context) =>
      const RegistroInasistencias(rango: true);
}
