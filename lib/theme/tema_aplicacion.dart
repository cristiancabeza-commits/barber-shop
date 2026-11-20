import 'package:flutter/material.dart';

import 'colores_aplicacion.dart';

abstract final class TemaAplicacion {
  static final claro = crear(false);
  static final oscuro = crear(true);
  static ThemeData crear(bool oscuro) {
    final texto = oscuro ? const Color(0xFFF5F5F7) : const Color(0xFF202126);
    final secundario = oscuro
        ? const Color(0xFFB8BDC7)
        : const Color(0xFF59606C);
    final superficie = oscuro ? ColoresAplicacion.superficie : Colors.white;
    final fondo = oscuro ? ColoresAplicacion.fondo : const Color(0xFFF6F5F2);
    final borde = oscuro
        ? const Color(0xFF3C414B)
        : const Color.fromARGB(255, 203, 201, 211);
    final scheme =
        ColorScheme.fromSeed(
          seedColor: ColoresAplicacion.rojo,
          brightness: oscuro ? Brightness.dark : Brightness.light,
        ).copyWith(
          primary: ColoresAplicacion.rojo,
          onPrimary: Colors.white,
          secondary: oscuro
              ? ColoresAplicacion.dorado
              : const Color(0xFF84620A),
          surface: superficie,
          onSurface: texto,
          onSurfaceVariant: secundario,
          outline: borde,
        );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: fondo,
      dividerColor: borde,
      textTheme: TextTheme(
        titleLarge: TextStyle(
          fontFamily: 'Gabarito',
          fontSize: 22,
          height: 1.2,
          fontWeight: FontWeight.w700,
          color: texto,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          height: 1.4,
          fontWeight: FontWeight.w700,
          color: texto,
        ),
        bodyLarge: TextStyle(fontSize: 16, height: 1.5, color: texto),
        bodyMedium: TextStyle(fontSize: 14, height: 1.5, color: texto),
        bodySmall: TextStyle(fontSize: 12, height: 1.5, color: secundario),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: fondo,
        foregroundColor: texto,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          fontFamily: 'Gabarito',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: texto,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: superficie,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: TextStyle(color: secundario),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borde),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.secondary, width: 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: ColoresAplicacion.rojo,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: texto,
          minimumSize: const Size.fromHeight(52),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          side: BorderSide(color: borde),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.secondary,
          minimumSize: const Size(48, 48),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        shape: CircleBorder(),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: texto,
        contentTextStyle: TextStyle(color: fondo),
      ),
    );
  }
}
