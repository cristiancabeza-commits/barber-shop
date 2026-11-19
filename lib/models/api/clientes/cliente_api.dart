class ClienteApi {
  ClienteApi.fromJson(Map<String, dynamic> json)
    : id = (json['id'] ?? json['clienteId'])?.toString(),
      documento = json['documento']?.toString() ?? '',
      nombres = (json['nombres'] ?? json['nombre'])?.toString() ?? '',
      apellidos = json['apellidos']?.toString() ?? '',
      celular = json['celular']?.toString() ?? '',
      correo = json['correo']?.toString() ?? '',
      fechaNacimiento = DateTime.tryParse(
        json['fechaNacimiento']?.toString() ?? '',
      );

  final String? id;
  final String documento, nombres, apellidos, celular, correo;
  final DateTime? fechaNacimiento;
}
