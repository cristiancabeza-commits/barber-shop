import '../models/datos_barberia.dart';
import 'estado_aplicacion.dart';

List<String> horasDisponibles(
  String profesional,
  DateTime fecha,
  int duracion, {
  String? ignorar,
}) {
  final repo = EstadoAplicacion.repositorio;
  if (duracion <= 0) return [];
  if (repo.listar(Modulo.inasistencias).any((r) {
    final desde = leerFecha(r.valor('desde')),
        hasta = leerFecha(r.valor('hasta'));
    return r.valor('profesional') == profesional &&
        desde != null &&
        hasta != null &&
        !fecha.isBefore(desde) &&
        !fecha.isAfter(hasta);
  }))
    return [];
  final dia = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ][fecha.weekday - 1];
  final jornadas = repo
      .listar(Modulo.horarios)
      .where(
        (j) =>
            j.activo &&
            j.valor('profesional') == profesional &&
            j.nombre == dia,
      );
  final salida = <String>{};
  for (final j in jornadas) {
    for (
      var inicio = minutos(j.valor('inicio'));
      inicio + duracion <= minutos(j.valor('fin'));
      inicio += 30
    ) {
      final fin = inicio + duracion;
      if (j.valor('almuerzo') == 'sí' &&
          inicio < minutos(j.valor('finAlmuerzo')) &&
          fin > minutos(j.valor('inicioAlmuerzo')))
        continue;
      if (repo.reservas.any(
        (r) =>
            r.id != ignorar &&
            r.estado != 'Cancelada' &&
            r.profesionalId == profesional &&
            r.fecha.year == fecha.year &&
            r.fecha.month == fecha.month &&
            r.fecha.day == fecha.day &&
            inicio < minutos(r.hora) + r.duracion &&
            fin > minutos(r.hora),
      ))
        continue;
      salida.add(
        '${(inicio ~/ 60).toString().padLeft(2, '0')}:${(inicio % 60).toString().padLeft(2, '0')}',
      );
    }
  }
  return salida.toList()..sort();
}
