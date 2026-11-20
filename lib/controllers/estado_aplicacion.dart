import '../models/datos_barberia.dart';
import '../repositories/repositorio_barberia.dart';
import '../repositories/repositorio_memoria.dart';
import '../repositories/repositorio_remoto.dart';

abstract final class EstadoAplicacion {
  static DateTime Function() ahora = DateTime.now;
  static RepositorioBarberia repositorio = RepositorioMemoria();
  static Future<void> cargarSesion() async {
    final actual = repositorio;
    if (actual is RepositorioRemoto) await actual.cargar();
  }

  static void usarApi() {
    repositorio = RepositorioRemoto.produccion();
    borrador = null;
    ultimaReservaId = null;
    borradorCierre = null;
    ultimoCierreId = null;
  }

  static Reserva? borrador;
  static String? ultimaReservaId;
  static Cierre? borradorCierre;
  static String? ultimoCierreId;
  static String nuevoId(String prefijo) =>
      '$prefijo-${DateTime.now().microsecondsSinceEpoch}';
  static Registro registro(Modulo modulo, String id) {
    return repositorio
        .listar(modulo)
        .firstWhere(
          (r) => r.id == id,
          orElse: () => Registro(id, {'nombre': 'Registro no disponible'}),
        );
  }

  static void reiniciar({DateTime? fecha}) {
    ahora = fecha == null ? DateTime.now : () => fecha;
    repositorio = RepositorioMemoria(fecha: fecha);
    borrador = null;
    ultimaReservaId = null;
    borradorCierre = null;
    ultimoCierreId = null;
  }
}
