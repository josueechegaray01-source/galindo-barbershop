# Matriz de Trazabilidad - Galindo Barbershop v1.0.0

> **Versión:** 0.1 (Fase 0)
> **Fuente:** Expediente Técnico Cap. 5, Anexos B, C, F, I
> **Estado:** Inicial - Se completará en cada fase

---

## Leyenda

| Código | Significado |
|--------|-------------|
| **RF** | Requerimiento Funcional (Anexo B) |
| **RNF** | Requerimiento No Funcional (Anexo C) |
| **RN** | Regla de Negocio (Cap. 5.3.4, 5.3.5) |
| **CU** | Caso de Uso (Anexo F) |
| **CP** | Caso de Prueba (Anexo I) |
| **MOD** | Módulo Flutter / Componente |
| **ARCH** | Archivo/Tabla/Función clave |
| **FASE** | Fase de implementación |

---

## Matriz Principal: Requerimientos → Módulos → Archivos → Pruebas

### AUTENTICACIÓN Y PERFILES

| ID | Descripción | Tipo | Módulo Flutter | Archivos Clave | Pruebas (CP) | Fase |
|----|-------------|------|----------------|----------------|--------------|------|
| RF-01 | Registro de cliente con email/password | RF | `auth` | `auth_repository.dart`, `sign_up_usecase.dart`, `register_page.dart` | CP-01 | 3 |
| RF-02 | Inicio de sesión | RF | `auth` | `sign_in_usecase.dart`, `login_page.dart` | CP-02 | 3 |
| RF-03 | Cierre de sesión | RF | `auth` | `sign_out_usecase.dart`, `auth_controller.dart` | CP-02 | 3 |
| RF-04 | Recuperación de contraseña | RF | `auth` | `reset_password_usecase.dart`, `forgot_password_page.dart` | CP-02 | 3 |
| RF-05 | Persistencia/restauración de sesión | RF | `auth` | `auth_state_provider.dart`, `main.dart` | CP-02, CP-13 | 3 |
| RN-01 | Registro público → rol cliente únicamente | RN | `auth` + `profiles` trigger | `profiles` table, `handle_new_user()` function | CP-01, Security Audit | 2,3 |
| RN-02 | No auto-asignación admin/barbero desde cliente | RN | `auth` + RLS | `profiles` RLS policies | Security Audit | 2 |
| RNF-01 | Contraseñas no en texto plano | RNF | Supabase Auth | GoTrue (bcrypt) | Security Audit | 2 |
| RNF-02 | Sesión expira y requiere reautenticación | RNF | `auth` | `auth_controller.dart`, router guards | CP-13 | 3 |

### CATÁLOGO DE SERVICIOS

| ID | Descripción | Tipo | Módulo Flutter | Archivos Clave | Pruebas | Fase |
|----|-------------|------|----------------|----------------|---------|------|
| RF-06 | Listar servicios activos | RF | `catalog` | `services_repository.dart`, `get_services_usecase.dart`, `services_page.dart` | CP-03 | 4 |
| RF-07 | Detalle de servicio (nombre, desc, precio, duración) | RF | `catalog` | `service_detail_page.dart`, `ServiceCard` widget | CP-03 | 4 |
| RF-08 | Solo servicios activos y publicados | RN | `catalog` + `services` table | `services` RLS policy `active = true` | CP-03 | 2,4 |
| RN-03 | Precio ≥ 0, Duración > 0 | RN | `services` table | `CHECK (price >= 0)`, `CHECK (duration_min > 0)` | CP-12 | 2 |
| RNF-03 | Moneda PEN, formato local | RNF | `catalog` + `core/utils/formatters.dart` | `formatCurrency()`, `intl` es_PE | CP-03 | 3,4 |

### BARBEROS / PROFESIONALES

| ID | Descripción | Tipo | Módulo Flutter | Archivos Clave | Pruebas | Fase |
|----|-------------|------|----------------|----------------|---------|------|
| RF-09 | Listar barberos activos | RF | `barbers` | `barbers_repository.dart`, `barbers_page.dart` | CP-04 | 4 |
| RF-10 | Mostrar servicios por barbero | RF | `barbers` + `catalog` | `barber_detail_page.dart`, `barber_services` join | CP-04 | 4 |
| RN-04 | Barberos inactivos no visibles | RN | `barbers` table | `barbers.active = true` + RLS | CP-04 | 2,4 |
| RN-05 | Solo barberos con `barber_services.active = true` para servicio | RN | `availability` | `barber_services` join en RPC | CP-04 | 2,4 |

### HORARIOS Y DISPONIBILIDAD

| ID | Descripción | Tipo | Módulo Flutter | Archivos Clave | Pruebas | Fase |
|----|-------------|------|----------------|----------------|---------|------|
| RF-11 | Consultar disponibilidad por servicio, barbero, fecha | RF | `availability` | `availability_repository.dart`, `get_slots_usecase.dart`, `slots_page.dart` | CP-05 | 4 |
| RF-12 | Calcular franjas respetando duración servicio/override | RN | `availability` + RPC | `get_available_slots()` function | CP-05 | 2,4 |
| RN-06 | Respetar `business_hours` (horario general) | RN | RPC | `business_hours` table + function logic | CP-05 | 2 |
| RN-07 | Respetar `barber_hours` (horario individual) | RN | RPC | `barber_hours` table + function logic | CP-05 | 2 |
| RN-08 | Respetar `schedule_blocks` (descansos, vacaciones) | RN | RPC | `schedule_blocks` table + function logic | CP-05 | 2 |
| RN-09 | Respetar citas existentes en estados bloqueantes | RN | RPC + Exclusion Constraint | `appointments` + `no_overlapping_appointments` | CP-05, CP-07 | 2 |
| RN-10 | Fin de cita = inicio + duración (servicio u override) | RN | RPC | `book_appointment()` calcula `ends_at` | CP-06 | 2 |
| RN-11 | Zona horaria America/Lima en presentación | RN | `core/utils/date_time.dart` | `DateTimeFormatter` con `timeZone: 'America/Lima'` | CP-05 | 3,4 |
| RNF-04 | Disponibilidad no garantizada (revalidar al reservar) | RNF | `bookings` | `book_appointment()` revalida atómicamente | CP-06, CP-07 | 5 |

### RESERVA DE CITAS (FLUJO CRÍTICO)

| ID | Descripción | Tipo | Módulo Flutter | Archivos Clave | Pruebas | Fase |
|----|-------------|------|----------------|----------------|---------|------|
| RF-13 | Crear cita: servicio + barbero + fecha + hora | RF | `bookings` | `book_appointment_usecase.dart`, `booking_summary_page.dart`, `confirm_booking_page.dart` | CP-06 | 5 |
| RF-14 | Resumen con duración, precio, inicio, fin, estado | RF | `bookings` | `BookingSummary` widget, `booking_summary_page.dart` | CP-06 | 5 |
| RN-12 | Cliente = `auth.uid()` (nunca del cliente) | RN | RPC `book_appointment` | `auth.uid()` en función | CP-06, CP-09 | 2,5 |
| RN-13 | Validar: servicio activo, barbero activo, asignación, jornada, bloqueos, solapamientos | RN | RPC `book_appointment` | Lógica completa en función | CP-06, CP-07, CP-08 | 2 |
| RN-14 | Transacción atómica: cita + evento | RN | RPC `book_appointment` | `BEGIN; INSERT appointments; INSERT appointment_events; COMMIT;` | CP-06 | 2 |
| RN-15 | Snapshots: `price_snapshot`, `duration_snapshot_min` | RN | `appointments` table | Columns + RPC setea valores | CP-12 | 2 |
| RN-16 | Exclusión GiST impide doble reserva concurrente | RN | `appointments` constraint | `no_overlapping_appointments` | CP-07 | 2 |
| RN-17 | Estados iniciales: `pending` o `confirmed` (configurable) | RN | `appointments` + config | `status` default + config param | CP-06 | 2,5 |
| RN-18 | `pending`/`confirmed` bloquean; `cancelled` libera | RN | Exclusion constraint `WHERE` | `WHERE status IN ('pending','confirmed')` | CP-05, CP-11 | 2 |
| RNF-05 | No éxito si backend no confirmó escritura | RNF | `bookings` presentation | `booking_controller.dart` maneja estados | CP-06 | 5 |
| RNF-06 | Conflicto concurrencia → info clara + refresh disponibilidad | RNF | `bookings` | `BookingConflictException` + UI | CP-07 | 5 |
| RNF-07 | Timeout/red → no éxito falso + ver "Mis citas" antes reintentar | RNF | `bookings` | Error handling + idempotency key | CP-14 | 5 |

### MIS CITAS (CLIENTE)

| ID | Descripción | Tipo | Módulo Flutter | Archivos Clave | Pruebas | Fase |
|----|-------------|------|----------------|----------------|---------|------|
| RF-15 | Listar citas propias (futuras/pasadas/estado) | RF | `my_bookings` | `my_bookings_repository.dart`, `my_bookings_page.dart` | CP-09 | 5 |
| RF-16 | Detalle cita: estado, servicio, barbero, fecha/hora, precio, duración | RF | `my_bookings` | `booking_detail_page.dart` | CP-09 | 5 |
| RF-17 | Solicitar cancelación (según política) | RF | `my_bookings` | `cancel_booking_usecase.dart`, `cancel_dialog.dart` | CP-11 | 5 |
| RF-18 | Solicitar reprogramación (según política) | RF | `my_bookings` | `reschedule_booking_usecase.dart`, `reschedule_page.dart` | CP-11 | 5 |
| RN-19 | Cliente solo ve/sus citas (ownership = auth.uid()) | RN | `appointments` RLS | Policy `customer_id = auth.uid()` | CP-09, Security | 2,5 |
| RN-20 | Cancelación: valida transición + reglas + libera intervalo + evento | RN | RPC `cancel_appointment` | Function logic | CP-11 | 2,5 |
| RN-21 | Reprogramación: atómica (nuevo + libera anterior) + eventos | RN | RPC `reschedule_appointment` | Function logic | CP-11 | 2,5 |
| RN-22 | No borrado físico (soft delete via status) | RN | `appointments` | No `DELETE` en RPCs cliente | CP-11 | 2 |

### AGENDA BARBERO / PERSONAL

| ID | Descripción | Tipo | Módulo Flutter | Archivos Clave | Pruebas | Fase |
|----|-------------|------|----------------|----------------|---------|------|
| RF-19 | Agenda diaria/semanal con filtros | RF | `staff_agenda` | `agenda_page.dart`, `agenda_controller.dart` | CP-10 | 6 |
| RF-20 | Detalle cita con datos mínimos cliente | RF | `staff_agenda` | `appointment_detail_staff.dart` | CP-10 | 6 |
| RF-21 | Actualizar estado (transiciones permitidas) | RF | `staff_agenda` | `update_status_usecase.dart`, `status_actions.dart` | CP-10 | 6 |
| RN-23 | Barbero solo ve citas asignadas (`barber_id = auth.uid()` via profile) | RN | `appointments` RLS | Policy join `barbers.profile_id = auth.uid()` | CP-10, Security | 2,6 |
| RN-24 | Solo transiciones autorizadas por rol | RN | RPC `update_appointment_status` | Function valida `new_status` vs `old_status` + rol | CP-10 | 2,6 |
| RN-25 | Evento auditoría en cada transición | RN | RPC + trigger | `appointment_events` insert | CP-10 | 2 |

### PANEL ADMINISTRADOR

| ID | Descripción | Tipo | Módulo Flutter | Archivos Clave | Pruebas | Fase |
|----|-------------|------|----------------|----------------|---------|------|
| RF-22 | Dashboard: conteos por estado, día, barbero | RF | `admin` | `dashboard_page.dart`, `admin_dashboard_usecase.dart` | - | 6 |
| RF-23 | Agenda global con filtros | RF | `admin` | `global_agenda_page.dart` | - | 6 |
| RF-24 | CRUD Servicios (nombre, precio, duración, activo) | RF | `admin` | `services_admin_page.dart`, `service_form.dart` | - | 6 |
| RF-25 | CRUD Barberos (perfil, servicios, activo) | RF | `admin` | `barbers_admin_page.dart`, `barber_form.dart` | - | 6 |
| RF-26 | Asignación barbero-servicio + override duración | RF | `admin` | `barber_services_admin.dart` | - | 6 |
| RF-27 | Horarios generales (semanal, días cerrados) | RF | `admin` | `business_hours_admin.dart` | - | 6 |
| RF-28 | Horarios por barbero | RF | `admin` | `barber_hours_admin.dart` | - | 6 |
| RF-29 | Bloqueos (descansos, vacaciones, motivo) | RF | `admin` | `schedule_blocks_admin.dart` | - | 6 |
| RF-30 | Gestión estados cita (confirmar, atender, cancelar, reprogramar) | RF | `admin` | `admin_appointment_actions.dart` | - | 6 |
| RF-31 | Usuarios operativos (flujo protegido, no CRUD público) | RF | `admin` | `user_management_admin.dart` + secure function | - | 6 |
| RF-32 | Historial eventos visible solo autorizados | RF | `admin` | `audit_log_page.dart` | - | 6 |
| RN-26 | Desactivar (no borrar) servicios/barberos con historial | RN | `services`/`barbers` | `active` boolean + FK `ON DELETE RESTRICT` | - | 2,6 |
| RN-27 | Validar horas inicio/fin, rangos, solapamientos jornadas/bloqueos | RN | RPCs admin | Functions validan antes de insert/update | - | 2,6 |
| RN-28 | Impedir borrar/desactivar config que deje citas huérfanas | RN | FK + RPC checks | `ON DELETE RESTRICT` + pre-checks | - | 2 |
| RN-29 | Cambio precio/duración → preserva snapshots | RN | `appointments` | Snapshots inmutables | CP-12 | 2 |
| RNF-08 | Backend valida todo; UI no es frontera seguridad | RNF | All RPCs + RLS | Defense in depth | Security Audit | 2,6,8 |

### TRANSVERSAL: UI/UX, ACCESIBILIDAD, RESPONSIVE

| ID | Descripción | Tipo | Módulo | Archivos Clave | Pruebas | Fase |
|----|-------------|------|--------|----------------|---------|------|
| RNF-09 | Paleta: carbón #171717, blanco #FFFFFF, gris #F4F4F4, texto #202020 | RNF | `theme` | `colors.dart`, `theme.dart` | UI QA | 1,3,7 |
| RNF-10 | Logo original intacto, proporciones, zona seguridad | RNF | `theme` + `assets` | `BrandGuide`, `LogoWidget` | UI QA | 1,3,7 |
| RNF-11 | Tipografía legible, Roboto/Material base | RNF | `theme` | `typography.dart` | UI QA | 1,3,7 |
| RNF-12 | Contraste suficiente (WCAG AA) | RNF | `theme` | Color tokens validados | Accessibility Audit | 7 |
| RNF-13 | Targets táctiles ≥ 48 dp | RNF | `core/widgets` | `Button`, `TouchTarget` wrapper | UI QA | 3,7 |
| RNF-14 | Escalado de texto, labels semánticas, lectores | RNF | `core/widgets` | `Semantics`, `MediaQuery.textScaler` | Accessibility Audit | 7 |
| RNF-15 | Focus visible teclado (Web) | RNF | `core/widgets` | `FocusTraversalGroup`, `FocusableActionDetector` | UI QA | 7 |
| RNF-16 | Responsive: móvil (cards), tablet, escritorio (tablas) | RNF | `core/responsive` | `ResponsiveBuilder`, breakpoints | CP-16 | 3,7 |
| RNF-17 | Español natural Perú, fechas/horas locale | RNF | `l10n` + `intl` | `es_PE.arb`, `DateFormat` | CP-03, CP-05, CP-06 | 3,4,5 |
| RNF-18 | Estados: Loading, Empty, Error, Offline, Success, Permission | RNF | `core/widgets` | `StateLayout`, `ErrorView`, `OfflineBanner` | CP-14, UI QA | 3,4,5,7 |

### TRANSVERSAL: SEGURIDAD Y RENDIMIENTO

| ID | Descripción | Tipo | Componente | Validación | Fase |
|----|-------------|------|------------|------------|------|
| RNF-19 | RLS en todas tablas `public.*` | RNF | PostgreSQL | `\d+` + policy check | 2,8 |
| RNF-20 | GRANT explícitos mínimos | RNF | PostgreSQL | `\dp` audit | 2,8 |
| RNF-21 | No secrets en cliente/repo/build | RNF | CI/CD + code | `truffleHog`, `git-secrets`, manual | 3,8,9 |
| RNF-22 | No service_role en Flutter/Web/APK | RNF | Build config | Verificar bundle | 3,9 |
| RNF-23 | Vercel token rotado, en secrets CI | RNF | GitHub Actions | Secrets audit | 9 |
| RNF-24 | Consultas N+1 evitadas | RNF | RPCs + Repo | `EXPLAIN ANALYZE`, logs | 2,8 |
| RNF-25 | Índices en columnas de filtro/join | RNF | PostgreSQL | `\di` review | 2 |
| RNF-26 | P95 consultas normales < 3s (objetivo expediente) | RNF | Supabase Dashboard | Load test | 8 |
| RNF-27 | Build Web y Android compilando sin errores | RNF | CI/CD | Pipeline success | 3,9 |

---

## Cobertura por Fase

| Fase | RF Cubiertos | RNF Cubiertos | RN Cubiertos | CU Cubiertos | CP Ejecutados |
|------|--------------|---------------|--------------|--------------|---------------|
| 0 | - | - | - | - | - |
| 1 | - | RNF-09 a RNF-18 (diseño) | - | CU-01 a CU-10 (diseño) | - |
| 2 | RF-06 a RF-12 (backend) | RNF-01 a RNF-04, RNF-19 a RNF-25 | RN-01 a RN-11, RN-13 a RN-22, RN-26 a RN-29 | - | - |
| 3 | RF-01 a RF-05, RF-09 | RNF-02, RNF-11, RNF-13, RNF-15, RNF-17 | RN-01, RN-02 | CU-09, CU-10 | - |
| 4 | RF-06 a RF-12 | RNF-03, RNF-04, RNF-12, RNF-14, RNF-16, RNF-17, RNF-18 | RN-03 a RN-11 | CU-01, CU-02 | CP-03, CP-04, CP-05 |
| 5 | RF-13 a RF-18 | RNF-05, RNF-06, RNF-07, RNF-17, RNF-18 | RN-12 a RN-22 | CU-03, CU-04, CU-05 | CP-01, CP-02, CP-06, CP-07, CP-08, CP-09, CP-11, CP-12, CP-13, CP-14 |
| 6 | RF-19 a RF-32 | RNF-08, RNF-16, RNF-17, RNF-18 | RN-23 a RN-29 | CU-06, CU-07, CU-08, CU-09 | CP-10, CP-11 (admin) |
| 7 | - | RNF-09 a RNF-18 (validación) | - | - | CP-16, UI QA, Accessibility |
| 8 | Todos (regresión) | Todos (auditoría) | Todos (validación) | Todos | CP-01 a CP-16 + Security + Perf |
| 9 | - | RNF-21, RNF-22, RNF-23, RNF-27 | - | - | Build verification |
| 10 | - | - | - | - | - |

---

## Estado de Trazabilidad (Checklist Final v1.0.0)

- [ ] Cada RF tiene al menos 1 MOD, 1 ARCH, 1 CP
- [ ] Cada RN tiene implementación en BD (constraint/trigger/function) + validación en CP
- [ ] Cada RNF tiene criterio medible y evidencia en fase correspondiente
- [ ] Cada CU tiene flujo implementado end-to-end
- [ ] Cada CP obligatorio (01,05,06,07,09,10) aprobado con evidencia
- [ ] No hay celdas vacías en columnas MOD/ARCH para items en alcance
- [ ] Decisiones pendientes (docs/DECISIONES_PENDIENTES.md) resueltas o documentadas como limitación

---

> **Nota:** Esta matriz se actualiza al final de cada fase. Al cierre de Fase 8, debe estar 100% completa para declarar v1.0.0.