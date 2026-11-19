import 'package:flutter/material.dart';

class CampoContrasena extends StatefulWidget {
  const CampoContrasena({super.key});
  @override
  State<CampoContrasena> createState() => _EstadoContrasena();
}

class _EstadoContrasena extends State<CampoContrasena> {
  bool hidden = true;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Contraseña', style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      TextFormField(
        initialValue: 'demo1234',
        obscureText: hidden,
        decoration: InputDecoration(
          suffixIcon: IconButton(
            tooltip: hidden ? 'Mostrar contraseña' : 'Ocultar contraseña',
            onPressed: () => setState(() => hidden = !hidden),
            icon: Icon(
              hidden
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
        ),
      ),
    ],
  );
}
