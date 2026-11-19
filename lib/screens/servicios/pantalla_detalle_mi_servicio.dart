import 'package:flutter/material.dart';

import '../../widgets/flujo_reservas.dart';

class PantallaDetalleMiServicio extends StatelessWidget {
  const PantallaDetalleMiServicio({super.key});
  @override
  Widget build(BuildContext context) =>
      const DetalleReserva(estado: 'Atendida');
}
