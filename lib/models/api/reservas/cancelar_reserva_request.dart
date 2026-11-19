/// DELETE /api/Reservas/{id}
class CancelarReservaRequest {
  const CancelarReservaRequest({
    required this.id,
    this.motivoCancelacionId,
    required this.motivoOtro,
  });

  final String id;
  final int? motivoCancelacionId;
  final String motivoOtro;

  Map<String, Object?> toJson() => {
    'motivoCancelacionId': motivoCancelacionId,
    'motivoOtro': motivoOtro,
  };
}
