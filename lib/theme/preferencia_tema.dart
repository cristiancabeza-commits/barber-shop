import 'package:flutter/material.dart';

abstract final class PreferenciaTema {
  static final modo = ValueNotifier<ThemeMode>(ThemeMode.light);
  static void cambiar(bool oscuro) =>
      modo.value = oscuro ? ThemeMode.dark : ThemeMode.light;
}
