import 'package:flutter/foundation.dart';

import '../models/datos_barberia.dart';

/// Contrato interno. No presupone rutas, tokens ni campos JSON del servidor.
abstract class RepositorioBarberia extends ChangeNotifier {
  List<Registro> listar(Modulo modulo);
  List<Reserva> get reservas;
  List<Cierre> get cierres;
  Future<void> guardar(Modulo modulo, Registro registro);
  Future<void> guardarReserva(Reserva reserva);
  Future<void> guardarCierre(Cierre cierre);
}
