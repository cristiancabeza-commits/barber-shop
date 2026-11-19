import 'package:flutter/material.dart';

import '../../widgets/agenda_operativa.dart';

class PantallaAgendaCalendario extends StatelessWidget {
  const PantallaAgendaCalendario({super.key});
  @override
  Widget build(BuildContext context) => const AgendaOperativa(calendario: true);
}
