import '../controllers/estado_aplicacion.dart';
import '../repositories/repositorio_remoto.dart';
import '../services/remote/servicio_sesion.dart';

import 'package:flutter/material.dart';

import '../theme/preferencia_tema.dart';

void abrirVista(BuildContext context, String route) {
  if (ModalRoute.of(context)?.settings.name == route) return;
  if (route == '/inicio-principal' &&
      [
        '/inicio-sesion',
        '/error-inicio-sesion',
      ].contains(ModalRoute.of(context)?.settings.name)) {
    Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
  } else {
    Navigator.of(context).pushNamed(route);
  }
}

void irSeccion(BuildContext context, String ruta) {
  if (ModalRoute.of(context)?.settings.name == ruta) return;
  Navigator.of(context).pushNamedAndRemoveUntil(
    ruta,
    (route) =>
        route.settings.name == '/inicio-principal' &&
        ruta != '/inicio-principal',
  );
}

void regresarVista(BuildContext context) {
  if (Navigator.of(context).canPop()) {
    Navigator.of(context).pop();
  } else {
    irSeccion(context, '/inicio-principal');
  }
}

void regresarAlModulo(BuildContext context, String ruta) {
  final navegador = Navigator.of(context);
  var encontrado = false;
  navegador.popUntil((route) {
    encontrado = route.settings.name == ruta;
    return encontrado || route.isFirst;
  });
  if (!encontrado) navegador.pushNamed(ruta);
}

void mostrarAviso(BuildContext context, String message) =>
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));

void mostrarModulos(BuildContext context) {
  const modulos = {
    'Especialidades': '/especialidades',
    'Servicios': '/servicios',
    'Profesionales': '/profesionales',
    'Clientes': '/clientes',
    'Horarios': '/horarios',
    'Inasistencias': '/inasistencias',
    'Cierres de caja': '/cierres-caja',
    'Comisiones': '/consulta-comisiones',
    'Mis servicios': '/mis-servicios',
    'Cerrar sesión': '/inicio-sesion',
  };
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * .75,
        child: ListView(
          children: [
            const ListTile(title: Text('Más opciones')),
            ValueListenableBuilder<ThemeMode>(
              valueListenable: PreferenciaTema.modo,
              builder: (context, modo, _) => SwitchListTile(
                title: const Text('Modo oscuro'),
                subtitle: Text(
                  modo == ThemeMode.dark
                      ? 'Apariencia oscura'
                      : 'Apariencia clara',
                ),
                secondary: Icon(
                  modo == ThemeMode.dark
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                ),
                value: modo == ThemeMode.dark,
                onChanged: PreferenciaTema.cambiar,
              ),
            ),
            ...modulos.entries.map(
              (entry) => ListTile(
                title: Text(entry.key),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(sheetContext);
                  if (entry.key == 'Cerrar sesión') {
                    ServicioSesion.instancia.cerrar();
                    if (EstadoAplicacion.repositorio is RepositorioRemoto) {
                      EstadoAplicacion.usarApi();
                    }
                    Navigator.of(context)
                        .pushNamedAndRemoveUntil(entry.value, (_) => false);
                  } else {
                    abrirVista(context, entry.value);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
