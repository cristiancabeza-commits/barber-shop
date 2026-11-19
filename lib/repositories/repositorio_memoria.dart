import '../models/datos_barberia.dart';
import 'repositorio_barberia.dart';

/// Implementación local: sus cambios duran hasta cerrar el proceso.
class RepositorioMemoria extends RepositorioBarberia {
  RepositorioMemoria({DateTime? fecha}) {
    reiniciar(fecha: fecha);
  }
  final _catalogos = <Modulo, List<Registro>>{};
  final _reservas = <Reserva>[];
  final _cierres = <Cierre>[];
  @override
  List<Registro> listar(Modulo modulo) =>
      List.unmodifiable(_catalogos[modulo] ?? []);
  @override
  List<Reserva> get reservas => List.unmodifiable(_reservas);
  @override
  List<Cierre> get cierres => List.unmodifiable(_cierres);
  @override
  Future<void> guardar(Modulo modulo, Registro registro) async {
    final lista = _catalogos.putIfAbsent(modulo, () => []);
    final i = lista.indexWhere((r) => r.id == registro.id);
    if (i < 0) {
      lista.add(registro);
    } else {
      lista[i] = registro;
    }
    notifyListeners();
  }

  @override
  Future<void> guardarReserva(Reserva reserva) async {
    final i = _reservas.indexWhere((r) => r.id == reserva.id);
    if (i < 0) {
      _reservas.add(reserva);
    } else {
      _reservas[i] = reserva;
    }
    notifyListeners();
  }

  @override
  Future<void> guardarCierre(Cierre cierre) async {
    final ids = _cierres.expand((c) => c.reservas).map((r) => r.id).toSet();
    if (cierre.reservas.isEmpty)
      throw StateError('No hay servicios atendidos sin cerrar en ese periodo.');
    if (cierre.reservas.any((r) => ids.contains(r.id)))
      throw StateError('Hay servicios que ya pertenecen a otro cierre.');
    _cierres.add(cierre);
    notifyListeners();
  }

  void reiniciar({DateTime? fecha}) {
    _catalogos.clear();
    _reservas.clear();
    _cierres.clear();
    _catalogos[Modulo.especialidades] = [
      Registro('E-001', {'nombre': 'Corte y peinado'}),
      Registro('E-002', {'nombre': 'Coloración'}),
      Registro('E-003', {'nombre': 'Barbería clásica'}),
      Registro('E-004', {'nombre': 'Tratamientos capilares'}, activo: false),
    ];
    _catalogos[Modulo.clientes] = [
      Registro('CL-001', {
        'nombre': 'Juan',
        'apellidos': 'Pérez',
        'documento': '1098765432',
        'celular': '310 555 1234',
        'correo': 'juan@email.com',
        'nacimiento': '15/05/1995',
      }),
      Registro('CL-002', {
        'nombre': 'Andrés',
        'apellidos': 'Mendoza',
        'documento': '1076543210',
        'celular': '315 222 9876',
        'correo': 'andres@email.com',
      }),
      Registro('CL-003', {
        'nombre': 'Daniel',
        'apellidos': 'Lupita',
        'documento': '1023456789',
        'celular': '320 888 1122',
        'correo': 'daniel@email.com',
      }),
      Registro('CL-004', {
        'nombre': 'Mateo',
        'apellidos': 'Gómez',
        'documento': '1054321098',
        'celular': '300 444 5566',
        'correo': 'mateo@outlook.com',
      }),
    ];
    _catalogos[Modulo.profesionales] = [
      Registro('P-001', {
        'nombre': 'Carlos',
        'apellidos': 'Gómez',
        'documento': '98765432',
        'especialidad': 'E-003',
        'nacimiento': '10/03/1990',
        'comision': '15',
      }),
      Registro('P-002', {
        'nombre': 'María',
        'apellidos': 'López',
        'documento': '87654321',
        'especialidad': 'E-002',
        'nacimiento': '20/06/1994',
        'comision': '15',
      }),
      Registro('P-003', {
        'nombre': 'Pedro',
        'apellidos': 'Ruiz',
        'documento': '76543210',
        'especialidad': 'E-001',
        'nacimiento': '04/02/1992',
        'comision': '10',
      }, activo: false),
    ];
    _catalogos[Modulo.servicios] = [
      Registro('S-001', {
        'nombre': 'Corte clásico',
        'especialidad': 'E-003',
        'precio': '25000',
        'duracion': '30',
      }),
      Registro('S-002', {
        'nombre': 'Barba completa',
        'especialidad': 'E-003',
        'precio': '20000',
        'duracion': '25',
      }),
      Registro('S-003', {
        'nombre': 'Corte + Barba',
        'especialidad': 'E-003',
        'precio': '40000',
        'duracion': '50',
      }),
      Registro('S-004', {
        'nombre': 'Tinte capilar',
        'especialidad': 'E-002',
        'precio': '60000',
        'duracion': '90',
      }),
    ];
    final hoy = fecha ?? DateTime.now();
    final dia = DateTime(hoy.year, hoy.month, hoy.day);
    _reservas.addAll([
      Reserva(
        id: 'R-001',
        clienteId: 'CL-001',
        servicioId: 'S-001',
        profesionalId: 'P-001',
        fecha: dia,
        hora: '10:00',
        creada: dia.subtract(const Duration(days: 1)),
        precio: 25000,
        duracion: 30,
        comision: 15,
      ),
      Reserva(
        id: 'R-002',
        clienteId: 'CL-002',
        servicioId: 'S-004',
        profesionalId: 'P-002',
        fecha: dia,
        hora: '11:30',
        creada: dia.subtract(const Duration(days: 1)),
        precio: 60000,
        duracion: 90,
        comision: 15,
        estado: 'Atendida',
      ),
      Reserva(
        id: 'R-003',
        clienteId: 'CL-004',
        servicioId: 'S-003',
        profesionalId: 'P-001',
        fecha: dia,
        hora: '14:00',
        creada: dia,
        precio: 40000,
        duracion: 50,
        comision: 15,
        estado: 'Cancelada',
        motivo: 'Cambio de planes',
      ),
    ]);
    _catalogos[Modulo.horarios] = [
      for (final profesional in ['P-001', 'P-002', 'P-003'])
        for (var d = 0; d < 7; d++)
          Registro('H-$profesional-$d', {
            'nombre': [
              'Lunes',
              'Martes',
              'Miércoles',
              'Jueves',
              'Viernes',
              'Sábado',
              'Domingo',
            ][d],
            'profesional': profesional,
            'inicio': '08:00',
            'fin': d == 5 ? '13:00' : '18:00',
            'almuerzo': d < 5 ? 'sí' : 'no',
            'inicioAlmuerzo': '12:00',
            'finAlmuerzo': '14:00',
          }, activo: d != 6),
    ];
    _catalogos[Modulo.inasistencias] = [];
    // Historial coherente, separado de los servicios pendientes de cerrar hoy.
    final anterior = dia.subtract(const Duration(days: 7));
    _cierres.add(
      Cierre('C-001', anterior, anterior, [
        Reserva(
          id: 'R-HIST-1',
          clienteId: 'CL-001',
          servicioId: 'S-001',
          profesionalId: 'P-001',
          fecha: anterior,
          hora: '10:00',
          creada: anterior,
          precio: 25000,
          duracion: 30,
          comision: 15,
          estado: 'Atendida',
        ),
      ]),
    );
    notifyListeners();
  }
}
