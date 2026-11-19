class ListarServiciosDeComisionResponse {
  const ListarServiciosDeComisionResponse(this.datos);

  factory ListarServiciosDeComisionResponse.fromJson(Object? json) {
    final filas = json is Map ? json['comisionServicios'] : json;
    if (filas is! List) {
      throw const FormatException('Detalle de comisión inválido');
    }
    return ListarServiciosDeComisionResponse(
      List.unmodifiable(
        filas.map((fila) => Map<String, dynamic>.from(fila as Map)),
      ),
    );
  }

  final List<Map<String, dynamic>> datos;
}
