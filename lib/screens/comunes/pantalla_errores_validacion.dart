import 'package:flutter/material.dart';

import '../../widgets/componentes.dart';

class PantallaErroresValidacion extends StatelessWidget {
  const PantallaErroresValidacion({super.key});
  @override
  Widget build(BuildContext context) => EstructuraPantalla(
    title: "Ejemplo de validación",
    active: 3,
    bottom: true,
    children: [
      CampoVista(
        "Nombre *",
        hint: "Nombre del cliente",
        error: "Este campo es obligatorio",
      ),
      CampoVista(
        "Documento *",
        hint: "Documento del cliente",
        error: "Este campo es obligatorio",
      ),
      CampoVista(
        "Correo electrónico",
        value: "correo-invalido",
        error: "Ingresa un correo válido",
      ),
      BotonVista(
        "Volver a formulario",
        route: "/nuevo-cliente",
        secondary: true,
      ),
    ],
  );
}
