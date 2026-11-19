import 'package:flutter/material.dart';

import 'campo_vista.dart';

class CamposAlmuerzo extends StatefulWidget {
  const CamposAlmuerzo({super.key});
  @override
  State<CamposAlmuerzo> createState() => _EstadoAlmuerzo();
}

class _EstadoAlmuerzo extends State<CamposAlmuerzo> {
  bool lunch = true;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Tiene almuerzo'),
        value: lunch,
        onChanged: (v) => setState(() => lunch = v),
      ),
      if (lunch)
        const Row(
          children: [
            Expanded(child: CampoVista('Inicio almuerzo', value: '12:00 PM')),
            SizedBox(width: 12),
            Expanded(child: CampoVista('Fin almuerzo', value: '02:00 PM')),
          ],
        ),
    ],
  );
}
