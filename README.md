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
| `lib/repositories` | Repositorios separados por módulo: coordinan los servicios, adaptan los datos y actualizan las listas de las pantallas. |
| `lib/services/local` | Datos complementarios que la API no recibe, como asistencia y medio de pago durante la sesión. |
| `test` y `referencias/revision_visual` | Pruebas y capturas de referencia que necesitan las pruebas visuales. |

Al confirmar una reserva, la pantalla entrega los datos al repositorio. Este arma el `CrearReservaRequest`, llama a `ReservasService` y actualiza la agenda con el resultado del servidor.

Las consultas de listado y detalle de Clientes y Reservas convierten el JSON en modelos con campos tipados. El repositorio adapta esos modelos para las pantallas. Los cuerpos se serializan con `toJson()`, siguiendo el ejemplo Fluxis del profesor y la organización de Lumiere.

### Cómo entender los repositorios

El recorrido es: **pantalla → repositorio del módulo → servicio del módulo → API**.
La pantalla recoge y muestra información; el repositorio coordina los datos;
el servicio realiza la petición HTTP; los modelos representan los datos enviados y recibidos.

| Archivo dentro de `lib/repositories` | Qué debes explicar |
| --- | --- |
| `repositorio_clientes.dart` | Lista, consulta, crea, actualiza y elimina clientes. |
| `repositorio_especialidades.dart` | Maneja el catálogo de especialidades. |
| `repositorio_servicios.dart` | Maneja los servicios ofrecidos, sus precios y duración. |
| `repositorio_profesionales.dart` | Maneja profesionales y los consulta por servicio. |
| `repositorio_horarios.dart` | Maneja horarios individuales, por profesional y para varios días. |
| `repositorio_inasistencias.dart` | Maneja los períodos de ausencia de los profesionales. |
| `repositorio_reservas.dart` | Consulta, crea, modifica y cancela reservas; conserva los complementos locales de atención y pago. |
| `repositorio_agenda.dart` | Consulta agenda diaria y horas disponibles. |
| `repositorio_liquidaciones.dart` | Consulta cierres, obtiene el último y crea liquidaciones. |
| `repositorio_comisiones.dart` | Consulta comisiones y los servicios incluidos en cada comisión. |
| `repositorio_remoto.dart` | Crea y conecta los repositorios de los módulos. Conserva el acceso usado por las pantallas y retransmite los avisos de cambios. |
| `repositorio_catalogo.dart` | Define las operaciones comunes de los seis catálogos y conserva sus listas. `cargar()` consulta los datos y avisa que cambiaron. |
| `formato_repositorio.dart` | Funciones compartidas para adaptar fechas, horas, identificadores y registros de los formularios. No hace peticiones. |
| `repositorio_barberia.dart` | Contrato común que permite usar el repositorio remoto o el de memoria. |
| `repositorio_memoria.dart` | Datos temporales del prototipo y las pruebas. No llama a la API ni sustituye los servicios remotos tras iniciar sesión. |

Por ejemplo, al guardar un cliente:

1. El formulario llama a `guardar(Modulo.clientes, registro)` del coordinador.
2. El coordinador delega a `RepositorioClientes.guardar()`.
3. Ese módulo decide si crea o actualiza, construye el request y llama a `ClientesService`.
4. Después ejecuta `cargar()` para consultar la lista actualizada.
5. `notifyListeners()` avisa al coordinador y a las pantallas que escuchan sus cambios.

En reservas sucede lo mismo: `RepositorioReservas.guardarReserva()` llama a
`ReservasService` y recarga sus datos. Inicio y Agenda siguen leyendo la misma lista.
La atención y el medio de pago conservan el comportamiento local previo porque
no se añadieron operaciones a la API del profesor.

Para estudiarlo, comienza por `repositorio_especialidades.dart`, después revisa
`especialidades_service.dart` y sus modelos request/response. Luego sigue el flujo
de clientes y finalmente el de reservas. Los repositorios de los módulos son
clases independientes; el coordinador no contiene los cuerpos de las peticiones.

## Próximos pasos

- Extender el tipado de respuestas a los demás módulos.
- Probar en el teléfono el flujo de inicio de sesión, creación de una cita y actualización de Inicio y Agenda.

## Conteo del panel y prueba de liquidación

Inicio cuenta las reservas desde hoy en adelante, incluidas las de otros meses, y ordena las próximas citas por fecha y hora. Los cierres usan los totales de la API y el detalle de comisión lee la lista comisionServicios. La prueba del 18 de noviembre creó las reservas 108, 109 y 110 y verificó la liquidación 16 y la comisión 6.
