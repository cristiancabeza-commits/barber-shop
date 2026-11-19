import 'package:flutter/material.dart';

import '../controllers/estado_aplicacion.dart';
import '../services/remote/servicio_sesion.dart';
import '../services/local/credenciales_guardadas.dart';
import 'componentes.dart';
import 'campo_formulario.dart';

/// Formulario de inicio de sesión.
class AccesoLocal extends StatefulWidget {
  const AccesoLocal({
    super.key,
    this.errorInicial = false,
    this.recuperar = false,
  });
  final bool errorInicial, recuperar;
  @override
  State<AccesoLocal> createState() => _EstadoAcceso();
}

class _EstadoAcceso extends State<AccesoLocal> {
  final clave = GlobalKey<FormState>();
  final usuario = TextEditingController(),
      contrasena = TextEditingController(),
      codigo = TextEditingController();
  bool ocultar = true, enviado = false, ingresando = false;
  String? error;
  @override
  void initState() {
    super.initState();
    if (widget.errorInicial) error = 'Usuario o contraseña incorrectos';
    if (!widget.recuperar) _cargarCredenciales();
  }

  Future<void> _cargarCredenciales() async {
    final datos = await CredencialesGuardadas().leer();
    if (!mounted ||
        datos == null ||
        ingresando ||
        usuario.text.isNotEmpty ||
        contrasena.text.isNotEmpty)
      return;
    usuario.text = datos.usuario;
    contrasena.text = datos.clave;
  }

  @override
  void dispose() {
    usuario.dispose();
    contrasena.dispose();
    codigo.dispose();
    super.dispose();
  }

  Future<void> _ingresar() async {
    if (ingresando) return;
    if (!clave.currentState!.validate()) return;
    final usuarioIngresado = usuario.text.trim();
    final claveIngresada = contrasena.text;
    setState(() {
      ingresando = true;
      error = null;
    });
    try {
      final valido = await ServicioSesion.instancia.iniciar(
        usuarioIngresado,
        claveIngresada,
      );
      if (!mounted) return;
      if (valido) {
        await EstadoAplicacion.cargarSesion();
        final recordado = await CredencialesGuardadas().guardar(
          usuarioIngresado,
          claveIngresada,
        );
        if (!mounted) return;
        if (!recordado) {
          mostrarAviso(
            context,
            'No se pudo recordar el acceso en este dispositivo.',
          );
        }
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/inicio-principal', (_) => false);
      } else {
        setState(() => error = 'Usuario o contraseña incorrectos');
      }
    } on Exception {
      ServicioSesion.instancia.cerrar();
      if (mounted)
        setState(() => error = 'No se pudo iniciar sesión. Intenta de nuevo.');
    } on StateError {
      if (mounted)
        setState(() => error = 'No se pudo iniciar sesión. Intenta de nuevo.');
    } finally {
      if (mounted) setState(() => ingresando = false);
    }
  }

  @override
  Widget build(BuildContext context) => Form(
    key: clave,
    child: EstructuraPantalla(
      title: widget.recuperar ? 'Restablecer contraseña' : 'Iniciar sesión',
      bottom: false,
      back: widget.recuperar,
      children: [
        const Logotipo(size: 112),
        const TituloSeccion('Administración y control de barbería'),
        if (error != null)
          Text(
            error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        CampoFormulario(
          widget.recuperar ? 'Correo o usuario' : 'Usuario',
          usuario,
          validar: requerido,
        ),
        if (widget.recuperar) ...[
          FilledButton(
            onPressed: () {
              if (requerido(usuario.text) != null) {
                clave.currentState!.validate();
                return;
              }
              setState(() => enviado = true);
              mostrarAviso(
                context,
                'Solicitud simulada. Código de prueba: 123456.',
              );
            },
            child: const Text('ENVIAR CÓDIGO'),
          ),
          if (enviado) ...[
            const Text('Solicitud enviada en modo de prueba. Código: 123456'),
            CampoFormulario(
              'Código de verificación',
              codigo,
              tipo: 'numero',
              validar: (v) => v == '123456'
                  ? null
                  : 'Ingresa el código de prueba de seis dígitos',
            ),
            FilledButton(
              onPressed: () {
                if (clave.currentState!.validate()) {
                  mostrarAviso(
                    context,
                    'Verificación simulada. La recuperación real requiere la API.',
                  );
                  Navigator.pushReplacementNamed(context, '/inicio-sesion');
                }
              },
              child: const Text('VERIFICAR CÓDIGO'),
            ),
          ],
          const BotonVista(
            'Volver al inicio de sesión',
            route: '/inicio-sesion',
            secondary: true,
          ),
        ] else ...[
          TextFormField(
            controller: contrasena,
            validator: requerido,
            obscureText: ocultar,
            decoration: InputDecoration(
              labelText: 'Contraseña',
              suffixIcon: IconButton(
                tooltip: ocultar ? 'Mostrar contraseña' : 'Ocultar contraseña',
                onPressed: () => setState(() => ocultar = !ocultar),
                icon: Icon(
                  ocultar
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: TextButton(
              onPressed: () =>
                  Navigator.pushNamed(context, '/restablecer-contrasena'),
              child: const Text('¿Olvidaste tu contraseña?'),
            ),
          ),
          FilledButton(
            onPressed: ingresando ? null : _ingresar,
            child: Text(ingresando ? 'INGRESANDO…' : 'INGRESAR'),
          ),
        ],
      ],
    ),
  );
}
