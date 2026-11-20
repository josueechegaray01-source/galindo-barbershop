# Auditoría Técnica Inicial - Galindo Barbershop v1.0.0

> **Fecha:** 2026-11-20
> **Fase:** 0 - Auditoría y Planificación
> **Ejecutado por:** Equipo de Ingeniería (Arquitecto, Lead Flutter, Supabase Specialist, Security, UX, QA, DevOps)

---

## 1. Estado del Repositorio y Entorno

### 1.1 Estructura Actual
```
BARBERIA/
├── .env                          # ✅ Creado con credenciales Supabase
├── .env.example                  # ✅ Creado (plantilla sin secretos)
├── assets/
│   └── branding/
│       └── galindo_logo_original.png  # ✅ Copiado desde GALINDO ICON.jpg
├── docs/
│   ├── PROGRESO.md               # ✅ Este archivo
│   ├── DECISIONES_PENDIENTES.md  # ✅ Creado
│   ├── ARQUITECTURA.md           # ✅ Creado
│   ├── MATRIZ_TRAZABILIDAD.md    # ✅ Creado
│   └── AUDITORIA_FASE0.md        # ✅ Este archivo
├── supabase/
│   └── migrations/               # ✅ Directorio creado (vacío)
├── lib/
│   ├── app/                      # ✅ Directorio creado
│   ├── core/                     # ✅ Directorio creado
│   └── features/                 # ✅ Directorio creado
├── Expediente_Tecnico_Galindo_Barbershop_v1.0.0.pdf  # Documento rector
├── EchegarayMendozaJosue_LRPD_MEJORADO.docx           # Contenido técnico extraído
├── PROMPTS_OPENCODE_GALINDO_BARBERSHOP_v1.0.0.md      # Plan de prompts por fases
└── GALINDO ICON.jpg              # Logo original (JPG)
```

### 1.2 Git
- **Estado:** No inicializado (`git status` → not a git repo)
- **Acción requerida:** `git init` + `.gitignore` antes de Fase 1

### 1.3 Entorno de Desarrollo Verificado

| Herramienta | Versión | Estado | Notas |
|-------------|---------|--------|-------|
| Flutter | 3.47.9 (stable) | ✅ | Channel stable, revision c197ca5199 |
| Dart | 3.13.7 | ✅ | Null safety, WASM support |
| Android SDK | 37.0.0 (API 34) | ✅ | Build-tools, platform-tools, emulator |
| Chrome | Disponible | ✅ | Web development |
| Visual Studio Build Tools | 2026 18.6.1 | ✅ | Windows desktop (no requerido) |
| Python | 3.x | ✅ | Para scripts DOCX/PDF |
| Git | - | ❌ No verificado | Instalar y configurar |

### 1.4 Dispositivos Conectados
```
3 dispositivos disponibles:
- Windows (desktop)
- Chrome (web)
- Android SDK (emulator/device)
```

---

## 2. Conexión Supabase Verificada

### 2.1 Proyecto Objetivo
- **URL:** `https://fithxgprfwkfptgjhqcy.supabase.co`
- **Project Ref:** `fithxgprfwkfptgjhqcy`
- **Región:** (pendiente confirmar en Dashboard)

### 2.2 Pruebas de Conectividad Realizadas

| Endpoint | Método | Resultado | Detalles |
|----------|--------|-----------|----------|
| `/rest/v1/` (OpenAPI) | GET | ✅ 200 OK | Schema público accesible |
| `/auth/v1/health` | GET | ✅ 200 OK | GoTrue v2.198.0 |
| `/storage/v1/bucket` | GET | ✅ 200 OK | 0 buckets creados |

### 2.3 Credenciales Configuradas

| Variable | Valor | Uso |
|----------|-------|-----|
| `SUPABASE_URL` | `https://fithxgprfwkfptgjhqcy.supabase.co` | Cliente Flutter, RPCs |
| `SUPABASE_ANON_KEY` | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` (anon) | Cliente público (Flutter Web, Android) |
| `SUPABASE_SERVICE_ROLE_KEY` | `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` (service_role) | **SOLO** backend/admin, CI/CD, migraciones |

> ⚠️ **CRÍTICO:** La `SUPABASE_SERVICE_ROLE_KEY` **NUNCA** debe incluirse en el bundle Flutter, APK, repo, ni variables `NEXT_PUBLIC_*` / `--dart-define` públicas.

### 2.4 Estado del Esquema Actual
- **Tablas existentes:** 0 (proyecto vacío)
- **Extensiones:** `pgcrypto` disponible, `uuid-ossp` disponible, `btree_gist` **pendiente verificar**
- **Auth:** Configurado (email/password habilitado por defecto)
- **RLS:** No hay políticas (tablas no existen)
- **Realtime:** Habilitado por defecto

---

## 3. Análisis del Expediente Técnico (DOCX/PDF)

### 3.1 Contenido Extraído y Validado

El documento `EchegarayMendozaJosue_LRPD_MEJORADO.docx` contiene el **expediente técnico completo** con:

✅ **Capítulos confirmados:**
- Capítulo 1: Planteamiento del problema
- Capítulo 2: Marco teórico (Flutter, Dart, Supabase, PostgreSQL, RLS, etc.)
- Capítulo 3: Hipótesis y variables
- Capítulo 4: Metodología (aplicada, descriptivo-evaluativa, pruebas controladas + piloto opcional)
- Capítulo 5: **Proyecto técnico completo** (proceso actual, propuesto, modelado negocio, BD, seguridad)
- Anexos A-J: Matriz consistencia, RF, RNF, Arquitectura lógica, Modelo conceptual, Actores/CU, Guía tareas, Ficha observación, Matriz CP, Ficha población

✅ **Modelo de datos propuesto (Cap 5.3.3):**
- `perfiles` (vinculado a `auth.users`)
- `clientes`
- `barberos`
- `servicios`
- `horarios`
- `citas`
- Índices básicos
- RLS habilitada (políticas pendientes)

✅ **Reglas de negocio clave (Cap 5.3.4):**
- Validación disponibilidad en backend/transaccional
- Exclusión GiST para solapamientos
- Estados: pendiente, confirmada, atendida, cancelada, reprogramada
- Snapshots precio/duración
- Zona horaria America/Lima

✅ **Seguridad (Cap 5.3.5):**
- Supabase Auth
- Roles: cliente, personal, administrador
- RLS por tabla
- No claves servicio en cliente

⚠️ **Decisiones pendientes explícitas en el expediente:**
- Duración real de cada servicio
- Horarios de atención reales
- Disponibilidad por barbero
- Reglas de cancelación/reprogramación
- Estado inicial de reserva (pendiente vs confirmada)
- Datos personales mínimos
- Método verificación email

### 3.2 Diferencias Expediente vs Prompts v1.0.0

| Aspecto | Expediente (Cap 5.3.3) | Prompts v1.0.0 (Fase 2) | Acción |
|---------|------------------------|--------------------------|--------|
| Tabla `horarios` | Una sola tabla simple | `business_hours` + `barber_hours` + `schedule_blocks` | **Usar diseño prompts** (más granular) |
| Tabla `barberos` | Sin `profile_id` | Con `profile_id` opcional (link a auth) | **Usar diseño prompts** |
| `barber_services` | No existe | Existe con `duration_override` | **Añadir** (requisito RF) |
| `appointment_events` | No existe | Existe (auditoría) | **Añadir** (requisito RN) |
| Exclusión GiST | Mencionada | Detallada con `WHERE` parcial | **Implementar prompts** |
| RPCs | No especificadas | 7 funciones definidas | **Implementar prompts** |

**Decisión:** Seguir el diseño detallado en los **Prompts v1.0.0** (más completo y listo para implementar), que extiende correctamente el modelo base del expediente.

---

## 4. Análisis de Riesgos y Bloqueadores

### 4.1 Riesgos Críticos (Deben resolverse antes de Fase 2)

| ID | Riesgo | Impacto | Probabilidad | Mitigación |
|----|--------|---------|--------------|------------|
| R-01 | **Token Vercel comprometido** compartido en chat anterior | Seguridad: deploy no autorizado, costos, defacement | **ALTA** | Revocar INMEDIATAMENTE en Vercel Dashboard → Settings → Tokens. Generar nuevo y guardar SOLO en GitHub Actions Secrets. |
| R-02 | **Publishable Key (Anon) no obtenida del Dashboard** | Bloqueo: Flutter no puede conectar a Supabase | **ALTA** | Obtener en Supabase Dashboard → Settings → API → `anon` `public` key. Poner en `.env` y CI secrets. |
| R-03 | **Extensión `btree_gist` no confirmada** | Bloqueo: Exclusión GiST anti-doble-reserva no funciona | **MEDIA** | Verificar en Supabase SQL Editor: `CREATE EXTENSION IF NOT EXISTS btree_gist;` |
| R-04 | **Datos de negocio reales no definidos** | Calidad: DEMO en producción, UX pobre | **ALTA** | Reunión con propietario ANTES de Fase 2 (ver `DECISIONES_PENDIENTES.md`) |
| R-05 | **Fotos/imágenes del local sin autorización** | Legal/Privacidad: uso no autorizado de imágenes | **MEDIA** | Obtener autorización escrita. Usar placeholders hasta entonces. |

### 4.2 Riesgos Técnicos (Gestionables en fases)

| ID | Riesgo | Impacto | Mitigación |
|----|--------|---------|------------|
| R-06 | Flutter Web renderer `canvaskit` tamaño bundle | Performance Web | Evaluar `html` renderer si bundle > 5MB gzipped |
| R-07 | Riverpod 2.x breaking changes | Mantenimiento | Fijar versión en `pubspec.yaml`, probar migración |
| R-08 | GoRouter 14+ API changes | Navegación | Fijar versión, leer changelog |
| R-09 | Supabase Flutter package version lag | Features nuevas | Usar versión estable, no `main` branch |
| R-10 | Android keystore management en CI | Release blocking | Documentar proceso, guardar secrets en GitHub/Forgejo |

### 4.3 Decisiones Arquitectónicas Pendientes Validación

| Decisión | Opciones | Recomendación | Validar en |
|----------|----------|---------------|------------|
| State Management | Riverpod / Bloc / Provider / setState | **Riverpod** (compile-time safety, testing, DI) | Fase 3 |
| Navigation | GoRouter / AutoRoute / Navigator 2.0 manual | **GoRouter** (declarative, deep links, guards) | Fase 3 |
| DI/Service Locator | Riverpod providers / get_it / manual | **Riverpod** (unificado con state) | Fase 3 |
| Localization | `intl` + `flutter_localizations` / easy_localization | **intl + arb** (estándar Flutter) | Fase 3 |
| Date/Time handling | `timezone` package / `intl` / manual | **timezone + intl** (America/Lima correcto) | Fase 3 |
| Forms | `form_builder` / `reactive_forms` / manual | **form_builder** (validación declarativa) | Fase 3 |
| Date picker | `flutter_cupertino_datetime_picker` / `syncfusion` / material | **Material** + custom para rango horario | Fase 4 |

---

## 5. Plan de Ejecución Detallado por Fases

### Fase 0: Auditoría y Planificación ✅ **ESTA FASE**
- [x] Verificar entorno Flutter/Dart/Android
- [x] Conectar y validar Supabase
- [x] Leer expediente técnico (DOCX)
- [x] Crear estructura carpetas
- [x] Crear `.env`, `.env.example`
- [x] Copiar logo
- [x] Crear docs: PROGRESO, DECISIONES_PENDIENTES, ARQUITECTURA, MATRIZ_TRAZABILIDAD, AUDITORIA_FASE0
- [ ] **Inicializar Git** + `.gitignore`
- [ ] **Revocar token Vercel comprometido** (URGENTE)
- [ ] **Obtener Anon Key** de Supabase Dashboard
- [ ] Reunión con propietario para decisiones CRÍTICAS

### Fase 1: Diseño UX/UI y Brand Guide (3-5 días)
**Entradas:** Expediente, Facebook público, Logo, Decisiones pendientes
**Salidas:** `BRAND_GUIDE.md`, `UX_SPECIFICATION.md`, `SCREEN_MAP.md`, `USER_FLOWS.md`, Wireframes
**Actividades:**
1. Investigación visual Facebook (Playwright/computer-use si disponible)
2. Definir Design System (colores, tipografía, spacing, componentes, logo usage)
3. Mapa de navegación completo (3 roles × pantallas)
4. Wireframes todas las pantallas (Figma/Excalidraw/PlantUML)
5. Flujos críticos detallados (registro, reserva, cancelación, admin)
6. Matriz pantalla-requisitos
7. Revisión responsive breakpoints

### Fase 2: Backend Supabase (5-7 días)
**Entradas:** `ARQUITECTURA.md`, `DECISIONES_PENDIENTES.md` (valores DEMO), `MATRIZ_TRAZABILIDAD.md`
**Salidas:** `supabase/migrations/*.sql`, `DATABASE_SCHEMA.md`, `RLS_MATRIX.md`, `SUPABASE_SETUP.md`
**Actividades:**
1. Inspeccionar esquema actual (confirmar vacío)
2. Crear migraciones ordenadas:
   - 001_extensions.sql
   - 002_profiles_customers.sql
   - 003_barbers_services.sql
   - 004_hours_blocks.sql
   - 005_appointments_events.sql
   - 006_indexes_constraints.sql
   - 007_rls_policies.sql
   - 008_functions_rpc.sql
   - 009_triggers.sql
   - 010_seeds_demo.sql (solo DEMO, claramente marcado)
3. Probar cada migración en Supabase (SQL Editor)
4. Verificar RLS con cuentas test (client, barber, admin)
5. Probar RPCs: concurrencia, snapshots, transiciones
6. Documentar todo

### Fase 3: Base Flutter (5-7 días)
**Entradas:** `BRAND_GUIDE.md`, `ARQUITECTURA.md`, `SUPABASE_SETUP.md`
**Salidas:** `lib/` completo base, `FLUTTER_ARCHITECTURE.md`, builds verificados
**Actividades:**
1. `flutter create .` (o usar estructura existente)
2. `pubspec.yaml` con dependencias fijadas
3. `lib/main.dart` + providers + router init
4. `app/theme/` completo (tokens + ThemeData)
5. `app/router.dart` + guards por rol
6. `core/` (config, errors, network, utils, widgets, constants)
7. `features/auth/` completo (data, domain, presentation)
8. Auth flow: splash → auth check → login/register → home por rol
9. `intl` + `es_PE` + `America/Lima` + PEN
10. Responsive breakpoints + navigation adaptativa
11. `flutter analyze`, `dart format`, `flutter test`, `flutter build web --release`
12. Documentar arquitectura Flutter

### Fase 4: Módulos Cliente - Catálogo, Barberos, Disponibilidad (5-7 días)
**Entradas:** Fase 3 base, Fase 2 RPCs
**Salidas:** `features/catalog/`, `features/barbers/`, `features/availability/`
**Actividades:**
1. Repository + UseCases + Providers para cada feature
2. UI: ServicesPage, ServiceDetail, BarbersPage, BarberDetail
3. Availability: DatePicker → BarberSelector → SlotsGrid
4. RPC `get_available_slots` integration
5. Loading/Empty/Error/Offline states
6. Responsive testing (360, 390, 768, 1366, 1440px)
7. Unit + Widget tests

### Fase 5: Flujo Crítico Reservas + Mis Citas (7-10 días)
**Entradas:** Fases 2, 3, 4
**Salidas:** `features/bookings/`, `features/my_bookings/`
**Actividades:**
1. Booking flow: Service → Barber → Date → Slot → Summary → Confirm
2. `book_appointment` RPC integration (idempotency key)
3. Concurrency handling (UI feedback + retry logic)
4. MyBookings: list, filters, detail
5. Cancel/Reschedule: parametrizable, RPCs + UI
6. State machine documentation + tests
7. Appointment events audit trail
8. **Tests obligatorios:** CP-01, CP-05, CP-06, CP-07, CP-09, CP-10, CP-11, CP-12, CP-13, CP-14

### Fase 6: Panel Barbero + Panel Admin (7-10 días)
**Entradas:** Fases 2, 3, 5
**Salidas:** `features/staff_agenda/`, `features/admin/`
**Actividades:**
1. Staff: Agenda diaria/semanal, detail, status actions
2. Admin: Dashboard, Global Agenda, CRUDs (Services, Barbers, Assignments, Hours, Blocks)
3. User management (flujo protegido)
4. Audit log viewer
5. Role-based authorization tests (RLS + RPC)
6. Responsive: Desktop sidebar + tables, Tablet hybrid, Mobile cards

### Fase 7: Integración + Refinamiento Visual + Accesibilidad (5-7 días)
**Entradas:** Todas las fases anteriores
**Salidas:** `UI_QA_REPORT.md`, builds pulidos
**Actividades:**
1. Recorrido end-to-end 3 roles con cuentas test
2. Visual QA vs Brand Guide + Facebook refs
3. Logo usage audit
4. Viewport testing (5 tamaños)
5. Android physical device testing
6. Accessibility audit (contraste, 48dp, semantics, focus, text scaling)
7. Cleanup DEMO data / placeholders
8. Navigation security (deep links, guards)

### Fase 8: QA Integral + Seguridad + Rendimiento (5-7 días)
**Entradas:** Fase 7 completo
**Salidas:** `QA_TEST_PLAN.md`, `QA_TEST_RESULTS.md`, `SECURITY_AUDIT.md`, `KNOWN_ISSUES.md`
**Actividades:**
1. Ejecutar matriz CP-01 a CP-16 + Security + Performance
2. Static analysis: `flutter analyze`, `dart format --set-exit-if-changed`
3. Security: RLS audit, IDOR tests, secrets scan, dependency audit
4. Performance: Query analysis, bundle size, frame timing
5. Privacy: PII check, consent docs
6. Documentar incidencias con severidad

### Fase 9: Deploy Web (Vercel) + Build Android (3-5 días)
**Entradas:** Fase 8 aprobado
**Salidas:** Preview URL, AAB/APK, `DEPLOYMENT_WEB.md`, `DEPLOYMENT_ANDROID.md`, `RELEASE_NOTES_1.0.0.md`
**Actividades:**
1. `flutter build web --release` con `--dart-define` secrets
2. `vercel.json` SPA config
3. Vercel Preview deploy (NO production sin autorización)
4. Verify Preview: auth, routing, booking, responsive
5. Android: package name, icon, splash, versionCode/versionName
6. `flutter build appbundle --release` (keystore en secrets)
7. Test físico: install, login, booking, roles
8. Hash artifacts (SHA-256)

### Fase 10: Documentación Final + Cierre (3-5 días)
**Entradas:** Todo el proyecto
**Salidas:** 12 manuales en `docs/`, `ACTA_ENTREGA.md`
**Actividades:**
1. Escribir 10 manuales + Release Notes + Acta
2. Actualizar PROGRESO, DECISIONES_PENDIENTES, MATRIZ_TRAZABILIDAD, KNOWN_ISSUES
3. Auditoría cierre: trazabilidad 100%, no TODOs críticos, no DEMO en prod
4. Final build + test suite
5. Clasificar incidencias finales
6. Entregar reporte final

### Fase EXTRA: Revisión Independiente (2-3 días)
**Entradas:** Proyecto completo v1.0.0
**Salidas:** `FINAL_INDEPENDENT_REVIEW.md`
**Actividades:**
1. Auditoría externa simulada (código, BD, RLS, RPC, builds, docs)
2. Buscar: doble reserva, IDOR, privilege escalation, data leakage, secrets
3. Corregir hallazgos sin cambios destructivos
4. Re-ejecutar tests
5. Categorizar: APTO PREVIEW / APTO CON RESTRICCIONES PROD / NO APTO PROD

---

## 6. Estimación de Esfuerzo Total

| Fase | Días Estimados | Acumulado | Hitos Clave |
|------|----------------|-----------|-------------|
| 0 | 1 | 1 | ✅ Auditoría completa, Git init, Vercel token rotado |
| 1 | 4 | 5 | Brand Guide + UX Spec aprobados |
| 2 | 6 | 11 | Supabase migraciones + RLS + RPCs funcionando |
| 3 | 6 | 17 | Flutter base + Auth + builds OK |
| 4 | 6 | 23 | Catálogo + Barberos + Disponibilidad integrados |
| 5 | 9 | 32 | **Reservas completas + Mis Citas + CP obligatorios** |
| 6 | 9 | 41 | Paneles Staff + Admin funcionales |
| 7 | 6 | 47 | UI/UX pulido + Accesibilidad |
| 8 | 6 | 53 | **QA completo + Seguridad + Performance** |
| 9 | 4 | 57 | Web Preview + Android AAB |
| 10 | 4 | 61 | Documentación final + Acta |
| EXTRA | 3 | 64 | Revisión independiente + firma |

**Total estimado: ~64 días hábiles (~3 meses calendario)**

> **Nota:** Las fases 2-6 pueden tener paralelismo parcial (backend vs frontend). Estimación asume 1-2 desarrolladores senior full-time.

---

## 7. Próximos Pasos Inmediatos (Action Items)

### 🔴 URGENTE (Hoy)
1. **Revocar token Vercel comprometido**
   - Ir a https://vercel.com/account/tokens
   - Revocar token compartido en chat anterior
   - Crear nuevo token → Guardar en GitHub Secrets como `VERCEL_TOKEN`

2. **Obtener Supabase Anon Key**
   - Ir a https://supabase.com/dashboard/project/fithxgprfwkfptgjhqcy/settings/api
   - Copiar `anon` `public` key
   - Actualizar `.env` local
   - Guardar en GitHub Secrets como `SUPABASE_ANON_KEY`

3. **Inicializar Git**
   ```bash
   cd C:\Users\lENOVO\Desktop\BARBERIA
   git init
   git add .
   git commit -m "chore: initial project structure and Phase 0 audit docs"
   ```

4. **Crear `.gitignore`**
   ```gitignore
   # Secrets
   .env
   *.keystore
   *.jks
   
   # Build outputs
   build/
   .dart_tool/
   *.apk
   *.aab
   *.ipa
   
   # IDE
   .idea/
   .vscode/
   *.iml
   
   # OS
   .DS_Store
   Thumbs.db
   
   # Logs
   *.log
   
   # Coverage
   coverage/
   ```

### 🟡 ESTA SEMANA
5. **Reunión con propietario Galindo Barbershop** para resolver `DECISIONES_PENDIENTES.md` (sección CRÍTICO)
6. **Investigación visual Facebook** (Fase 1) - capturar referencias de marca
7. **Iniciar Fase 1** - Brand Guide + UX Specification

### 🟢 PRÓXIMAS 2 SEMANAS
8. **Fase 2** - Migraciones Supabase completas
9. **Fase 3** - Base Flutter funcional

---

## 8. Aprobación de Fase 0

| Rol | Nombre | Aprobación | Fecha | Comentarios |
|-----|--------|------------|-------|-------------|
| Arquitecto | - | ⬜ Pendiente | - | Validar arquitectura propuesta |
| Lead Flutter | - | ⬜ Pendiente | - | Validar stack Flutter, dependencias |
| Supabase Specialist | - | ⬜ Pendiente | - | Validar modelo BD, RPCs, RLS |
| Security | - | ⬜ Pendiente | - | Validar modelo authz, threat model |
| UX/UI | - | ⬜ Pendiente | - | Validar approach Fase 1 |
| QA | - | ⬜ Pendiente | - | Validar matriz CP, strategy |
| DevOps | - | ⬜ Pendiente | - | Validar CI/CD, secrets, deploy |

---

> **Firma digital de cierre Fase 0:** _________________________
> **Fecha:** _________________________
> **Próxima fase autorizada:** □ Fase 1 (Diseño UX/UI)  □ Requiere ajustes previos