import 'package:flutter/material.dart';

import '../../widgets/flujo_reservas.dart';

class PantallaReservaCancelada extends StatelessWidget {
  const PantallaReservaCancelada({super.key});
  @override
  Widget build(BuildContext context) =>
      const DetalleReserva(estado: 'Cancelada');
}
