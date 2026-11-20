import 'package:flutter/material.dart';

import '../../widgets/componentes.dart';

class PantallaSinResultados extends StatelessWidget {
  const PantallaSinResultados({super.key});
  @override
  Widget build(BuildContext context) => EstructuraPantalla(
    title: "Sin resultados",
    active: 3,
    bottom: true,
    children: [
      const Icon(Icons.search_off, size: 64),
      TituloSeccion("No encontramos coincidencias"),
      Text("Prueba con otro nombre, documento o limpia los filtros."),
      BotonVista("Volver a clientes", route: "/clientes"),
      BotonVista("Crear cliente", route: "/nuevo-cliente", secondary: true),
    ],
  );
}
