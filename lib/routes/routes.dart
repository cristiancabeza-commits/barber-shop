import 'package:flutter/material.dart';

import '../widgets/inicio_prototipo.dart';
import '../screens/autenticacion/pantalla_inicio_sesion.dart';
import '../screens/autenticacion/pantalla_error_inicio_sesion.dart';
import '../screens/autenticacion/pantalla_restablecer_contrasena.dart';
import '../screens/inicio/pantalla_inicio_principal.dart';
import '../screens/especialidades/pantalla_especialidades.dart';
import '../screens/especialidades/pantalla_nueva_especialidad.dart';
import '../screens/servicios/pantalla_servicios.dart';
import '../screens/servicios/pantalla_nuevo_servicio.dart';
import '../screens/clientes/pantalla_clientes.dart';
import '../screens/clientes/pantalla_nuevo_cliente.dart';
import '../screens/profesionales/pantalla_profesionales.dart';
import '../screens/profesionales/pantalla_nuevo_profesional.dart';
import '../screens/agenda/pantalla_agenda.dart';
import '../screens/reservas/pantalla_nueva_reserva.dart';
import '../screens/reservas/pantalla_confirmar_reserva.dart';
import '../screens/reservas/pantalla_detalle_reserva.dart';
import '../screens/reservas/pantalla_reagendar_reserva.dart';
import '../screens/reservas/pantalla_cancelar_reserva.dart';
import '../screens/reservas/pantalla_reserva_creada.dart';
import '../screens/reservas/pantalla_reserva_cancelada.dart';
import '../screens/reservas/pantalla_reserva_atendida.dart';
import '../screens/horarios/pantalla_horarios.dart';
import '../screens/horarios/pantalla_agregar_horario.dart';
import '../screens/inasistencias/pantalla_inasistencias.dart';
import '../screens/cierres_caja/pantalla_cierres_caja.dart';
import '../screens/comisiones/pantalla_consulta_comisiones.dart';
import '../screens/clientes/pantalla_editar_cliente.dart';
import '../screens/servicios/pantalla_mis_servicios.dart';
import '../screens/cierres_caja/pantalla_nuevo_cierre.dart';
import '../screens/cierres_caja/pantalla_confirmar_cierre.dart';
import '../screens/cierres_caja/pantalla_detalle_cierre.dart';
import '../screens/comisiones/pantalla_detalle_comision.dart';
import '../screens/especialidades/pantalla_editar_especialidad.dart';
import '../screens/servicios/pantalla_editar_servicio.dart';
import '../screens/profesionales/pantalla_editar_profesional.dart';
import '../screens/horarios/pantalla_editar_horario.dart';
import '../screens/inasistencias/pantalla_inasistencia_rango.dart';
import '../screens/comunes/pantalla_sin_resultados.dart';
import '../screens/comunes/pantalla_errores_validacion.dart';
import '../screens/agenda/pantalla_agenda_calendario.dart';
import '../screens/servicios/pantalla_detalle_mi_servicio.dart';

abstract final class Rutas {
  static const inicio = '/inicio-principal';
  static final pantallas = <String, WidgetBuilder>{
    '/presentacion': (_) => const InicioPrototipo(),
    '/inicio-sesion': (_) => const PantallaInicioSesion(),
    '/error-inicio-sesion': (_) => const PantallaErrorInicioSesion(),
    '/restablecer-contrasena': (_) => const PantallaRestablecerContrasena(),
    '/inicio-principal': (_) => const PantallaInicioPrincipal(),
    '/especialidades': (_) => const PantallaEspecialidades(),
    '/nueva-especialidad': (_) => const PantallaNuevaEspecialidad(),
    '/servicios': (_) => const PantallaServicios(),
    '/nuevo-servicio': (_) => const PantallaNuevoServicio(),
    '/clientes': (_) => const PantallaClientes(),
    '/nuevo-cliente': (_) => const PantallaNuevoCliente(),
    '/profesionales': (_) => const PantallaProfesionales(),
    '/nuevo-profesional': (_) => const PantallaNuevoProfesional(),
    '/agenda': (_) => const PantallaAgenda(),
    '/nueva-reserva': (_) => const PantallaNuevaReserva(),
    '/confirmar-reserva': (_) => const PantallaConfirmarReserva(),
    '/detalle-reserva': (_) => const PantallaDetalleReserva(),
    '/reagendar-reserva': (_) => const PantallaReagendarReserva(),
    '/cancelar-reserva': (_) => const PantallaCancelarReserva(),
    '/reserva-creada': (_) => const PantallaReservaCreada(),
    '/reserva-cancelada': (_) => const PantallaReservaCancelada(),
    '/reserva-atendida': (_) => const PantallaReservaAtendida(),
    '/horarios': (_) => const PantallaHorarios(),
    '/agregar-horario': (_) => const PantallaAgregarHorario(),
    '/inasistencias': (_) => const PantallaInasistencias(),
    '/cierres-caja': (_) => const PantallaCierresCaja(),
    '/consulta-comisiones': (_) => const PantallaConsultaComisiones(),
    '/editar-cliente': (_) => const PantallaEditarCliente(),
    '/mis-servicios': (_) => const PantallaMisServicios(),
    '/nuevo-cierre': (_) => const PantallaNuevoCierre(),
    '/confirmar-cierre': (_) => const PantallaConfirmarCierre(),
    '/detalle-cierre': (_) => const PantallaDetalleCierre(),
    '/detalle-comision': (_) => const PantallaDetalleComision(),
    '/editar-especialidad': (_) => const PantallaEditarEspecialidad(),
    '/editar-servicio': (_) => const PantallaEditarServicio(),
    '/editar-profesional': (_) => const PantallaEditarProfesional(),
    '/editar-horario': (_) => const PantallaEditarHorario(),
    '/inasistencia-rango': (_) => const PantallaInasistenciaRango(),
    '/sin-resultados': (_) => const PantallaSinResultados(),
    '/errores-validacion': (_) => const PantallaErroresValidacion(),
    '/agenda-calendario': (_) => const PantallaAgendaCalendario(),
    '/detalle-mi-servicio': (_) => const PantallaDetalleMiServicio(),
  };
}
