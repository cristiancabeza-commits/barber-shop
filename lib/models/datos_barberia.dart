enum Modulo {
  clientes,
  especialidades,
  servicios,
  profesionales,
  horarios,
  inasistencias,
}

/// Datos de presentación. El adaptador HTTP deberá mapear el contrato de la API.
class Registro {
  Registro(this.id, Map<String, String> datos, {this.activo = true})
    : datos = Map.unmodifiable(datos);
  final String id;
  final Map<String, String> datos;
  final bool activo;
  String valor(String campo) => datos[campo] ?? '';
  String get nombre => [
    valor('nombre'),
    valor('apellidos'),
  ].where((parte) => parte.isNotEmpty).join(' ');
}

class Reserva {
  const Reserva({
    required this.id,
    required this.clienteId,
    required this.servicioId,
    required this.profesionalId,
    required this.fecha,
    required this.hora,
    required this.creada,
    required this.precio,
    required this.duracion,
    required this.comision,
    this.estado = 'Programada',
    this.medioPago = 'Efectivo',
    this.motivo = '',
  });
  final String id,
      clienteId,
      servicioId,
      profesionalId,
      hora,
      estado,
      medioPago,
      motivo;
  final DateTime fecha, creada;
  final int precio, duracion;
  final double comision;
  Reserva copiar({
    String? id,
    String? profesionalId,
    DateTime? fecha,
    String? hora,
    String? estado,
    String? medioPago,
    String? motivo,
  }) => Reserva(
    id: id ?? this.id,
    clienteId: clienteId,
    servicioId: servicioId,
    profesionalId: profesionalId ?? this.profesionalId,
    fecha: fecha ?? this.fecha,
    hora: hora ?? this.hora,
    creada: creada,
    precio: precio,
    duracion: duracion,
    comision: comision,
    estado: estado ?? this.estado,
    medioPago: medioPago ?? this.medioPago,
    motivo: motivo ?? this.motivo,
  );
}

class Cierre {
  Cierre(
    this.id,
    this.desde,
    this.hasta,
    List<Reserva> reservas, {
    this.totalFacturado,
    this.totalComisionesProfesionales,
  }) : reservas = List.unmodifiable(reservas);
  final String id;
  final DateTime desde, hasta;
  final List<Reserva> reservas;
  final int? totalFacturado;
  final double? totalComisionesProfesionales;
  int get total =>
      totalFacturado ?? reservas.fold(0, (suma, r) => suma + r.precio);
  double get comisiones =>
      totalComisionesProfesionales ??
      reservas.fold(0, (suma, r) => suma + r.precio * r.comision / 100);
  Set<String> get profesionales => reservas.map((r) => r.profesionalId).toSet();
}

String fechaTexto(DateTime fecha) =>
    '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
DateTime? leerFecha(String valor) {
  final partes = valor.split('/');
  if (partes.length != 3) return null;
  final d = int.tryParse(partes[0]),
      m = int.tryParse(partes[1]),
      a = int.tryParse(partes[2]);
  if (d == null || m == null || a == null) return null;
  final fecha = DateTime(a, m, d);
  return fecha.day == d && fecha.month == m && fecha.year == a ? fecha : null;
}

String dinero(num valor) {
  final partes = valor.round().toString().split('').reversed.toList();
  final salida = <String>[];
  for (var i = 0; i < partes.length; i++) {
    if (i > 0 && i % 3 == 0) salida.add('.');
    salida.add(partes[i]);
  }
  return '\$${salida.reversed.join()}';
}

int minutos(String hora) {
  final p = hora.split(':');
  return p.length == 2
      ? (int.tryParse(p[0]) ?? 0) * 60 + (int.tryParse(p[1]) ?? 0)
      : 0;
}
