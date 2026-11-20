import 'package:flutter/foundation.dart';

import '../models/datos_barberia.dart';

abstract class RepositorioBarberia extends ChangeNotifier {
  List<Registro> listar(Modulo modulo);
  List<Reserva> get reservas;
  List<Cierre> get cierres;
  Future<void> guardar(Modulo modulo, Registro registro);
  Future<void> guardarReserva(Reserva reserva);
  Future<void> guardarCierre(Cierre cierre);
}
