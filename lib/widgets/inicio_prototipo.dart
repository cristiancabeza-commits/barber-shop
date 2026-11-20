import 'dart:async';

import 'package:flutter/material.dart';

import '../screens/inicio/pantalla_presentacion.dart';

class InicioPrototipo extends StatefulWidget {
  const InicioPrototipo({super.key});
  @override
  State<InicioPrototipo> createState() => _InicioPrototipoState();
}

class _InicioPrototipoState extends State<InicioPrototipo> {
  Timer? _temporizador;
  @override
  void initState() {
    super.initState();
    _temporizador = Timer(const Duration(seconds: 2), () {
      if (mounted && ModalRoute.of(context)?.isCurrent == true) {
        Navigator.of(context).pushReplacementNamed('/inicio-sesion');
      }
    });
  }

  @override
  void dispose() {
    _temporizador?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const PantallaPresentacion();
}
