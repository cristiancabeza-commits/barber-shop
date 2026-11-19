/// GET /api/Comisiones/{comisionId}/servicios
class ListarServiciosDeComisionRequest {
  const ListarServiciosDeComisionRequest({required this.comisionId});

  final String comisionId;
}
