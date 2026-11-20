# Barrber Shop API CECAR - Gestor

Colección de Bruno organizada por módulos, sin tests ni aserciones automáticas.
Contiene 52 peticiones que cubren las 45 operaciones del Swagger revisado el 19/11/2026.
Las peticiones adicionales son variantes de filtros y de creación de reserva con cliente nuevo o registrado.

## Abrir y utilizar

1. En Bruno selecciona Open Collection y abre esta carpeta, la que contiene bruno.json.
2. Selecciona el entorno Produccion en la esquina superior derecha.
3. En el entorno, agrega usuario y clave como variables secretas con tu cuenta de la API.
4. Ejecuta autenticacion → Iniciar sesion. Si responde correctamente, el script guarda token para las siguientes peticiones.
5. Abre el módulo que necesites y ejecuta su petición. Revisa el código HTTP y el cuerpo de Response.
6. Ajusta los identificadores y las fechas del entorno al registro y al horario que vayas a utilizar. Los IDs de las altas se guardan automáticamente para reutilizarlos.
7. Los DELETE están en su módulo. Al enviarlos se elimina o cancela el registro cuyo ID esté seleccionado.

## Organización

- autenticacion: iniciar sesión y obtener token.
- clientes: listar, buscar por documento, crear, actualizar y eliminar.
- especialidades: listar, consultar por ID, crear, actualizar y eliminar.
- servicios: listar, consultar por ID, crear, actualizar y eliminar.
- profesionales: listar, consultar por ID o por servicio, crear, actualizar y eliminar.
- horarios laborales: listar, consultar por ID o profesional, crear individualmente o en varios días, actualizar y eliminar.
- agenda: consultar por fecha y consultar disponibilidad por servicio o profesional.
- reservas: listar, filtrar, consultar por ID, crear con cliente existente o nuevo, reagendar y cancelar.
- inasistencias: listar, filtrar por profesional, consultar por ID, registrar períodos, actualizar y eliminar. La API llama eventualidades a este recurso.
- liquidaciones-comisiones: listar cierres, consultar el último y crear una liquidación.
- comisiones: listar, filtrar por liquidación o profesional y consultar los servicios de una comisión.

## Scripts y tests

No hay bloques tests, assert ni validaciones automáticas. Solo se conservan scripts breves para guardar el token y los identificadores de registros creados. La pestaña Tests pertenece a Bruno y puede seguir visible; en esta colección queda vacía.

## Práctica para la sustentación

Puedes practicar listar, buscar un detalle, crear y actualizar un cliente; crear una especialidad y un servicio; consultar profesionales y horarios; consultar disponibilidad; crear una reserva y luego reagendarla o cancelarla; registrar una inasistencia; consultar y crear liquidaciones; y filtrar comisiones y consultar su detalle.
Estas son prácticas manuales sobre las peticiones existentes, no endpoints adicionales ni tests. Crear, modificar, eliminar o liquidar cambia datos reales al presionar Send.
La reorganización y la revisión de cobertura no ejecutaron esas operaciones en el servidor. Cubrir las rutas no garantiza que todas respondan correctamente con cualquier dato.
