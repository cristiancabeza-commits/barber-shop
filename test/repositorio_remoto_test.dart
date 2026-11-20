import 'dart:convert';

import 'package:barrber_figma/models/datos_barberia.dart';
import 'package:barrber_figma/repositories/repositorio_remoto.dart';
import 'package:barrber_figma/services/remote/api_service.dart';
import 'package:barrber_figma/services/remote/servicio_barberia.dart';
import 'package:barrber_figma/services/remote/servicio_sesion.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'Los módulos comparten sus cambios con el coordinador de pantallas',
    () async {
      final api = ApiService(baseUrl: 'https://example.test');
      final sesion = ServicioSesion(api);
      final repositorio = RepositorioRemoto(ServicioBarberia(api, sesion));
      var avisos = 0;
      repositorio.addListener(() => avisos++);
      final cliente = MockClient((peticion) async {
        if (peticion.url.path == '/api/Sesion') {
          return http.Response('{"accessToken":"token_prueba"}', 200);
        }
        final Object datos;
        switch (peticion.url.path) {
          case '/api/Especialidades':
            datos = [
              {'id': 3, 'nombre': 'Barberia'},
            ];
          case '/api/Reservas':
            datos = [
              {
                'id': 15,
                'fecha': '2026-11-20T08:00:00',
                'clienteId': 2,
                'servicioId': 5,
              },
            ];
          case '/api/liquidaciones-comisiones':
            datos = [
              {
                'id': 16,
                'fechaInicio': '2026-11-18',
                'fechaFin': '2026-11-18',
                'totalFacturado': 26000,
              },
            ];
          default:
            throw StateError('Petición inesperada: ${peticion.url.path}');
        }
        return http.Response(jsonEncode({'data': datos}), 200);
      });
      await http.runWithClient(() async {
        await sesion.iniciar('usuario', 'clave');
        // Se recarga cada módulo directamente, sin pasar por cargar() del coordinador.
        await repositorio.especialidades.cargar();
        expect(
          repositorio.listar(Modulo.especialidades).single.nombre,
          'Barberia',
        );
        expect(avisos, 1);
        await repositorio.moduloReservas.cargar();
        expect(repositorio.reservas.single.id, '15');
        expect(avisos, 2);
        await repositorio.liquidaciones.cargar();
        expect(repositorio.cierres.single.total, 26000);
        expect(avisos, 3);
      }, () => cliente);
      repositorio.dispose();
    },
  );

  test('Carga datos de la cuenta y guarda el cliente con el token', () async {
    final api = ApiService(baseUrl: 'https://example.test');
    final sesion = ServicioSesion(api);
    final repositorio = RepositorioRemoto(ServicioBarberia(api, sesion));
    final clientes = <Map<String, dynamic>>[];
    final cliente = MockClient((peticion) async {
      final ruta = peticion.url.path;
      if (ruta == '/api/Sesion') {
        return http.Response('{"accessToken":"token_prueba"}', 200);
      }
      expect(peticion.headers['Authorization'], 'Bearer token_prueba');
      if (ruta == '/api/Clientes' && peticion.method == 'POST') {
        final datos = jsonDecode(peticion.body) as Map<String, dynamic>;
        expect(datos['fechaNacimiento'], '2001-05-20');
        clientes.add({'id': 18, ...datos});
        return http.Response('{"data":{"id":18}}', 201);
      }
      expect(peticion.method, 'GET');
      if (ruta == '/api/Comisiones/6/servicios') {
        return http.Response(
          jsonEncode({
            'data': {
              'id': 6,
              'comisionServicios': [
                {
                  'id': 10,
                  'servicioId': 5,
                  'precio': 26000,
                  'valorComision': 3900,
                },
              ],
            },
          }),
          200,
        );
      }

      return http.Response.bytes(
        utf8.encode(
          jsonEncode({
            'success': true,
            'data': ruta == '/api/Clientes'
                ? clientes
                : ruta == '/api/liquidaciones-comisiones'
                ? [
                    {
                      'id': 16,
                      'fechaInicio': '2026-10-27',
                      'fechaFin': '2026-10-27',
                      'totalFacturado': 26000,
                      'subtotalComisionProfesionales': 3900,
                    },
                  ]
                : [],
          }),
        ),
        200,
      );
    });
    await http.runWithClient(() async {
      expect(await sesion.iniciar('usuario', 'clave'), isTrue);
      await repositorio.cargar();
      expect(repositorio.listar(Modulo.clientes), isEmpty);
      expect(repositorio.cierres.single.total, 26000);
      expect(repositorio.cierres.single.comisiones, 3900);
      final detalle = await repositorio.serviciosComision('6');
      expect(detalle.single['valorComision'], 3900);

      await repositorio.guardar(
        Modulo.clientes,
        Registro('nuevo', {
          'nombre': 'Lucía',
          'apellidos': 'Rojas',
          'nacimiento': '20/05/2001',
          'correo': 'lucia@example.test',
        }),
      );
      final guardado = repositorio.listar(Modulo.clientes).single;
      expect(guardado.id, '18');
      expect(guardado.nombre, 'Lucía Rojas');
    }, () => cliente);
    repositorio.dispose();
  });
  test(
    'Consulta agenda y registra varios días con el contrato publicado',
    () async {
      final api = ApiService(baseUrl: 'https://example.test');
      final sesion = ServicioSesion(api);
      final repositorio = RepositorioRemoto(ServicioBarberia(api, sesion));
      final peticiones = <String>[];
      final cliente = MockClient((peticion) async {
        final ruta = peticion.url.path;
        peticiones.add('${peticion.method} $ruta');
        if (ruta == '/api/Sesion')
          return http.Response('{"accessToken":"token_prueba"}', 200);
        if (ruta == '/api/agenda') {
          expect(peticion.url.queryParameters, {
            'fecha': '2026-11-10',
            'servicioId': '5',
            'profesionalId': '4',
          });
          return http.Response('{"data":[{"fecha":"2026-11-10 08:30"}]}', 200);
        }
        if (ruta == '/api/horarios-laboral/masivo') {
          final datos = jsonDecode(peticion.body) as Map<String, dynamic>;
          expect(datos['dias'], [1, 3]);
          expect(datos['horaInicio'], '08:00:00');
          expect(datos['horaInicioAlmuerzo'], isNull);
          return http.Response('{"success":true}', 201);
        }
        return http.Response('{"data":[]}', 200);
      });
      await http.runWithClient(() async {
        await sesion.iniciar('usuario', 'clave');
        expect(
          await repositorio.horasAgenda(
            DateTime(2026, 11, 10),
            '5',
            profesional: '4',
          ),
          ['08:30'],
        );
        await repositorio.agendaDiaria(DateTime(2026, 11, 10));
        await repositorio.guardarHorarios(
          Registro('nuevo', {
            'profesional': '4',
            'inicio': '08:00',
            'fin': '17:00',
            'almuerzo': 'no',
          }),
          {'Lunes', 'Miércoles'},
        );
      }, () => cliente);
      expect(
        peticiones,
        containsAllInOrder([
          'GET /api/agenda',
          'GET /api/agenda/2026-11-10',
          'POST /api/horarios-laboral/masivo',
          'GET /api/horarios-laboral',
        ]),
      );
      repositorio.dispose();
    },
  );
}
