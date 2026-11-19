# Barber Shop

Aplicación Flutter de gestión de barbería conectada a la API del profesor.

## Ejecutar en VS Code

1. Abre la carpeta Barber Shop en VS Code.
2. Ejecuta `flutter pub get` y `flutter devices` en la terminal.
3. Selecciona el teléfono o emulador y presiona **F5**.
4. Inicia sesión con la cuenta asignada por el profesor. Después de un acceso correcto, el usuario y la contraseña se recuerdan mediante almacenamiento seguro para rellenar el siguiente inicio. La contraseña se mantiene oculta en el formulario.

La aplicación arranca en modo claro y permite cambiar de tema desde Más.

Para verificar el proyecto, ejecuta `flutter analyze` y `flutter test`.

## Arquitectura

| Carpeta | Responsabilidad |
| --- | --- |
| `lib/screens` y `lib/widgets` | Pantallas por módulo y componentes reutilizables. |
| `lib/models/api` | Modelos por módulo, con archivos separados `*_request.dart` y `*_response.dart` para cada operación. |
| `lib/services/remote` | Endpoints HTTP en servicios por módulo, cliente HTTP y sesión. |
| `lib/config/app_config.dart` | URL base configurable con `API_BASE_URL`. |
| `lib/repositories` | Adapta los datos de la API y actualiza las listas que muestran las pantallas. |
| `lib/services/local` | Datos complementarios que la API no recibe, como asistencia y medio de pago durante la sesión. |
| `test` y `referencias/revision_visual` | Pruebas y capturas de referencia que necesitan las pruebas visuales. |

Al confirmar una reserva, la pantalla entrega los datos al repositorio. Este arma el `CrearReservaRequest`, llama a `ReservasService` y actualiza la agenda con el resultado del servidor.

Las consultas de listado y detalle de Clientes y Reservas convierten el JSON en modelos con campos tipados. El repositorio adapta esos modelos para las pantallas. Los cuerpos se serializan con `toJson()`, siguiendo el ejemplo Fluxis del profesor y la organización de Lumiere.

## Próximos pasos

- Extender el tipado de respuestas a los demás módulos.
- Probar en el teléfono el flujo de inicio de sesión, creación de una cita y actualización de Inicio y Agenda.

## Conteo del panel y prueba de liquidación

Inicio cuenta las reservas desde hoy en adelante, incluidas las de otros meses, y ordena las próximas citas por fecha y hora. Los cierres usan los totales de la API y el detalle de comisión lee la lista comisionServicios. La prueba del 18 de noviembre creó las reservas 108, 109 y 110 y verificó la liquidación 16 y la comisión 6.
