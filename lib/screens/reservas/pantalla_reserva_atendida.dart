import 'package:flutter/material.dart';

import '../../widgets/flujo_reservas.dart';

class PantallaReservaAtendida extends StatelessWidget {
  const PantallaReservaAtendida({super.key});
  @override
  Widget build(BuildContext context) =>
      const DetalleReserva(estado: 'Atendida');
}
