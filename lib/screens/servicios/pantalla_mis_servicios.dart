import 'package:flutter/material.dart';

import '../../widgets/agenda_operativa.dart';

class PantallaMisServicios extends StatelessWidget {
  const PantallaMisServicios({super.key});
  @override
  Widget build(BuildContext context) =>
      const AgendaOperativa(misServicios: true);
}
