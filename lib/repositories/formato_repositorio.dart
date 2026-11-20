import '../models/datos_barberia.dart';

const diasSemana = [
  'Domingo',
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
];

String textoApi(Object? valor) =>
    (valor is Map ? valor['id'] : valor)?.toString() ?? '';
String fechaVista(Object? valor) {
  final fecha = DateTime.tryParse(textoApi(valor));
  return fecha == null ? '' : fechaTexto(fecha);
}

String horaVista(Object? valor) {
  final texto = textoApi(valor);
  return texto.length >= 5 ? texto.substring(0, 5) : texto;
}

String fechaIso(DateTime fecha) => fecha.toIso8601String().split('T').first;
String? fechaApi(String valor) {
  final fecha = leerFecha(valor);
  return fecha == null ? null : fechaIso(fecha);
}

String? horaApi(String valor) => valor.isEmpty ? null : '$valor:00';
bool activoApi(Object? valor) => ![
  false,
  0,
  '0',
  'false',
  'inactivo',
].contains(valor?.toString().toLowerCase() ?? valor);

Registro registroApi(Modulo modulo, Map<String, dynamic> fila) {
  final dia = int.tryParse(textoApi(fila['diaSemana']));
  final id = textoApi(
    fila['id'] ??
        fila[switch (modulo) {
          Modulo.clientes => 'clienteId',
          Modulo.especialidades => 'especialidadId',
          Modulo.servicios => 'servicioId',
          Modulo.profesionales => 'profesionalId',
          Modulo.horarios => 'horarioLaboralId',
          Modulo.inasistencias => 'eventualidadId',
        }],
  );
  if (id.isEmpty) throw const FormatException('Registro sin identificador');
  return Registro(id, {
    'nombre': dia != null && dia >= 0 && dia < diasSemana.length
        ? diasSemana[dia]
        : textoApi(
            fila['nombres'] ??
                fila['nombre'] ??
                fila['diaSemana'] ??
                fila['profesionalNombre'],
          ),
    for (final campo in [
      'documento',
      'apellidos',
      'celular',
      'correo',
      'precio',
      'duracion',
      'descripcion',
    ])
      campo: textoApi(fila[campo]),
    'nacimiento': fechaVista(fila['fechaNacimiento']),
    'comision': textoApi(fila['porcentaje']),
    'especialidad': textoApi(fila['especialidadId'] ?? fila['especialidad']),
    'profesional': textoApi(fila['profesionalId'] ?? fila['profesional']),
    'inicio': horaVista(fila['horaInicio']),
    'fin': horaVista(fila['horaFin']),
    'almuerzo': fila['tieneAlmuerzo'] == true ? 'sí' : 'no',
    'inicioAlmuerzo': horaVista(fila['horaInicioAlmuerzo']),
    'finAlmuerzo': horaVista(fila['horaFinAlmuerzo']),
    'desde': fechaVista(fila['fechaInicio']),
    'hasta': fechaVista(fila['fechaFin']),
    'motivo': textoApi(fila['observacion'] ?? fila['motivo']),
    'motivoId': textoApi(fila['motivo']),
  }, activo: activoApi(fila['activo'] ?? fila['activa'] ?? fila['estado']));
}

String idCreado(Object? datos, String clave) {
  if (datos is List) datos = datos.firstOrNull;
  final id = textoApi(
    datos is Map ? datos['id'] ?? datos[clave] ?? datos['reserva'] : datos,
  );
  if (int.tryParse(id) == null)
    throw const FormatException('Falta identificador creado');
  return id;
}
