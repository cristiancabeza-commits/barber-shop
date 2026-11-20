import 'package:flutter/foundation.dart';

import '../models/datos_barberia.dart';

abstract class RepositorioCatalogo extends ChangeNotifier {
  List<Registro> _registros = [];
  List<Registro> get registros => List.unmodifiable(_registros);

  Future<List<Registro>> consultarTodos();
  Future<Registro> consultar(Registro registro);
  Future<void> guardar(Registro registro);
  Future<void> eliminar(String id);

  Future<void> cargar() async {
    _registros = await consultarTodos();
    notifyListeners();
  }
}
