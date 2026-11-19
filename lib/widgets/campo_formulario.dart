import 'package:flutter/material.dart';

import '../models/datos_barberia.dart';

class CampoFormulario extends StatelessWidget {
  const CampoFormulario(
    this.etiqueta,
    this.controlador, {
    super.key,
    this.validar,
    this.tipo = 'texto',
    this.soloLectura = false,
    this.lineas = 1,
    this.maximo,
  });
  final String etiqueta, tipo;
  final TextEditingController controlador;
  final FormFieldValidator<String>? validar;
  final bool soloLectura;
  final int lineas;
  final int? maximo;
  @override
  Widget build(BuildContext context) => TextFormField(
    key: ValueKey(etiqueta),
    controller: controlador,
    validator: validar,
    readOnly:
        soloLectura ||
        tipo == 'fecha' ||
        tipo == 'hora' ||
        tipo == 'nacimiento',
    maxLines: lineas,
    maxLength: maximo,
    keyboardType: tipo == 'numero'
        ? TextInputType.number
        : tipo == 'correo'
        ? TextInputType.emailAddress
        : tipo == 'telefono'
        ? TextInputType.phone
        : TextInputType.text,
    decoration: InputDecoration(
      labelText: etiqueta,
      suffixIcon: soloLectura
          ? const Icon(Icons.lock_outline)
          : ['fecha', 'nacimiento', 'hora'].contains(tipo)
          ? Icon(
              tipo == 'hora' ? Icons.schedule : Icons.calendar_month_outlined,
            )
          : null,
    ),
    onTap: soloLectura
        ? null
        : () async {
            if (tipo == 'fecha' || tipo == 'nacimiento') {
              final hoy = DateUtils.dateOnly(DateTime.now());
              final limite = tipo == 'nacimiento'
                  ? hoy
                  : DateTime(2035, 12, 31);
              var inicial = leerFecha(controlador.text) ?? hoy;
              if (inicial.isAfter(limite)) inicial = limite;
              final fecha = await showDatePicker(
                context: context,
                initialDate: inicial,
                firstDate: DateTime(1900),
                lastDate: limite,
                cancelText: 'Cancelar',
                confirmText: 'Aceptar',
              );
              if (fecha != null) controlador.text = fechaTexto(fecha);
            } else if (tipo == 'hora') {
              final partes = controlador.text.split(':');
              final hora = await showTimePicker(
                context: context,
                initialTime: TimeOfDay(
                  hour: int.tryParse(partes.first) ?? 8,
                  minute: partes.length == 2
                      ? int.tryParse(partes.last) ?? 0
                      : 0,
                ),
              );
              if (hora != null)
                controlador.text =
                    '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
            }
          },
  );
}

String? requerido(String? texto) =>
    texto == null || texto.trim().isEmpty ? 'Este campo es obligatorio' : null;
String? validarCorreo(String? texto) =>
    texto == null ||
        texto.trim().isEmpty ||
        RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(texto.trim())
    ? null
    : 'Ingresa un correo válido';
String? validarEntero(String? texto, {int minimo = 0, int? maximo}) {
  final valor = int.tryParse(texto?.trim() ?? '');
  return valor == null || valor < minimo || (maximo != null && valor > maximo)
      ? (maximo == null
            ? 'Ingresa un entero mayor o igual a $minimo'
            : 'Ingresa un entero entre $minimo y $maximo')
      : null;
}
