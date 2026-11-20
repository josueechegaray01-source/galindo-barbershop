# PROMPTS POR FASES — GALINDO BARBERSHOP
## Desarrollo integral del sistema multiplataforma | Versión objetivo 1.0.0

**Stack definido:** Flutter + Dart · Supabase Auth · PostgreSQL · RLS · Vercel (Flutter Web) · Android.

**Documento rector:** `Expediente_Tecnico_Galindo_Barbershop_v1.0.0.pdf`.

**Proyecto Supabase:** `https://fithxgprfwkfptgjhqcy.supabase.co`.

**Facebook de referencia:** https://www.facebook.com/ClaudioGalindoBarbershop1998/?locale=es_LA

---

# Instrucciones de uso

1. Abre OpenCode en la carpeta raíz del proyecto Flutter.
2. Coloca el expediente PDF dentro de `docs/Expediente_Tecnico_Galindo_Barbershop_v1.0.0.pdf` y el logotipo original que proporcionó el usuario en `assets/branding/galindo_logo_original.png`. Si tienes el DOCX del expediente, puedes guardarlo también en `docs/` como fuente complementaria.
3. Envía primero el **Prompt 0**. Revisa que OpenCode haya inspeccionado el proyecto, creado el plan y las reglas permanentes.
4. Ejecuta los prompts siguientes **uno por uno y en orden**. No envíes todas las fases en un solo mensaje. Cada fase debe terminar con implementación, pruebas y reporte de evidencia antes de comenzar la siguiente.
5. Cuando OpenCode necesite acceso a Supabase o Vercel, utiliza las conexiones/MCP que estén autenticadas en tu entorno. Nunca pegues una clave privada dentro de un prompt, código, archivo versionado o variable pública.

> El expediente define una propuesta técnica, no acredita que Supabase o Vercel ya estén configurados. Los datos operativos del negocio que figuran como pendientes deben quedar configurables y documentados; no inventes horarios, precios, barberos ni políticas.

---

# PROMPT 0 — Instrucciones maestras, auditoría del proyecto y plan de ejecución

```text
Actúa como un equipo senior de ingeniería de software compuesto por: arquitecto de soluciones, líder Flutter/Dart, especialista Supabase/PostgreSQL, especialista en seguridad, diseñador UX/UI, QA automation y DevOps. Tu responsabilidad es construir profesionalmente el sistema multiplataforma de GALINDO BARBERSHOP, siguiendo estrictamente el expediente técnico proporcionado.

OBJETIVO DEL PROYECTO
Construir la versión 1.0.0 de un sistema multiplataforma para optimizar la gestión de citas y la atención al cliente de Galindo Barbershop, Ica – Perú. Debe funcionar en Android y Web responsive, con una experiencia visual alineada a la marca real del establecimiento.

DOCUMENTOS Y ACTIVOS QUE DEBES LEER
- docs/Expediente_Tecnico_Galindo_Barbershop_v1.0.0.pdf (documento rector; inspecciona sus 46 páginas, tablas, diagramas, reglas, anexos y criterios de aceptación).
- assets/branding/galindo_logo_original.png (logotipo original; no lo redibujes ni deformes).
- Cualquier DOCX o material complementario que el usuario haya colocado en docs/.
Si el archivo no se encuentra, busca por nombre dentro del workspace y sus carpetas de documentación. No inventes contenido que no hayas podido leer: registra el faltante y continúa con lo que esté disponible.

DATOS TÉCNICOS INICIALES
- Supabase Project URL: https://fithxgprfwkfptgjhqcy.supabase.co
- La publishable key de Supabase todavía debe obtenerse del Dashboard/Connect. No inventarla.
- La service_role/secret key nunca debe llegar al cliente Flutter, al bundle web, al APK, al repositorio ni a documentación pública.
- Vercel se usará para publicar los archivos estáticos generados por Flutter Web.
- El token Vercel compartido anteriormente debe considerarse comprometido. No lo reutilices, no lo imprimas, no lo guardes ni intentes leerlo de conversaciones o archivos. Informa que debe revocarse y sustituirse por uno nuevo, almacenado únicamente en el gestor de secretos del CI/CD.
- Zona horaria funcional: America/Lima. Moneda de presentación: PEN (S/), pendiente de validación final con el negocio.
- Versión objetivo: 1.0.0.

ALCANCE FUNCIONAL OBLIGATORIO
1. Registro, inicio/cierre de sesión, recuperación de acceso y perfil.
2. Catálogo de servicios activos con nombre, descripción, precio y duración.
3. Directorio de barberos/profesionales y asociación de servicios que puede realizar cada uno.
4. Horarios generales, horarios por barbero, descansos, vacaciones y bloqueos.
5. Consulta de disponibilidad por servicio, profesional y fecha.
6. Creación de citas: servicio + barbero + fecha + hora; resumen con duración, precio, inicio, fin y estado.
7. Sección “Mis citas”: listado, detalle, estado y solicitud de cancelación/reprogramación según políticas que el negocio apruebe.
8. Agenda de barbero/personal para consultar las citas asignadas y actualizar estados permitidos.
9. Panel de administración: servicios, precios, duración, barberos, asignaciones, jornadas, bloqueos, agenda general, filtros e indicadores operativos básicos.
10. Historial auditable de los cambios relevantes de cada cita.

ROLES
- cliente: consulta catálogo y barberos, disponibilidad, crea citas propias y consulta/solicita cambios de sus propias citas.
- barbero/personal: consulta únicamente la agenda y datos necesarios para la operación que tenga asignada; actualiza estados autorizados.
- administrador: gestiona catálogo, profesionales, asignaciones, horarios, bloqueos, agenda y configuración operativa autorizada.
- Las opciones visibles en la interfaz NO sustituyen las autorizaciones del backend ni RLS.

REGLAS CRÍTICAS DE NEGOCIO
- Solo reservar servicios activos.
- El barbero debe estar activo y habilitado para el servicio seleccionado.
- El backend obtiene al cliente desde auth.uid(); nunca confíes en un customer_id enviado por el dispositivo.
- El fin de la cita se calcula desde la duración aprobada del servicio o una duración específica por barbero solo si se aprueba.
- La cita debe quedar dentro de la jornada general y de la jornada individual aplicable, fuera de descansos y bloqueos.
- No permitir dos citas activas superpuestas para un mismo barbero. Resolverlo en PostgreSQL mediante operación atómica y restricción de exclusión GiST cuando sea viable, no solo con una consulta previa desde Flutter.
- Los estados propuestos son pendiente, confirmada, atendida, cancelada y reprogramada. El expediente propone que pendiente y confirmada bloqueen el intervalo, pero el flujo de confirmación y las reglas de cancelación deben aprobarse con el negocio.
- Las canceladas liberan el intervalo. Conservar eventos de auditoría y snapshots históricos de precio/duración.
- No mostrar éxito si el backend no confirmó la escritura.
- Al fallar una reserva por concurrencia, informar con claridad y refrescar disponibilidad sin duplicar la solicitud.

ENTIDADES PROPUESTAS
profiles, customers, barbers, services, barber_services, business_hours, barber_hours, schedule_blocks, appointments y appointment_events. Mantén UUID, claves foráneas, índices, restricciones y tipos adecuados. Precio NUMERIC(10,2); fechas/horas TIMESTAMPTZ; mostrar en America/Lima. Guardar en appointments snapshots del precio y duración que tenía el servicio al reservar.

ARQUITECTURA Y HERRAMIENTAS
- Flutter y Dart; arquitectura feature-first por capas (presentation, domain, data).
- Considera Riverpod para estado/inyección y GoRouter para navegación; verifica primero compatibilidad y versiones estables actuales.
- supabase_flutter para Auth y Data API.
- PostgreSQL con migraciones SQL versionadas en supabase/migrations.
- RLS activada en todas las tablas expuestas del esquema public y políticas específicas por rol y propiedad.
- Vercel para hosting estático de Flutter Web. Android consume el mismo backend Supabase por HTTPS.
- Mantén pubspec.lock y fija dependencias estables compatibles. Revisa documentación oficial y changelogs antes de usar APIs o instalar paquetes.

FUERA DE ALCANCE DE 1.0.0
No implementar pagos, pasarela, POS, facturación electrónica, inventario, compras, proveedores, caja, contabilidad, planillas, puntos/membresías, marketing masivo, chat en tiempo real, bots, SMS, notificaciones push automáticas, sincronización offline ni iOS. No agregues módulos no aprobados aunque parezcan atractivos.

SEGURIDAD NO NEGOCIABLE
- Nunca usar user_metadata editable por el usuario para autorización. Los roles deben provenir de app_metadata o de una fuente protegida del servidor.
- El registro público siempre crea clientes; nunca permitir que alguien se autoasigne barbero o administrador.
- Bootstrap inicial de administrador por mecanismo seguro documentado, nunca con un botón público de “convertirme en admin”.
- RLS y GRANT revisados tabla por tabla; no crear políticas genéricas inseguras.
- Las políticas UPDATE deben validar USING y WITH CHECK. Evitar IDOR/BOLA.
- SECURITY INVOKER por defecto para funciones. Cualquier función SECURITY DEFINER exige revisión especial, search_path fijo, autorización interna y no estar expuesta sin control.
- No exponer service_role/secret keys. No registrar JWT, contraseñas, tokens ni datos personales innecesarios.
- No usar datos reales de clientes sin autorización expresa y revisión de privacidad aplicable en Perú.
- Nunca borrar tablas/datos existentes ni reemplazar configuraciones productivas sin inspección, respaldo y autorización explícita.

IDENTIDAD VISUAL / UX
- La marca utiliza un logotipo circular negro y blanco con el texto GALINDO BARBER y elementos clásicos de barbería. Usar el archivo original, mantener proporciones y zona de seguridad.
- Base cromática: carbón #171717, blanco #FFFFFF, gris claro #F4F4F4 y texto #202020. Colores de estado solo como apoyo, siempre con texto e icono.
- Las imágenes públicas consultables de la marca muestran mobiliario negro, espejos y paredes claras, capas de corte con el logotipo y estampados azul/morado. Las campañas estacionales pueden tener otras paletas; no conviertas una campaña navideña en el tema global.
- Interfaz profesional, contemporánea, masculina sin estereotipos, limpia y comercial. No recargar con barber poles, tijeras, rayas o texturas en cada sección.
- Tipografía legible; Roboto/Material es la base propuesta. Accesibilidad: contraste suficiente, escalado de texto, etiquetas, lectores y objetivos táctiles de al menos 48 dp.
- Web responsive: tablas/filtros en escritorio; tarjetas/acciones contextuales en móvil. Android debe sentirse nativo.
- Todo texto visible en español natural del Perú. Fechas en formato local y horas de Ica.

MÉTODO DE TRABAJO
1. Inspecciona primero el repositorio y el estado de Git. No sobrescribas trabajo existente.
2. Lee el expediente completo y crea matriz de trazabilidad RF/RNF/RN/CU/CP → módulos → archivos → pruebas.
3. Si existe MCP Supabase, descubre sus herramientas disponibles y verifica el proyecto objetivo por URL/ID antes de operar. Haz primero lectura/esquema/advisors. Si no está autenticado, genera migraciones y comandos reproducibles sin fingir conexión.
4. Verifica disponibilidad de Flutter/Dart, Android SDK, Git, Node/Vercel CLI si aplica y herramientas de pruebas.
5. Trabaja por fases, con commits lógicos si el repositorio está bajo Git.
6. No entregues solo prototipos visuales, mocks o botones decorativos: cada función del alcance debe conectarse a su lógica y persistencia reales, o quedar claramente marcada como pendiente por una dependencia externa.
7. Al final de cada fase ejecuta análisis, pruebas pertinentes y build posible; corrige errores antes de declarar terminada la fase.
8. Mantén `docs/PROGRESO.md`, `docs/DECISIONES_PENDIENTES.md`, `docs/ARQUITECTURA.md` y `docs/MATRIZ_TRAZABILIDAD.md` actualizados.
9. No inventes información de negocio. Para horarios, precios, profesionales, política de confirmación, anticipación y cancelaciones, crea configuración administrable y registra la decisión pendiente. Usa datos seed ficticios solo en desarrollo, rotulados DEMO y nunca como información real publicada.
10. Si una dependencia bloquea una fase, explica exactamente el bloqueo, implementa lo que no dependa de él y deja un procedimiento claro; no simules un resultado exitoso.

CRITERIO GLOBAL DE ENTREGA
La versión 1.0.0 debe incluir código Flutter mantenible, Supabase con migraciones y RLS verificadas, Android release y Flutter Web responsive, matriz de pruebas ejecutada, documentación técnica/operativa y evidencias. No declarar producción lista sin pruebas, secretos correctos, datos reales aprobados y aceptación del negocio.

Comienza ejecutando únicamente la FASE 0 de auditoría y planificación. No implementes todavía todos los módulos. Primero entrega diagnóstico verificable, estructura actual, dependencias, riesgos, preguntas/decisiones bloqueantes y plan por fases. Después espera el siguiente prompt de fase.
```

---

# PROMPT 1 — Auditoría, levantamiento definitivo y diseño UX/UI con referencia de marca

```text
Ejecuta la FASE 1 del proyecto GALINDO BARBERSHOP. Debes completar el análisis y el diseño UX/UI de manera profesional antes de implementar módulos de negocio.

1. Vuelve a leer el expediente técnico y utiliza su alcance, requisitos y decisiones pendientes como fuente de verdad. Revisa especialmente los capítulos 3–7, 11 y anexos A–E.
2. Inspecciona el repositorio actual, los assets y cualquier prototipo existente. No elimines ni reemplaces pantallas funcionales sin justificarlo.
3. INVESTIGACIÓN VISUAL DE MARCA:
   - Abre la página pública https://www.facebook.com/ClaudioGalindoBarbershop1998/?locale=es_LA mediante Playwright/computer-use si está disponible.
   - Recorre portada, publicaciones, fotos y videos públicos. Captura referencias visuales representativas (logo, local, sillones, estaciones, capas, trabajos de corte y piezas promocionales). No intentes evadir inicios de sesión, bloqueos o controles de acceso.
   - Compara con el logotipo original proporcionado en assets/branding/galindo_logo_original.png.
   - Separa identidad permanente de campañas/eventos. No uses una publicación de Navidad, promoción temporal o una foto de terceros como identidad global.
   - Si Facebook bloquea la vista automatizada, documenta la limitación y usa únicamente el logotipo y los contenidos públicos ya disponibles. No inventes elementos de la marca. Deja una lista de fotos adicionales que el propietario debería facilitar.
   - No descargues ni uses fotografías de terceros sin autorización. Para las fotos de clientes, confirma que el negocio tiene permiso para emplearlas en la aplicación.
4. DEFINE EL DESIGN SYSTEM:
   - Colores base: carbón #171717, blanco #FFFFFF, gris #F4F4F4 y texto #202020.
   - Colores semánticos accesibles para éxito, advertencia, error e información, usados de forma contenida y siempre acompañados de etiqueta/icono.
   - Tipografía, escala tipográfica, espaciado, radios, sombras, bordes, estados de botones, campos, tarjetas, badges, tablas, diálogos, snackbars y estados de carga/vacío/error.
   - Logo: proporción intacta, variantes necesarias (si el original permite transparencia), zona de seguridad, fondos permitidos y tamaño mínimo.
   - Crear `docs/BRAND_GUIDE.md` y tokens/tema Flutter correspondientes cuando la base visual esté definida.
5. DEFINE MAPA DE NAVEGACIÓN Y WIREFRAMES de todas las pantallas:
   A. Acceso: splash/bienvenida, login, registro, recuperación.
   B. Cliente: inicio, catálogo, detalle de servicio, lista/detalle de barberos, calendario, selector de horarios, resumen/confirmación, Mis citas, detalle, solicitud de cambio/cancelación y perfil.
   C. Personal: agenda diaria/semanal, detalle de cita y cambio de estado permitido.
   D. Administrador: dashboard, agenda global, filtros, servicios CRUD, barberos CRUD, asignaciones, horarios generales, horarios por barbero, descansos/bloqueos y gestión de usuarios operativos por procedimiento seguro.
6. DEFINE LOS FLUJOS CRÍTICOS:
   - Registro/login y redirecciones por sesión/rol.
   - Reserva con progreso claro y resumen de servicio, barbero, fecha, hora, duración, precio y estado.
   - Conflicto de horario durante el envío.
   - Solicitud de cancelación/reprogramación.
   - Operación del personal y administración.
7. CRITERIOS UX:
   - Pocas etapas por tarea, sin formularios excesivos.
   - Precio y duración visibles antes de seleccionar horario.
   - Fecha/hora America/Lima y formato local.
   - Confirmación antes de acciones que afecten una cita.
   - Diseñar correctamente Loading, Empty, Error, Offline/Connection lost, Success y Permission denied.
   - Accesibilidad: contraste, tamaño táctil mínimo recomendado 48 dp, foco visible en Web/teclado, labels semánticas y escalado de texto.
   - En móvil, tarjetas y navegación compacta; escritorio, agenda/tablas/filtros bien organizados.
8. No agregues funciones fuera del expediente. No inventes promociones, descuentos, precios, horarios ni slogans.
9. PRODUCE:
   - `docs/BRAND_GUIDE.md`
   - `docs/UX_SPECIFICATION.md`
   - `docs/SCREEN_MAP.md`
   - `docs/USER_FLOWS.md`
   - Prototipos/wireframes en el formato que permita el repositorio.
   - Matriz de pantallas y requisitos vinculados.
10. Antes de terminar, revisa coherencia visual en al menos tamaños móvil, tablet y escritorio; reporta lo no verificable.

No pases a backend ni construyas aún todos los módulos. Esta fase termina cuando el sistema visual, pantallas y flujos estén especificados y puedan utilizarse en la fase Flutter.
```

---

# PROMPT 2 — Diseño e implementación de Supabase, PostgreSQL, migraciones y RLS

```text
Ejecuta la FASE 2: backend de datos y seguridad de GALINDO BARBERSHOP. Debe quedar preparado para conectar Flutter de manera segura.

PROYECTO OBJETIVO
Supabase Project URL: https://fithxgprfwkfptgjhqcy.supabase.co
Project ref esperado: fithxgprfwkfptgjhqcy.
Comprueba el proyecto antes de cualquier operación. Si el MCP de Supabase está disponible, descubre las herramientas existentes y úsalo para inspección y verificación. No inventes que estás conectado si no lo estás.

ANTES DE CAMBIAR
1. Inspecciona el esquema, tablas, funciones, extensiones, políticas RLS, triggers, índices y migraciones existentes.
2. Comprueba que el proyecto seleccionado corresponde al ref indicado.
3. Identifica si es desarrollo, pruebas o producción. Si no se puede demostrar que es desarrollo, trata el entorno como sensible.
4. No elimines, trunques, renombres ni sobrescribas objetos o datos preexistentes sin autorización expresa. Prepara backup/rollback y explica cualquier operación de riesgo.
5. Genera primero migraciones SQL revisables en `supabase/migrations/`; no edites la base productiva de forma improvisada desde la consola.

MODELO BASE A IMPLEMENTAR (con revisión técnica)
- profiles: id ligado a auth.users.id, full_name, email, phone, role o referencia a rol protegido, created_at, updated_at.
- customers: profile_id único y datos adicionales estrictamente necesarios.
- barbers: profile_id opcional, display_name, active.
- services: name, description, price NUMERIC(10,2), duration_min, active.
- barber_services: barber_id, service_id, duration_override opcional, active.
- business_hours: weekday, start_time, end_time, is_open.
- barber_hours: barber_id, weekday, start_time, end_time, is_open.
- schedule_blocks: barber_id, starts_at, ends_at, reason, created_by.
- appointments: customer_id, barber_id, service_id, starts_at, ends_at, status, price_snapshot, duration_snapshot, note, created_at.
- appointment_events: appointment_id, old_status, new_status, actor_id, reason, created_at.
Puedes agregar campos técnicos indispensables (updated_at, índices, idempotency key, etc.) si documentas su razón y mantienes el modelo del expediente.

REGLAS SQL
- UUID como claves primarias.
- Claves foráneas e integridad referencial explícita.
- CHECK para precio >= 0, duración > 0 y ends_at > starts_at.
- ENUM o CHECK para estados aprobados.
- TIMESTAMPTZ para citas; presentación America/Lima.
- Snapshots de precio y duración al reservar.
- Desactivar servicios/barberos en vez de borrar registros históricos.
- Índices para filtros por cliente, barbero, starts_at, status y relaciones.
- Restricción de exclusión GiST por barbero e intervalo para impedir solapamientos en estados bloqueantes (validar btree_gist y estados, revisar la mejor forma de implementar una exclusion constraint parcial). Si el enfoque requiere ajustar el diseño, explica el SQL final.

OPERACIONES BACKEND
Crear y documentar operaciones seguras equivalentes a:
- get_available_slots(service_id, barber_id, date)
- book_appointment(service_id, barber_id, starts_at, note opcional)
- cancel_appointment(appointment_id, reason opcional)
- reschedule_appointment(appointment_id, new_starts_at)
- update_appointment_status(appointment_id, new_status)
- admin_dashboard_summary(date range, filters)
Las firmas pueden variar, pero no cambies las garantías de seguridad. `book_appointment` debe ejecutarse de forma atómica, derivar el cliente desde auth.uid(), recalcular duración y precio desde fuentes válidas, verificar servicio/barbero/asignación/jornadas/bloqueos/solapamientos e insertar cita + evento en una sola transacción. Usa una protección de idempotencia si el diseño la necesita para evitar duplicados por reintentos.

AUTENTICACIÓN Y ROLES
- Supabase Auth para registro, login, logout y recuperación.
- profiles.id = auth.users.id.
- Cliente nuevo por defecto; nadie puede asignarse barbero o admin desde el formulario ni desde user_metadata.
- Las decisiones de autorización deben usar app_metadata o fuente de servidor protegida, nunca raw_user_meta_data editable.
- Documenta el procedimiento seguro para asignar el primer administrador desde Dashboard/MCP/función administrativa. No crees una ruta pública de elevación de privilegios.

RLS Y PRIVILEGIOS
- RLS habilitada en todas las tablas expuestas en public.
- Policies de SELECT/INSERT/UPDATE/DELETE separadas por tabla y operación.
- Cliente: únicamente sus datos y sus citas; el ownership se deriva de auth.uid().
- Barbero/personal: datos mínimos y agenda asignada, con autorización comprobada en servidor/RLS.
- Administrador: operaciones globales requeridas, solo con rol confiable.
- Catálogo público: solo servicios y barberos activos cuando corresponda.
- En UPDATE incluye USING y WITH CHECK para impedir reasignación de propietario, roles o relaciones.
- No uses SECURITY DEFINER como atajo. Si una función lo requiere, justifica, fija search_path, valida auth.uid()/rol y restringe EXECUTE.
- GRANT explícitos solo de operaciones necesarias; comprueba exposición por Data API.

SEEDS Y CONFIGURACIÓN
- No inventes servicios, tarifas, barberos ni horarios reales.
- Crea seeds solo para entorno local/demo, claramente identificados como ficticios y nunca aplicados a producción sin confirmación.
- Mantén configuración de reserva y estados pendiente/confirmada parametrizable mientras el negocio decide cuál será el estado inicial, qué bloquea disponibilidad y la política de cancelación/reprogramación.

PRUEBAS DE BACKEND
- Registro e identidad cliente.
- Intento de autoasignación admin rechazado.
- Cliente A no consulta ni modifica citas de Cliente B.
- Barbero no ve citas de otro profesional.
- Admin puede operar según permisos.
- Servicio inactivo no reservable.
- Barbero no asignado al servicio no reservable.
- Fuera de jornada/bloqueo rechazado.
- Dos reservas concurrentes en la misma franja: una sola puede prosperar.
- Precio/duración snapshot no cambia cuando el catálogo se modifica después.
- Cancelación libera el intervalo y deja evento.
- Usuario no autorizado no modifica estados.

ENTREGABLES
- Migraciones SQL ordenadas y reversibles cuando sea posible.
- Políticas RLS y GRANT documentados.
- Funciones RPC y contratos de respuesta.
- `docs/DATABASE_SCHEMA.md`, `docs/RLS_MATRIX.md`, `docs/SUPABASE_SETUP.md`.
- Tests SQL/integration y evidencia de consultas/advisors.
- `.env.example` con nombres y placeholders, nunca valores secretos.

Aplica migraciones al proyecto Supabase únicamente después de verificar el entorno y confirmar que el cambio es no destructivo. Si la conexión/autorización no está disponible, deja listo el SQL y un paso a paso reproducible; no finjas que fue ejecutado.
```

---

# PROMPT 3 — Base Flutter, arquitectura, tema visual, navegación y autenticación

```text
Ejecuta la FASE 3: construir la base real de Flutter para Android y Web responsive, conectada a Supabase.

1. Inspecciona el proyecto Flutter existente. Conserva estructura y convenciones válidas; si no existe una app, créala correctamente. Verifica `flutter --version`, `dart --version`, SDK Android y dispositivos disponibles.
2. Consulta documentación oficial y changelogs actuales antes de seleccionar versiones de Flutter packages. Usa versiones estables compatibles, no prereleases, salvo justificación. Mantén pubspec.lock.
3. Implementa arquitectura feature-first con capas presentation/domain/data. Estructura orientativa:
   lib/main.dart
   lib/app/app.dart, router.dart, theme/
   lib/core/config/, errors/, network/, utils/, widgets/
   lib/features/auth/{data,domain,presentation}/
   lib/features/profile/{data,domain,presentation}/
   lib/features/catalog/{data,domain,presentation}/
   lib/features/barbers/{data,domain,presentation}/
   lib/features/availability/{data,domain,presentation}/
   lib/features/bookings/{data,domain,presentation}/
   lib/features/my_bookings/{data,domain,presentation}/
   lib/features/staff_agenda/{data,domain,presentation}/
   lib/features/admin/{data,domain,presentation}/
   Adapta nombres si el proyecto ya emplea una estructura limpia equivalente.
4. Configura Riverpod (si es compatible), GoRouter y supabase_flutter. Centraliza configuración, clientes, repositorios y manejo de excepciones. Evita llamadas directas a Supabase desde widgets.
5. Configura las variables públicas de compilación `SUPABASE_URL` y `SUPABASE_PUBLISHABLE_KEY`. La URL base es `https://fithxgprfwkfptgjhqcy.supabase.co`. La publishable key está pendiente; utiliza placeholder y muestra un error de configuración seguro si falta. No inventes una key. No incluir service_role/secret key.
6. Diseña `ThemeData` y componentes reutilizables según `docs/BRAND_GUIDE.md`: carbón #171717, blanco #FFFFFF, gris #F4F4F4, texto #202020, logo original intacto. Crea variantes light/dark solo si el manual de marca las contempla; el modo inicial debe mantener coherencia con el branding. No recrees el logo con texto.
7. Implementa rutas y guards:
   - usuario no autenticado → acceso/login;
   - cliente → área cliente;
   - barbero/personal → agenda operativa;
   - administrador → panel administrativo;
   - sesión expirada → reautenticación segura;
   - el guard del router mejora la UX, pero RLS sigue siendo el control de autorización real.
8. Implementa Auth: registro, login, logout, recuperación de contraseña y persistencia/restauración de sesión. Maneja correo no verificado si el método elegido lo requiere. El método final de verificación debe quedar documentado; no inventes credenciales de correo.
9. El registro público asigna rol cliente únicamente. El perfil no puede actualizar su propio rol. El onboarding de administrador/barbero se realiza por proceso protegido documentado.
10. Implementa pantallas de acceso pulidas, validaciones, estados loading/error/success y mensajes en español. No dejar botones sin acción.
11. Configura `intl` para `es_PE`, PEN y `America/Lima`. Al guardar fechas, usar timestamps/ISO con zona apropiada; no interpretar horas locales como UTC sin conversión.
12. Configura responsive breakpoints y navegación: móvil con navegación inferior/drawer según UX; escritorio con navegación lateral y área de contenido.
13. Crea tests de servicios de Auth, guards, formularios y estados de carga/error. No depender de una cuenta real para tests unitarios.

VERIFICACIÓN
- `flutter pub get`
- `dart format .`
- `flutter analyze` sin errores; resolver warnings relevantes.
- `flutter test`.
- `flutter build web --release` con valores de entorno de prueba si los secretos públicos no están disponibles.
- Android debug build si el SDK está instalado.

ENTREGABLES
Base Flutter funcional, Auth real conectado si hay credenciales válidas, tema y rutas por roles, instrucciones de configuración, `.env.example`/scripts de build seguros, tests y `docs/FLUTTER_ARCHITECTURE.md`.
No implementes aún el proceso completo de reservas; deja preparado el marco para las siguientes fases.
```

---

# PROMPT 4 — Módulos de cliente: catálogo, barberos, horarios y disponibilidad

```text
Ejecuta la FASE 4: desarrollar las funciones de consulta que preceden a una reserva.

OBJETIVO
Permitir que el cliente conozca los servicios reales publicados, encuentre profesionales habilitados y consulte disponibilidad sin visualizar información privada.

MÓDULO CATÁLOGO
- Listar únicamente servicios activos y publicados.
- Mostrar nombre, descripción, precio en S/ y duración estimada.
- Detalle de servicio con información legible y CTA “Reservar”.
- Búsqueda/filtro solo si aporta valor y está incluido en el diseño aprobado.
- Estados loading, error, vacío y retry.
- Nunca fijar precios de ejemplo como precios reales. Si no hay datos aprobados, mostrar mensaje controlado de catálogo aún no configurado o dataset DEMO claramente no productivo.

MÓDULO BARBEROS
- Listar profesionales activos y mostrar solo información aprobada para publicación.
- Indicar servicios que cada profesional puede realizar.
- Respetar barber_services.active.
- No mostrar perfiles privados ni datos personales del personal.
- No crear fotos o biografías ficticias como si fueran datos reales; usar avatar neutro cuando falten activos autorizados.

MÓDULO HORARIOS Y DISPONIBILIDAD
- Elegir fecha y profesional después de seleccionar un servicio.
- Consultar disponibilidad con backend usando servicio, barbero y fecha.
- Respetar business_hours, barber_hours, schedule_blocks y citas bloqueantes.
- Calcular duración final con servicio o override aprobado.
- Mostrar horas locales America/Lima.
- No usar un intervalo fijo como 15 minutos hasta que el parámetro sea aprobado. Déjalo configurable.
- Si no hay disponibilidad, presentar alternativas solo si las devuelve el backend o se calculan con las mismas reglas seguras.
- No mostrar disponibilidad como garantizada: revalidar siempre al reservar.

REGLAS DE EXPERIENCIA
- El usuario debe ver precio y duración antes de elegir hora.
- Paso a paso sencillo: servicio → barbero → fecha → hora → resumen.
- Resaltar la selección actual y permitir volver sin perder datos válidos.
- Controles táctiles de al menos 48 dp, accesibilidad y responsive.
- No mostrar CTA activo si falta una selección requerida.

BACKEND Y DATOS
- Usar repositorios y casos de uso establecidos.
- Implementar contratos tipados para catálogo, barberos y slots.
- No confiar en consultas hechas desde cliente para seguridad ni integridad.
- Aplicar manejo de errores: no autorizado, sin conexión, servicio inactivo, barbero no disponible, fecha inválida y conflicto.

PRUEBAS
- Solo servicios activos aparecen.
- Un barbero sin asignación activa no aparece para ese servicio.
- Horarios fuera de jornada y bloqueos no se muestran.
- Cita existente elimina la franja correspondiente.
- Fechas locales no cambian de día por conversiones UTC.
- Responsividad Android, Web móvil y escritorio.

ENTREGABLES
Módulos de catálogo, barberos y disponibilidad conectados al backend; pruebas automatizadas; capturas de pantallas de estados principales; actualización de `docs/PROGRESO.md` y matriz de trazabilidad.
```

---

# PROMPT 5 — Flujo crítico de reservas, “Mis citas”, cancelación y reprogramación

```text
Ejecuta la FASE 5: construir la parte más crítica del proyecto, el ciclo de vida completo de las citas.

FLUJO PRINCIPAL DE RESERVA
1. El cliente autenticado selecciona servicio.
2. Selecciona un barbero habilitado para ese servicio.
3. Selecciona fecha y consulta las franjas disponibles.
4. Elige una franja todavía elegible.
5. Revisa resumen con servicio, barbero, fecha, inicio, fin, duración, precio y regla/estado inicial vigente.
6. Confirma una sola vez. Deshabilita el botón durante el envío y utiliza idempotencia si corresponde.
7. El backend vuelve a validar la disponibilidad y calcula precio/duración desde fuentes autorizadas.
8. Si se guarda, muestra identificador y estado real devuelto por backend.
9. Si el intervalo fue ocupado por otra persona, no insertes la cita; informa conflicto, consulta de nuevo y deja que seleccione otro horario.
10. Si hay fallo de red o timeout sin respuesta concluyente, no muestres éxito ni envíes repetidamente. Permite verificar “Mis citas” antes de reintentar.

OPERACIÓN BACKEND OBLIGATORIA
- `book_appointment` (o contrato equivalente) atómica/transaccional en PostgreSQL.
- Cliente se obtiene desde auth.uid(); nunca se confía en customer_id enviado.
- Validar servicio activo, barbero activo, barber_services habilitado, horarios general/individual, bloqueos y solapamientos.
- Crear appointments y appointment_events dentro de la misma transacción.
- Guardar price_snapshot y duration_snapshot.
- Restricción de exclusión GiST o mecanismo equivalente robusto que impida dobles reservas concurrentes para el mismo barber_id.
- Responder con contrato estable, éxito/código error/mensaje sanitizado.

MIS CITAS
- Mostrar únicamente citas propias.
- Filtros por futuras/pasadas/estado si están en UX spec.
- Detalle completo con estado, servicio, barbero, fecha/hora, precio snapshot y duración.
- No presentar información de otros clientes.

CANCELACIÓN Y REPROGRAMACIÓN
- El expediente deja pendiente la política temporal y la aprobación del negocio. Implementa estas acciones de forma parametrizable.
- No inventes “cancelar hasta 2 horas antes” ni límites similares.
- Si el negocio aún no decide, permitir mostrar una solicitud pendiente de revisión por personal/admin o mantener la acción deshabilitada con explicación, según diseño aprobado.
- `cancel_appointment` comprueba propietario/rol, transición válida y reglas; marca cancelada, conserva el historial y libera el intervalo.
- `reschedule_appointment` revalida todo, reserva nuevo intervalo de forma atómica y registra el cambio; el intervalo previo se libera solo al completar la transacción.
- No borrar físicamente citas ni eventos históricos.

ESTADOS Y TRANSICIONES
Implementar pendiente, confirmada, atendida, cancelada y reprogramada según máquina de estados documentada. Verificar que:
- pendiente/confirmada bloqueen disponibilidad mientras esa regla esté aprobada;
- atendida no bloquee horarios futuros tras finalizar;
- cancelada libere intervalo;
- reprogramada deje trazabilidad del intervalo anterior y nuevo;
- solo roles autorizados realicen cada transición.
El estado inicial (pendiente o confirmada) se debe dejar como parámetro de configuración y reportar como decisión pendiente hasta que exista aprobación del negocio.

AUDITORÍA
Cada cambio relevante crea un registro en appointment_events con cita, estado anterior/nuevo, actor, fecha y motivo cuando exista. Los clientes no deben poder fabricar actor_id ni editar eventos.

PRUEBAS OBLIGATORIAS
- Reserva válida.
- Reserva en servicio inactivo rechazada.
- Barbero no habilitado rechazado.
- Fuera de jornada/bloqueo rechazada.
- Dos solicitudes concurrentes para mismo barbero/hora → una sola exitosa.
- Cliente A no ve ni modifica la cita de cliente B.
- Reintento de una misma operación no genera duplicado.
- Cancelar cita permitida libera la franja.
- Reprogramar no produce doble cita ni pérdida de historial.
- Timeout no provoca falso éxito.
- Expiración de sesión permite reautenticación sin duplicar.

UX
Usa confirmaciones claras, mensajes naturales en español y estados accesibles. Al finalizar una reserva exitosa, presenta pantalla de confirmación con un resumen que pueda compartirse por el mecanismo nativo solo si no expone datos privados.

ENTREGABLES
Flujo completo de reserva operativo; módulos Mis citas/detalle/cancelación/reprogramación; funciones RPC; tests de concurrencia, RLS y estados; capturas de evidencia; documentación de máquina de estados y contratos.
```

---

# PROMPT 6 — Panel de barberos/personal y panel administrativo

```text
Ejecuta la FASE 6: implementar el área operativa del personal y la administración de Galindo Barbershop.

ÁREA BARBERO / PERSONAL
- Agenda diaria y semanal con filtro por fecha y estados.
- Mostrar solo citas asignadas al profesional o información mínima que el rol tenga autorizada.
- Detalle de cita con cliente y datos de contacto estrictamente necesarios para prestar el servicio.
- Actualizar estado solo mediante transiciones permitidas y operación de backend `update_appointment_status`.
- Registrar evento de auditoría en cada transición.
- No permitir cambiar precios, crear roles o configurar usuarios salvo permiso explícito.
- Estados visibles con texto e iconos, nunca solo color.

PANEL ADMINISTRADOR
1. Dashboard operativo: conteo de citas por estado, citas del día, por profesional y filtros por periodo; sin indicadores financieros avanzados.
2. Agenda global con filtros por fecha, barbero y estado.
3. Servicios: alta, edición, activación/desactivación; nombre requerido, precio >= 0, duración > 0.
4. Barberos: registrar/editar/desactivar, perfil mínimo y servicios asociados.
5. Asignación barbero-servicio: activar/desactivar relación y duration_override opcional solo si el negocio lo aprueba.
6. Horarios generales: configuración semanal y días cerrados.
7. Horarios por barbero: jornadas individuales.
8. Bloqueos: descansos, vacaciones, pausas o cierres excepcionales, con rango de fecha/hora y motivo.
9. Gestión de estados: confirmar, atender, cancelar o reprogramar según permisos y política aprobada.
10. Usuarios operativos: no permitir administrar roles sensibles desde un CRUD público. Debe utilizarse un flujo protegido y auditable.
11. Historial de eventos visible solo a perfiles autorizados.

REGLAS DE DATOS
- Desactivar en vez de borrar servicios/profesionales que tengan historial de citas.
- Validar horas inicio/fin, rangos, días, solapamientos entre jornadas y bloqueos.
- Impedir borrar o desactivar una configuración que deje huérfanas citas históricas.
- Al cambiar precio/duración, preservar snapshots de citas anteriores.
- Validar en backend todas las acciones; la UI no es frontera de seguridad.
- Evitar mostrar a cualquier miembro de personal datos completos de clientes que no tenga asignados.

UX / RESPONSIVE
- Escritorio: navegación lateral, dashboard, tablas, filtros, calendario y formularios en panel/modal donde resulte adecuado.
- Tablet: layouts intermedios y agenda legible.
- Móvil: cards, navegación compacta y acciones contextuales; no tablas que requieran scroll horizontal excesivo.
- Agregar confirmaciones para desactivar profesionales/servicios, bloquear horarios y cambiar estados.
- Estados de carga, vacío, error, éxito y permisos.

PRUEBAS DE AUTORIZACIÓN
- Barbero solo puede ver agenda autorizada.
- Cliente no puede acceder al panel por URL directa.
- Barbero no puede acceder al CRUD de servicios.
- Cliente no puede modificar status, price_snapshot, duration_snapshot o barber_id de una cita.
- Personal sin permiso no puede consultar información global.
- Administrador autorizado realiza operaciones de configuración.
- RLS y backend rechazan las acciones aun si se manipula el cliente HTTP.

ENTREGABLES
Panel de personal y admin funcional, formularios CRUD, agenda, calendario/filtros, resumen operativo, matriz de permisos actualizada, tests por rol y manual de administración preliminar.
```

---

# PROMPT 7 — Integración integral, refinamiento visual, accesibilidad y contenido de marca

```text
Ejecuta la FASE 7: integra todos los módulos y realiza una pasada completa de calidad visual, responsive y experiencia de usuario.

1. Recorre el flujo completo como cliente, barbero/personal y administrador usando cuentas de prueba independientes.
2. Compara pantallas con `docs/BRAND_GUIDE.md`, `docs/UX_SPECIFICATION.md` y las referencias públicas que se hayan podido observar en Facebook.
3. Verifica que el logotipo original esté usado correctamente en splash, acceso, encabezado y áreas apropiadas; evita repetirlo en todos los componentes. No deformar, recolorear o recortar sin una versión oficial alternativa.
4. Mantén la estética base sobria negro/blanco/grises. Las fotografías auténticas del local/cortes solo se incorporan cuando estén dentro del repositorio y su uso haya sido autorizado. Si no existen imágenes autorizadas, diseña con bloques visuales, iconos y el logo; no agregues fotos genéricas que parezcan ser del negocio.
5. La comunicación escrita puede ser cercana y cálida, con español peruano natural, pero el sistema debe conservar tono profesional. Evita copiar literalmente publicaciones de Facebook o reproducir campañas temporales como contenido fijo.
6. Revisa toda la interfaz:
   - Jerarquía visual y consistencia de márgenes/espaciado.
   - Calidad de iconos, tipografía, contraste y tamaños.
   - Formularios, validaciones, feedback y navegación.
   - Estados de carga, vacío, error, sin conexión, sesión expirada y permisos insuficientes.
   - Confirmaciones de reserva/cancelación/reprogramación.
   - Fechas/moneda en formato local.
   - No hay desbordamientos, textos cortados, elementos superpuestos o botones decorativos sin acción.
7. Prueba al menos estos viewports Web: móvil pequeño (360 px), móvil común (390–430 px), tablet (768 px), portátil (1366 px) y escritorio ancho (1440 px). Ajusta los breakpoints según Flutter y documenta el resultado.
8. Android: probar tamaños de pantalla distintos, orientación soportada, teclado, safe areas y permisos mínimos.
9. Accesibilidad: contraste, semántica, focus traversal teclado, labels, escala de texto, targets táctiles ≥48 dp, feedback no solo por color.
10. Elimina datos placeholder del build de producción. Los datos DEMO deben quedar en ambiente demo, con indicador claro y sin mezclarse con producción.
11. Revisa que la navegación no revele pantallas protegidas al entrar por URL directa o botón atrás.
12. Corrige inconsistencias de idioma, nombres de botones, términos “cita/reserva”, fechas y nombres de roles.

ENTREGABLES
- UI refinada en Android y Web.
- `docs/UI_QA_REPORT.md` con screenshots, viewport, problemas detectados y correcciones.
- Lista de assets y procedencia/autorización.
- Actualización de Design System y matriz de pantallas si cambió algo.
- No añadir features fuera de alcance.
```

---

# PROMPT 8 — QA integral, seguridad, rendimiento y aceptación de versión 1.0.0

```text
Ejecuta la FASE 8: actúa como QA lead y auditor de seguridad independiente. No des por correcta una función solo porque el flujo feliz funciona.

A. CALIDAD DE CÓDIGO
- Ejecutar format, analyze/lint y pruebas unitarias.
- Revisar manejo de errores, nulos, estados asíncronos, fugas de memoria y consultas repetidas.
- Revisar arquitectura, dependencias, versiones y lockfile.
- Eliminar logs de desarrollo y datos sensibles.

B. PRUEBAS FUNCIONALES (matriz CP)
Ejecuta y registra como mínimo:
CP-01 Registro válido: cuenta Auth creada y perfil asociado, sin contraseña en tablas de negocio.
CP-02 Inicio/cierre de sesión: sesión válida y cierre efectivo.
CP-03 Catálogo: servicios activos visibles; inactivos no publicables.
CP-04 Asignación barbero-servicio: profesional no habilitado no se ofrece.
CP-05 Disponibilidad: jornadas, bloqueos y citas previas correctamente consideradas.
CP-06 Reserva válida: cita y evento consistentes.
CP-07 Doble reserva concurrente: una sola solicitud exitosa.
CP-08 Cita fuera de jornada: backend rechaza.
CP-09 Cita ajena: cliente no puede leer/editar una cita de otra cuenta.
CP-10 Cambio de estado: rol no autorizado rechazado.
CP-11 Cancelación: regla válida, intervalo liberado y evento guardado.
CP-12 Edición de precio: nuevas citas usan nuevo precio y antiguas conservan snapshot.
CP-13 Sesión expirada: reautenticación controlada, sin falso éxito.
CP-14 Sin conexión: mensaje claro y ninguna reserva duplicada al recuperar conexión.
CP-15 Rutas Web: deep links y refresh funcionan con auth y guards.
CP-16 Responsive: móvil, tablet y escritorio sin desbordamientos ni controles inaccesibles.

C. SEGURIDAD
- RLS activada en todas las tablas expuestas.
- Verificar GRANT + RLS por SELECT/INSERT/UPDATE/DELETE.
- Revisar que rol no provenga de user_metadata editable.
- Probar IDOR/BOLA por UUID de otra persona.
- Revisar que cliente no se eleve a admin/barbero.
- Probar que el personal solo vea citas asignadas y datos mínimos.
- Revisar funciones RPC, search_path, permisos EXECUTE, SECURITY DEFINER/INVOKER y auth.uid().
- Buscar secrets, service_role, tokens, JWT y credenciales en el repo, assets, APK, bundle Web, historial Git y logs. No imprimir el valor encontrado; reportar ruta y tipo y pedir rotación cuando corresponda.
- Verificar que Vercel token no aparece en código, .env versionado, logs o bundle.
- Revisar dependencias con herramientas disponibles y reportar vulnerabilidades.
- Revisar manejo de sesiones, errores, CORS/redirects si aplica y headers/caching para archivos estáticos.

D. RENDIMIENTO Y RESILIENCIA
- Verificar consultas e índices; evitar consultas N+1.
- Medir tiempos de pantallas principales bajo conexión estable; objetivo del expediente <3 s para consultas normales, sin afirmar cumplimiento sin medición.
- Evaluar P95 donde las herramientas lo permitan.
- Probar timeouts, pérdida de red y reintentos.
- No implementar modo offline: mostrar claramente dependencia de Internet.

E. PRIVACIDAD
- Usar solo datos ficticios en pruebas.
- No capturar PII en evidencias.
- Revisar consentimiento, aviso de privacidad, finalidad, minimización y conservación; marcar revisión legal pendiente si no existe.

F. CRITERIOS DE ACEPTACIÓN
- Deben aprobar obligatoriamente CP-01, CP-05, CP-06, CP-07, CP-09 y CP-10.
- No puede quedar ninguna vulnerabilidad crítica abierta ni secreto privado en cliente.
- Las reglas de reserva deben probarse del lado PostgreSQL y no solo en Flutter.
- Builds Android y Web deben compilar.
- Incidencias restantes deben tener severidad, responsable y resolución/aceptación documentada.

ENTREGABLES
- `docs/QA_TEST_PLAN.md`
- `docs/QA_TEST_RESULTS.md` con aprobado/rechazado/no ejecutado y evidencias.
- `docs/SECURITY_AUDIT.md`
- `docs/KNOWN_ISSUES.md`
- Reporte de cobertura y comandos ejecutados.
No marques una prueba como aprobada si no fue ejecutada. No inventes resultados ni porcentajes.
```

---

# PROMPT 9 — Publicación Flutter Web en Vercel y compilación Android

```text
Ejecuta la FASE 9: preparar y validar los artefactos Android y Web de GALINDO BARBERSHOP 1.0.0. Separa Preview/Staging de Producción.

PRECONDICIONES
- Ejecuta únicamente después de que QA haya aprobado funciones críticas.
- Verifica repo, rama, proyecto Vercel, equipo, dominio y ambiente. No supongas IDs ni dominio.
- Comprueba que Supabase URL y publishable key corresponden al ambiente correcto.
- La publishable key puede estar disponible al cliente, pero solo con RLS y políticas revisadas.
- Nunca introduzcas service_role/secret key en Flutter, JavaScript, APK, bundle web ni variables NEXT_PUBLIC.
- El token Vercel que se compartió anteriormente está comprometido: no lo reutilices. El usuario debe revocarlo y crear uno nuevo desde Vercel; OpenCode solo debe leer el nuevo valor desde un secreto seguro del entorno/CI, sin imprimirlo.
- No pedir ni almacenar keystore Android en el repositorio. No exponer contraseñas ni claves de firma.

FLUTTER WEB
1. Verifica la configuración target web.
2. Ejecuta `flutter build web --release` con SUPABASE_URL y SUPABASE_PUBLISHABLE_KEY inyectadas de manera segura en build. Mantén secretos privados fuera del bundle.
3. Comprueba que el output es `build/web`.
4. Crea/revisa `vercel.json` para rutas SPA: las rutas internas deben servir `index.html` sin interferir con archivos estáticos.
5. Configura proyecto Vercel desde el repo aprobado; no inventes team/project ID ni dominio.
6. Primero crea Preview. No publiques Producción sin autorización expresa del responsable del negocio.
7. Verifica login, logout, refresh de ruta profunda, catálogo, disponibilidad, reserva, Mis citas, panel y responsive.
8. Revisa logs de Vercel y consola del navegador, sin mostrar secretos.
9. Configura variables por ambiente (Development/Preview/Production) y redeploy cuando corresponda.
10. Documenta el dominio real solo cuando Vercel lo devuelva.

ANDROID
1. Confirma `applicationId`/package name, nombre de app y versión. Si falta package name definitivo, propón uno y documenta que el propietario debe aprobarlo antes de Play Store.
2. Comprueba INTERNET permission y permisos mínimos.
3. Configura icono de la app usando asset autorizado; no deformes logo circular. Ajusta adaptive icon si se requiere.
4. Configura splash, label Galindo Barbershop, versionName 1.0.0 y versionCode apropiado.
5. Genera primero APK debug/release de validación.
6. Para release, genera App Bundle (AAB) o APK según distribución; firma con keystore privado fuera del repo y secretos del entorno.
7. Prueba instalación/actualización en dispositivo físico, login, catálogo, reserva, Mis citas, personal/admin según rol y conectividad.
8. Registra versión, fecha, commit y SHA-256 de artefactos.

AUTOMATIZACIÓN
- Si se usa GitHub Actions, Vercel CLI u otra herramienta, implementar pipeline reproducible y mínimo.
- Secretos como `VERCEL_TOKEN`, keystore y contraseñas deben ir en el almacén de secretos correspondiente. No crear `.env.production` versionado.
- Añadir `.gitignore` para archivos de entorno, firma y artefactos privados.
- Mantener scripts con pasos claros y fallos detectables.

ENTREGABLES
- Preview Web verificado.
- Artefacto Android de prueba y, si la firma está disponible y autorizada, release AAB/APK.
- Configuración Vercel versionada sin secretos.
- `docs/DEPLOYMENT_WEB.md`, `docs/DEPLOYMENT_ANDROID.md`, `docs/RELEASE_NOTES_1.0.0.md`.
- Reporte de URL de Preview/dominio real y hashes de artefactos.
No afirmar que una publicación de producción fue realizada si solo existe Preview o un build local.
```

---

# PROMPT 10 — Documentación final, transferencia, manuales y cierre del proyecto

```text
Ejecuta la FASE 10: consolidar la documentación y preparar la entrega formal de GALINDO BARBERSHOP versión 1.0.0.

DOCUMENTOS A ENTREGAR EN `docs/`
1. `MANUAL_USUARIO_CLIENTE.md`: crear cuenta, acceder, consultar servicios, elegir barbero, consultar disponibilidad, reservar, ver Mis citas y solicitar cambios conforme a las reglas aprobadas.
2. `MANUAL_PERSONAL_BARBERO.md`: entrar, consultar agenda, abrir detalle y actualizar estados permitidos.
3. `MANUAL_ADMINISTRADOR.md`: catálogo, barberos, asignaciones, horarios, bloqueos, agenda, usuarios operativos y solución de incidencias.
4. `MANUAL_TECNICO.md`: arquitectura, estructura Flutter, dependencias, variables, configuración local, instalación y comandos.
5. `DATABASE_SCHEMA.md`: entidades, campos, relaciones, índices, constraints, snapshots y migraciones.
6. `RLS_MATRIX.md`: rol × recurso × operación con políticas aplicadas y tests de evidencia.
7. `DEPLOYMENT_WEB.md` y `DEPLOYMENT_ANDROID.md`: paso a paso reproducible, secretos requeridos, Preview/Production, firma y rollback.
8. `BACKUP_RECOVERY.md`: estrategia disponible según plan/configuración Supabase y prueba de restauración; no prometer un respaldo que no esté habilitado o probado.
9. `TROUBLESHOOTING.md`: errores comunes de login, disponibilidad, reserva, sesión, conectividad y despliegue.
10. `RELEASE_NOTES_1.0.0.md`: alcance entregado, fecha, commit, artefactos y limitaciones conocidas.
11. `ACTA_ENTREGA.md`: checklist de entregables y espacios para aprobación del representante de Galindo Barbershop y responsable técnico.
12. Actualiza `PROGRESO.md`, `DECISIONES_PENDIENTES.md`, `MATRIZ_TRAZABILIDAD.md` y `KNOWN_ISSUES.md`.

CONTENIDO OBLIGATORIO
- Identificar claramente lo implementado, lo probado, lo desplegado y lo que sigue pendiente.
- Registrar decisiones que el negocio debe confirmar: catálogo real, precios, duración, barberos activos, asignaciones, horarios, descansos, estado inicial de reserva, bloqueos de disponibilidad, política y anticipación de cancelación/reprogramación, datos que se solicitan, método de verificación y dominio final.
- Documentar que pagos, facturación, inventario, caja, contabilidad, offline, chat y notificaciones externas están fuera de 1.0.0.
- Documentar la configuración Supabase URL y los pasos para proporcionar la publishable key desde un canal seguro.
- Documentar la rotación del Vercel token comprometido y la creación de un secreto nuevo sin escribirlo en la documentación.
- Incluir comandos de instalación, análisis, pruebas, builds y despliegue que hayan sido ejecutados y verificados.
- No publicar correos, teléfonos privados ni datos reales de clientes sin aprobación.
- Añadir capturas limpias y sanitizadas de las pantallas principales, sin usuarios o datos reales.

AUDITORÍA DE CIERRE
1. Comprobar que todas las filas de la matriz de trazabilidad tienen módulo/código y prueba asociada.
2. Verificar que no hay TODO críticos, botones sin función, datos DEMO en producción ni rutas no protegidas.
3. Ejecutar última ronda: format, analyze, tests, build Web, build Android y comprobaciones de migración/RLS disponibles.
4. Verificar artefactos y documentar hashes.
5. Clasificar incidencias como críticas/altas/medias/bajas. La versión no puede declararse lista para producción con incidencias críticas o altas de seguridad/booking abiertas.
6. No afirmar aceptación comercial, piloto real o mejora de productividad sin acta y evidencia del negocio.

RESULTADO FINAL
Entrega un reporte breve pero completo con:
- arquitectura final;
- módulos implementados;
- tablas/RPC/migraciones ejecutadas;
- roles/RLS comprobados;
- pruebas aprobadas, rechazadas y no ejecutadas;
- build Android y ubicación del artefacto;
- URL real de Preview/Producción, distinguiendo ambas;
- documentación entregada;
- decisiones y credenciales que todavía requieren intervención del usuario;
- limitaciones conocidas.

Cierra solo cuando cada resultado esté respaldado por archivo, test, consulta o evidencia verificable. Si una tarea no se pudo ejecutar por falta de acceso, indícala como PENDIENTE, no como completada.
```

---

# PROMPT EXTRA — Revisión independiente antes de declarar terminado

```text
Realiza una revisión independiente del proyecto GALINDO BARBERSHOP 1.0.0 como si fueras un auditor externo que no participó en su desarrollo.

No te limites a leer el README. Recorre el código, migraciones, políticas RLS, funciones RPC, variables, router, widgets, pruebas, builds y documentos. Contrasta cada requisito del expediente con evidencia real.

Busca especialmente:
- doble reserva concurrente;
- lectura o modificación de citas ajenas;
- elevación de privilegios a administrador;
- personal que visualiza más datos de los necesarios;
- funciones RPC invocables por anon sin control;
- políticas RLS ausentes, demasiado amplias o con UPDATE sin WITH CHECK;
- service_role o token Vercel dentro del cliente, bundle, APK, repositorio o logs;
- precio/duración de una reserva que cambian retroactivamente;
- conversión incorrecta de America/Lima;
- errores de zona horaria, estados inconsistentes o cancelación que no libera disponibilidad;
- rutas Web con refresh 404 o vistas privadas sin guard;
- botones que no realizan su acción;
- datos demo en producción;
- UI que no respeta el logo, paleta y referencias del negocio;
- builds que no se pueden reproducir desde documentación limpia.

Ejecuta las pruebas necesarias. Para cada hallazgo informa severidad, archivo/objeto afectado, escenario de explotación o fallo, evidencia y corrección propuesta/aplicada. Corrige los defectos que puedas sin introducir cambios destructivos. Vuelve a ejecutar pruebas después de corregir.

Entrega `docs/FINAL_INDEPENDENT_REVIEW.md` y concluye con una de estas categorías, basada en evidencia: APTO PARA PREVIEW, APTO CON RESTRICCIONES PARA PRODUCCIÓN, NO APTO PARA PRODUCCIÓN. Nunca uses “100% seguro” ni declares producción lista si faltan autorizaciones o datos de negocio.
```

---

## Decisiones de negocio que deben permanecer visibles hasta confirmación

- Catálogo real, nombres de servicios, descripciones, precios y duración.
- Barberos/profesionales activos y servicios que realiza cada uno.
- Horario general, horarios individuales, descansos y días no laborables.
- Si cada reserva nace `pendiente` o se confirma automáticamente.
- Si las citas pendientes bloquean disponibilidad.
- Política, anticipación mínima y límites de cancelación/reprogramación.
- Datos personales mínimos solicitados y canal de contacto.
- Permisos concretos del rol barbero/personal.
- Dominio web, proyecto/equipo Vercel y repositorio/branch definitivo.
- Método de autenticación/verificación de correo.
- Autorización para piloto y uso de datos reales/fotografías de clientes.

## Referencias de marca y operación consultadas

- Página de Facebook indicada por el propietario: https://www.facebook.com/ClaudioGalindoBarbershop1998/?locale=es_LA
- Ficha pública que replica publicaciones e imágenes de Barbershop Galindo: https://www.beautynailhairsalons.com/PE/Ica/151495269026837/Barbershop-Galindo
- Los datos publicados en directorios (dirección, teléfono y horario) deben confirmarse directamente con el negocio antes de mostrarse como información oficial dentro de la aplicación.

