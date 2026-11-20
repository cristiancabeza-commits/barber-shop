class ListarInasistenciasRequest {
  const ListarInasistenciasRequest({this.profesionalId});

  final String? profesionalId;

  Map<String, String> get filtros => {
    if (profesionalId != null) 'profesionalId': profesionalId!,
  };
}
