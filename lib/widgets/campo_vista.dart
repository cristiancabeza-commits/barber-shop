import 'package:flutter/material.dart';

/// Campo común: texto legible, fechas con calendario y estados de solo lectura.
class CampoVista extends StatefulWidget {
  const CampoVista(
    this.label, {
    super.key,
    this.value,
    this.hint,
    this.secret = false,
    this.readOnly = false,
    this.error,
    this.lines = 1,
    this.numeric = false,
  });
  final String label;
  final String? value, hint, error;
  final bool secret, readOnly, numeric;
  final int lines;
  @override
  State<CampoVista> createState() => _EstadoCampoVista();
}

class _EstadoCampoVista extends State<CampoVista> {
  late final controlador = TextEditingController(text: widget.value);
  bool get fecha =>
      widget.label.toLowerCase().contains('fecha') && !widget.readOnly;
  @override
  void dispose() {
    controlador.dispose();
    super.dispose();
  }

  Future<void> elegirFecha() async {
    final nacimiento = widget.label.toLowerCase().contains('nacimiento');
    final limite = nacimiento ? DateTime.now() : DateTime(2035, 12, 31);
    final partes = controlador.text.split('/');
    final inicial = partes.length == 3
        ? DateTime(
            int.tryParse(partes[2]) ?? 2026,
            int.tryParse(partes[1]) ?? 10,
            int.tryParse(partes[0]) ?? 15,
          )
        : DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: inicial.isAfter(limite) ? limite : inicial,
      firstDate: DateTime(1900),
      lastDate: limite,
      helpText: widget.label,
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
    );
    if (elegida != null && mounted) {
      controlador.text =
          '${elegida.day.toString().padLeft(2, '0')}/${elegida.month.toString().padLeft(2, '0')}/${elegida.year}';
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(widget.label, style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      TextFormField(
        controller: controlador,
        readOnly: widget.readOnly || fecha,
        obscureText: widget.secret,
        maxLines: widget.lines,
        style: Theme.of(context).textTheme.bodyLarge,
        onTap: fecha ? elegirFecha : null,
        keyboardType: widget.numeric
            ? TextInputType.number
            : widget.label.toLowerCase().contains('correo')
            ? TextInputType.emailAddress
            : widget.label.toLowerCase().contains('celular')
            ? TextInputType.phone
            : TextInputType.text,
        decoration: InputDecoration(
          hintText: widget.hint,
          errorText: widget.error,
          suffixIcon: fecha
              ? IconButton(
                  tooltip: 'Elegir fecha',
                  onPressed: elegirFecha,
                  icon: const Icon(Icons.calendar_month_outlined),
                )
              : widget.readOnly
              ? const Icon(Icons.lock_outline, size: 20)
              : null,
        ),
      ),
    ],
  );
}
