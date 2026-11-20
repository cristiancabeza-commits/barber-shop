import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'controllers/estado_aplicacion.dart';
import 'routes/routes.dart';
import 'theme/tema_aplicacion.dart';
import 'theme/preferencia_tema.dart';

void main() {
  EstadoAplicacion.usarApi();
  runApp(const AplicacionBarberia());
}

class AplicacionBarberia extends StatelessWidget {
  const AplicacionBarberia({super.key});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<ThemeMode>(
    valueListenable: PreferenciaTema.modo,
    builder: (context, modo, _) => MaterialApp(
      title: 'Barrber Shop',
      locale: const Locale('es', 'CO'),
      supportedLocales: const [Locale('es', 'CO')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      debugShowCheckedModeBanner: false,
      theme: TemaAplicacion.claro,
      darkTheme: TemaAplicacion.oscuro,
      themeMode: modo,
      builder: (context, child) {
        final oscuro = Theme.of(context).brightness == Brightness.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value:
              (oscuro ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
                  .copyWith(
                    statusBarColor: Colors.transparent,
                    systemNavigationBarColor: Theme.of(context)
                        .colorScheme
                        .surface,
                    systemNavigationBarIconBrightness: oscuro
                        ? Brightness.light
                        : Brightness.dark,
                  ),
          child: child!,
        );
      },
      initialRoute: const String.fromEnvironment(
        'PANTALLA',
        defaultValue: '/presentacion',
      ),
      routes: Rutas.pantallas,
      onGenerateRoute: (settings) => settings.name == '/'
          ? MaterialPageRoute(builder: Rutas.pantallas['/presentacion']!)
          : null,
    ),
  );
}
