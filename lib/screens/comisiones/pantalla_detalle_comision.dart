import 'package:flutter/material.dart';

import '../../widgets/flujo_cierres.dart';

class PantallaDetalleComision extends StatelessWidget {
  const PantallaDetalleComision({super.key});
  @override
  Widget build(BuildContext context) => const ConsultaComisiones(detalle: true);
}
