import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Recuerda el último acceso válido mediante el almacenamiento de la plataforma.
class CredencialesGuardadas {
  static const _almacen = FlutterSecureStorage();
  static const _llave = 'ultimo_acceso_barberia';

  Future<({String usuario, String clave})?> leer() async {
    try {
      final texto = await _almacen.read(key: _llave);
      if (texto == null) return null;
      final datos = jsonDecode(texto);
      if (datos is! Map ||
          datos['usuario'] is! String ||
          datos['clave'] is! String) {
        return null;
      }
      return (
        usuario: datos['usuario'] as String,
        clave: datos['clave'] as String,
      );
    } on Exception {
      return null;
    }
  }

  Future<bool> guardar(String usuario, String clave) async {
    try {
      await _almacen.write(
        key: _llave,
        value: jsonEncode({'usuario': usuario, 'clave': clave}),
      );
      return true;
    } on Exception {
      return false;
    }
  }
}
