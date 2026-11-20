import 'package:flutter/foundation.dart';

import '../models/datos_barberia.dart';
import 'formato_repositorio.dart';
import '../services/remote/liquidaciones_service.dart';
import '../models/api/liquidaciones/crear_liquidacion_request.dart';
import '../models/api/liquidaciones/listar_liquidaciones_request.dart';
import '../services/remote/api_service.dart';
import '../services/remote/servicio_barberia.dart';

class RepositorioLiquidaciones extends ChangeNotifier {
  RepositorioLiquidaciones(ServicioBarberia conexion)
    : _liquidaciones = LiquidacionesService(conexion);
  final LiquidacionesService _liquidaciones;
  List<Cierre> _cierres = [];
  List<Cierre> get cierres => List.unmodifiable(_cierres);
  String? ultimoIdCierre;
  Future<Cierre?> ultimoCierre() async {
    try {
      final datos = (await _liquidaciones.listarLiquidaciones(
        const ListarLiquidacionesRequest(ultimo: 'true'),
      )).datos;
      final fila = datos is List ? datos.firstOrNull : datos;
      if (fila == null) return null;
      final cierre = _cierre(Map<String, dynamic>.from(fila as Map));
      if (!_cierres.any((c) => c.id == cierre.id)) {
        _cierres = [..._cierres, cierre];
        notifyListeners();
      }
      return cierre;
    } on ErrorApi catch (error) {
      if (error.estado != 404) rethrow;
      return null;
    }
  }

  Future<void> cargar() async {
    List<Map<String, dynamic>> filas;
    try {
      final datos = (await _liquidaciones.listarLiquidaciones(
        const ListarLiquidacionesRequest(),
      )).datos;
      if (datos is! List) throw const FormatException('Se esperaba una lista');
      filas = datos
          .map((fila) => Map<String, dynamic>.from(fila as Map))
          .toList();
    } on ErrorApi catch (error) {
      if (error.estado != 404) rethrow;
      filas = [];
    }
    _cierres = filas.map(_cierre).toList();
    notifyListeners();
  }

  Cierre _cierre(Map<String, dynamic> fila) => Cierre(
    textoApi(fila['id'] ?? fila['liquidacionComisionId']),
    DateTime.parse(textoApi(fila['fechaInicio'])),
    DateTime.parse(textoApi(fila['fechaFin'])),
    [],
    totalFacturado: num.tryParse(textoApi(fila['totalFacturado']))?.round(),
    totalComisionesProfesionales: double.tryParse(
      textoApi(fila['subtotalComisionProfesionales']),
    ),
  );

  Future<void> guardarCierre(Cierre cierre) async {
    final datos = (await _liquidaciones.crearLiquidacion(
      CrearLiquidacionRequest(
        fechaInicio: fechaIso(cierre.desde),
        fechaFin: fechaIso(cierre.hasta),
      ),
    )).datos;
    ultimoIdCierre = idCreado(datos, 'liquidacionComisionId');
    await cargar();
  }
}
