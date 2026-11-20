# Arquitectura Técnica - Galindo Barbershop v1.0.0

> **Versión:** 0.1 (Borrador Fase 0)
> **Fecha:** 2026-11-20
> **Estado:** Pendiente de validación en Fase 1-3

---

## Visión General

```
┌─────────────────────────────────────────────────────────────────┐
│                      CLIENTE FLUTTER                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │   Android   │  │    Web      │  │   (iOS fut.)│             │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘             │
└─────────┼────────────────┼────────────────┼────────────────────┘
          │ HTTPS/TLS      │ HTTPS/TLS      │
          ▼                ▼                ▼
┌─────────────────────────────────────────────────────────────────┐
│                      SUPABASE BACKEND                           │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐           │
│  │   Auth       │ │  PostgREST   │ │  Realtime    │           │
│  │  (GoTrue)    │ │  (Data API)  │ │  (WebSockets)│           │
│  └──────┬───────┘ └──────┬───────┘ └──────┬───────┘           │
└─────────┼────────────────┼────────────────┼────────────────────┘
          │                │                │
          ▼                ▼                ▼
┌─────────────────────────────────────────────────────────────────┐
│                  POSTGRESQL (Managed)                           │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Esquema public: profiles, customers, barbers, services, │  │
│  │  barber_services, business_hours, barber_hours,          │  │
│  │  schedule_blocks, appointments, appointment_events       │  │
│  │  + RLS Policies + Functions (RPC) + Triggers             │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Stack Tecnológico Definido

| Capa | Tecnología | Versión (objetivo) | Justificación |
|------|------------|-------------------|---------------|
| **Frontend Framework** | Flutter | 3.24+ (stable) | Multiplataforma nativo, single codebase |
| **Language** | Dart | 3.5+ | Type safety, null safety, performance |
| **State Management** | Riverpod | 2.5+ | Compile-time safety, testing, DI |
| **Navigation** | GoRouter | 14+ | Declarative, deep links, guards |
| **Backend/DB** | Supabase (PostgreSQL) | 16+ | Auth + DB + Realtime + Edge Functions |
| **Auth** | Supabase Auth (GoTrue) | Latest | Email/password, Magic Link, OAuth ready |
| **API Data** | PostgREST | Latest | Auto-generated REST from PG schema |
| **RLS** | PostgreSQL Row Level Security | Native | Row-level authz, zero-trust |
| **Hosting Web** | Vercel | Latest | Static Flutter Web, Preview deploys |
| **CI/CD** | GitHub Actions | Latest | Build, test, deploy automation |
| **Android Build** | Gradle + Flutter | Latest | AAB release, Play Store ready |

---

## Arquitectura Flutter (Feature-First Layered)

```
lib/
├── main.dart                 # Entry point, providers, router init
├── app/
│   ├── app.dart              # MaterialApp.router + providers
│   ├── router.dart           # GoRouter config + guards
│   ├── theme/
│   │   ├── theme.dart        # ThemeData light/dark
│   │   ├── colors.dart       # Color tokens (Brand Guide)
│   │   ├── typography.dart   # TextTheme tokens
│   │   ├── spacing.dart      # Spacing/radius/elevation tokens
│   │   └── components.dart   # Component theme overrides
│   └── config/
│       ├── supabase.dart     # Supabase client singleton
│       ├── environment.dart  # Build-time constants (--dart-define)
│       └── routes.dart       # Route names/constants
├── core/
│   ├── config/               # App-wide config
│   ├── errors/               # Failure classes, exception handling
│   ├── network/              # Connectivity, interceptors
│   ├── utils/                # Helpers, formatters, validators
│   ├── widgets/              # Shared UI components (buttons, cards, etc.)
│   ├── extensions/           # Dart extensions
│   └── constants/            # App constants
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/  # AuthRemoteDataSource (Supabase)
│   │   │   ├── models/       # UserModel, SessionModel
│   │   │   └── repositories/ # AuthRepositoryImpl
│   │   ├── domain/
│   │   │   ├── entities/     # User, Session
│   │   │   ├── repositories/ # AuthRepository (interface)
│   │   │   ├── usecases/     # SignIn, SignUp, SignOut, ResetPassword
│   │   │   └── failures/     # AuthFailure subtypes
│   │   └── presentation/
│   │       ├── pages/        # LoginPage, RegisterPage, ForgotPasswordPage
│   │       ├── widgets/      # AuthForm, SocialButtons
│   │       ├── providers/    # authStateProvider, authController
│   │       └── validators/   # Form validators
│   ├── profile/
│   ├── catalog/
│   ├── barbers/
│   ├── availability/
│   ├── bookings/
│   ├── my_bookings/
│   ├── staff_agenda/
│   └── admin/
└── l10n/                     # Arb files para intl (es_PE)
```

### Principios de Capas

| Capa | Responsabilidad | No debe |
|------|-----------------|---------|
| **Presentation** | UI, estado de vista, navegación, validación de formulario | Lógica de negocio, llamadas directas a Supabase |
| **Domain** | Entidades puras, casos de uso, interfaces de repositorio, reglas de negocio | Dependencias de framework (Flutter, Supabase, Riverpod) |
| **Data** | Implementación de repositorios, datasources (Supabase, local), modelos DTO, mapeo | Lógica de presentación, widgets |

---

## Modelo de Datos (Esquema PostgreSQL)

### Entidades Principales

```sql
-- Extensiones
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "btree_gist";  -- Para exclusion constraints

-- Perfiles (vinculados a auth.users)
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name VARCHAR(120) NOT NULL,
    phone VARCHAR(20),
    role VARCHAR(20) NOT NULL CHECK (role IN ('client', 'barber', 'admin')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Clientes (datos adicionales)
CREATE TABLE customers (
    profile_id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
    -- campos adicionales si se requieren (preferencias, notas, etc.)
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Barberos/Profesionales
CREATE TABLE barbers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID UNIQUE REFERENCES profiles(id) ON DELETE SET NULL,
    display_name VARCHAR(120) NOT NULL,
    phone VARCHAR(20),
    avatar_url TEXT,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Servicios
CREATE TABLE services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    duration_min INTEGER NOT NULL CHECK (duration_min > 0),
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Relación Barbero-Servicio (quién hace qué)
CREATE TABLE barber_services (
    barber_id UUID NOT NULL REFERENCES barbers(id) ON DELETE CASCADE,
    service_id UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
    duration_override_min INTEGER CHECK (duration_override_min > 0),
    active BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (barber_id, service_id)
);

-- Horarios generales del negocio
CREATE TABLE business_hours (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    weekday SMALLINT NOT NULL CHECK (weekday BETWEEN 0 AND 6), -- 0=Dom
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_open BOOLEAN NOT NULL DEFAULT TRUE,
    CHECK (end_time > start_time),
    UNIQUE (weekday)
);

-- Horarios por barbero (pueden diferir del general)
CREATE TABLE barber_hours (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    barber_id UUID NOT NULL REFERENCES barbers(id) ON DELETE CASCADE,
    weekday SMALLINT NOT NULL CHECK (weekday BETWEEN 0 AND 6),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_open BOOLEAN NOT NULL DEFAULT TRUE,
    CHECK (end_time > start_time),
    UNIQUE (barber_id, weekday)
);

-- Bloques de horario (descansos, vacaciones, cierres)
CREATE TABLE schedule_blocks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    barber_id UUID REFERENCES barbers(id) ON DELETE CASCADE, -- NULL = todo el negocio
    starts_at TIMESTAMPTZ NOT NULL,
    ends_at TIMESTAMPTZ NOT NULL,
    reason VARCHAR(200) NOT NULL,
    created_by UUID REFERENCES profiles(id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (ends_at > starts_at)
);

-- Citas
CREATE TABLE appointments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL REFERENCES customers(profile_id) ON DELETE CASCADE,
    barber_id UUID NOT NULL REFERENCES barbers(id) ON DELETE CASCADE,
    service_id UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
    starts_at TIMESTAMPTZ NOT NULL,
    ends_at TIMESTAMPTZ NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled', 'rescheduled')),
    price_snapshot NUMERIC(10,2) NOT NULL CHECK (price_snapshot >= 0),
    duration_snapshot_min INTEGER NOT NULL CHECK (duration_snapshot_min > 0),
    note TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (ends_at > starts_at)
);

-- Auditoría de cambios de estado
CREATE TABLE appointment_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    appointment_id UUID NOT NULL REFERENCES appointments(id) ON DELETE CASCADE,
    old_status VARCHAR(20),
    new_status VARCHAR(20) NOT NULL
        CHECK (new_status IN ('pending', 'confirmed', 'completed', 'cancelled', 'rescheduled')),
    actor_id UUID NOT NULL REFERENCES profiles(id),
    reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
```

### Índices Críticos

```sql
-- Consultas frecuentes
CREATE INDEX idx_appointments_customer ON appointments(customer_id);
CREATE INDEX idx_appointments_barber_starts ON appointments(barber_id, starts_at);
CREATE INDEX idx_appointments_status ON appointments(status);
CREATE INDEX idx_appointments_starts_at ON appointments(starts_at);
CREATE INDEX idx_barber_services_barber ON barber_services(barber_id);
CREATE INDEX idx_barber_services_service ON barber_services(service_id);
CREATE INDEX idx_schedule_blocks_barber_time ON schedule_blocks(barber_id, starts_at, ends_at);
CREATE INDEX idx_appointment_events_appointment ON appointment_events(appointment_id);
```

### Restricción de Exclusión (Anti-Doble-Reserva)

```sql
-- Requiere btree_gist extension
-- Impide solapamiento para citas en estados que bloquean disponibilidad
ALTER TABLE appointments ADD CONSTRAINT no_overlapping_appointments
EXCLUDE USING GIST (
    barber_id WITH =,
    tsrange(starts_at, ends_at) WITH &&
) WHERE (status IN ('pending', 'confirmed'));
```

---

## Funciones RPC (Backend Seguro)

| Función | Parámetros | Retorno | Descripción |
|---------|------------|---------|-------------|
| `get_available_slots` | `p_service_id UUID, p_barber_id UUID, p_date DATE` | `SETOF time_slot` | Franjas disponibles calculadas server-side |
| `book_appointment` | `p_service_id UUID, p_barber_id UUID, p_starts_at TIMESTAMPTZ, p_note TEXT` | `appointment` | **Atómica**: valida + inserta cita + evento |
| `cancel_appointment` | `p_appointment_id UUID, p_reason TEXT` | `appointment` | Valida ownership + transición + libera slot |
| `reschedule_appointment` | `p_appointment_id UUID, p_new_starts_at TIMESTAMPTZ` | `appointment` | Atómica: valida nuevo + actualiza + eventos |
| `update_appointment_status` | `p_appointment_id UUID, p_new_status VARCHAR` | `appointment` | Transiciones permitidas por rol |
| `get_my_appointments` | `p_status_filter VARCHAR[]` | `SETOF appointment_view` | Citas del cliente autenticado |
| `get_barber_agenda` | `p_date DATE, p_status_filter VARCHAR[]` | `SETOF appointment_view` | Citas asignadas al barbero autenticado |
| `admin_dashboard_summary` | `p_from DATE, p_to DATE, p_barber_id UUID` | `dashboard_stats` | KPIs operativos para admin |

> **Nota:** Todas las funciones son `SECURITY INVOKER` (default), usan `auth.uid()` para autorización, y ejecutan en una sola transacción donde corresponda.

---

## Autenticación y Autorización

### Flujo de Roles

```
┌─────────────┐     Registro público      ┌──────────────────┐
│  Visitante  │ ────────────────────────► │  Supabase Auth   │
└─────────────┘   (email + password)      │  crea usuario    │
                                            └────────┬─────────┘
                                                     │
                                                     ▼
                                            ┌──────────────────┐
                                            │  Trigger/Function│
                                            │  crea profile    │
                                            │  role = 'client' │
                                            └────────┬─────────┘
                                                     │
                    ┌────────────────────────────────┼────────────────────────────────┐
                    ▼                                ▼                                ▼
            ┌───────────────┐               ┌───────────────┐               ┌───────────────┐
            │    Cliente    │               │   Barbero     │               │  Administrador│
            │  (default)    │               │  (asignado x  │               │  (asignado x  │
            │               │               │   admin)      │               │   admin)      │
            └───────────────┘               └───────────────┘               └───────────────┘
            - Ver catálogo                    - Ver agenda propia             - CRUD servicios
            - Reservar citas                  - Actualizar estados            - CRUD barberos
            - Ver/gestionar sus citas         - Ver datos mínimos cliente     - Horarios/bloqueos
            - Perfil propio                   - Perfil propio                 - Agenda global
                                                               - Usuarios (flujo protegido)
```

### Reglas de Seguridad Críticas

1. **NUNCA** usar `raw_user_meta_data` para autorización → usar `app_metadata` o tabla `profiles.role`
2. **Registro público** siempre crea `role = 'client'`
3. **Elevación a admin/barbero** solo vía función admin protegida / Dashboard Supabase
4. **RLS habilitada** en TODAS las tablas `public.*`
5. **Políticas UPDATE** siempre con `USING` + `WITH CHECK`
6. **Functions** `SECURITY INVOKER` por defecto; `SECURITY DEFINER` solo con justificación documentada
7. **Service Role Key** NUNCA en cliente Flutter, Web bundle, APK, repo

---

## Configuración de Entornos

| Variable | Development | Preview (Vercel) | Production |
|----------|-------------|------------------|------------|
| `SUPABASE_URL` | Local/Dev project | Staging project | Prod project |
| `SUPABASE_ANON_KEY` | Dev anon key | Staging anon key | Prod anon key |
| `SUPABASE_SERVICE_ROLE_KEY` | Solo backend local | Solo CI/CD secrets | Solo CI/CD secrets |
| `FLUTTER_WEB_RENDERER` | `canvaskit` | `canvaskit` | `canvaskit` |
| `VERCEL_ENV` | `development` | `preview` | `production` |

---

## CI/CD Pipeline (GitHub Actions)

```yaml
# .github/workflows/ci.yml (resumen)
jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: dart format --set-exit-if-changed .
      - run: flutter analyze
  
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3

  build_web:
    needs: [analyze, test]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build web --release --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
      - uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.VERCEL_ORG_ID }}
          vercel-project-id: ${{ secrets.VERCEL_PROJECT_ID }}
          vercel-args: '--prod'  # Solo para main branch

  build_android:
    needs: [analyze, test]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build appbundle --release
        env:
          KEYSTORE_BASE64: ${{ secrets.KEYSTORE_BASE64 }}
          KEYSTORE_PASSWORD: ${{ secrets.KEYSTORE_PASSWORD }}
          KEY_PASSWORD: ${{ secrets.KEY_PASSWORD }}
          KEY_ALIAS: ${{ secrets.KEY_ALIAS }}
```

---

## Métricas y Observabilidad (Futuro)

| Área | Herramienta | Métricas Clave |
|------|-------------|----------------|
| **App Performance** | Flutter DevTools / Firebase Performance | Frame render time, startup time, memory |
| **Backend** | Supabase Dashboard / pg_stat_statements | Query latency, connection pool, RLS perf |
| **Errors** | Sentry (opcional) | Crash rate, error types, user impact |
| **Business** | Custom events / Supabase Realtime | Bookings/day, conversion, cancellation rate |

---

## Decisiones Arquitectónicas Clave (ADR)

| ADR | Título | Estado |
|-----|--------|--------|
| 001 | Feature-first layered architecture | ✅ Aceptado |
| 002 | Riverpod for state management | ✅ Aceptado |
| 003 | GoRouter for navigation | ✅ Aceptado |
| 004 | Supabase Auth + PostgreSQL RLS | ✅ Aceptado |
| 005 | RPC functions for critical mutations | ✅ Aceptado |
| 006 | Exclusion constraint for double-booking prevention | 🔄 En validación |
| 007 | Vercel for Flutter Web hosting | ✅ Aceptado |
| 008 | No offline sync in v1.0.0 | ✅ Aceptado |
| 009 | No push notifications in v1.0.0 | ✅ Aceptado |

---

> **Próximo:** Validar esquema y RPCs en Fase 2, implementar capas en Fase 3.