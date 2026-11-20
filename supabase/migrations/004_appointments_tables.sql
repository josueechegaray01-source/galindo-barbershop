-- ============================================
-- MIGRACIÓN 004: Tablas de citas y auditoría
-- ============================================
-- appointments, appointment_events, walk_ins (sin cita previa)
-- ============================================

-- --------------------------------------------
-- ESTADOS DE CITA (enum para consistencia)
-- --------------------------------------------
DO $$ BEGIN
    CREATE TYPE public.appointment_status AS ENUM (
        'pending',      -- Pendiente de confirmación
        'confirmed',    -- Confirmada (bloquea disponibilidad)
        'in_progress',  -- En atención
        'completed',    -- Atendida/Finalizada
        'cancelled',    -- Cancelada
        'rescheduled',  -- Reprogramada
        'no_show',      -- No se presentó
        'walk_in'       -- Sin cita previa (atendido directo)
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- --------------------------------------------
-- CITAS
-- --------------------------------------------
CREATE TABLE public.appointments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    -- Relaciones
    customer_id UUID NOT NULL REFERENCES public.customers(profile_id) ON DELETE CASCADE,
    barber_id UUID NOT NULL REFERENCES public.barbers(id) ON DELETE CASCADE,
    service_id UUID NOT NULL REFERENCES public.services(id) ON DELETE CASCADE,
    -- Tiempo
    starts_at TIMESTAMPTZ NOT NULL,
    ends_at TIMESTAMPTZ NOT NULL,
    -- Estado
    status public.appointment_status NOT NULL DEFAULT 'pending',
    -- Snapshots inmutables (no cambian aunque se modifique el catálogo)
    price_snapshot NUMERIC(10,2) NOT NULL CHECK (price_snapshot >= 0),
    duration_snapshot_min INTEGER NOT NULL CHECK (duration_snapshot_min > 0),
    service_name_snapshot VARCHAR(100) NOT NULL,
    barber_name_snapshot VARCHAR(120) NOT NULL,
    -- Detalles
    notes TEXT,
    cancellation_reason TEXT,
    cancelled_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    cancelled_at TIMESTAMPTZ,
    confirmed_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    confirmed_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    -- Metadata
    source VARCHAR(20) NOT NULL DEFAULT 'app' CHECK (source IN ('app', 'walk_in', 'phone', 'whatsapp', 'admin')),
    idempotency_key VARCHAR(100) UNIQUE, -- para evitar duplicados en reintentos
    metadata JSONB DEFAULT '{}'::jsonb,
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    -- Constraints
    CHECK (ends_at > starts_at),
    CHECK (duration_snapshot_min = EXTRACT(EPOCH FROM (ends_at - starts_at))/60)
);

COMMENT ON TABLE public.appointments IS 'Citas programadas. Snapshots preservan precio/duración/servicio/barbero al momento de la reserva.';
COMMENT ON COLUMN public.appointments.idempotency_key IS 'Clave única para operaciones idempotentes (evita duplicados por reintentos de red).';
COMMENT ON COLUMN public.appointments.source IS 'Origen de la reserva: app, walk_in, phone, whatsapp, admin';

-- --------------------------------------------
-- RESTRICCIÓN DE EXCLUSIÓN (Anti-doble-reserva)
-- Impide solapamiento para el mismo barbero en estados que bloquean disponibilidad
-- Requiere extensión btree_gist (migración 001)
-- --------------------------------------------
ALTER TABLE public.appointments ADD CONSTRAINT no_overlapping_appointments
EXCLUDE USING GIST (
    barber_id WITH =,
    tsrange(starts_at, ends_at) WITH &&
) WHERE (status IN ('pending', 'confirmed', 'in_progress'));

COMMENT ON CONSTRAINT no_overlapping_appointments ON public.appointments IS 'Exclusión GiST: un barbero no puede tener citas solapadas en estados que bloquean disponibilidad.';

-- --------------------------------------------
-- EVENTOS DE AUDITORÍA DE CITAS
-- --------------------------------------------
CREATE TABLE public.appointment_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    appointment_id UUID NOT NULL REFERENCES public.appointments(id) ON DELETE CASCADE,
    old_status public.appointment_status,
    new_status public.appointment_status NOT NULL,
    actor_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    actor_role VARCHAR(20) NOT NULL, -- rol del actor al momento del evento
    reason TEXT,
    metadata JSONB DEFAULT '{}'::jsonb, -- datos extra: nuevo horario, precio anterior, etc.
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.appointment_events IS 'Historial inmutable de cambios de estado y operaciones relevantes en citas.';

-- --------------------------------------------
-- CLIENTES SIN CITA PREVIA (WALK-INS)
-- --------------------------------------------
CREATE TABLE public.walk_ins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID REFERENCES public.customers(profile_id) ON DELETE SET NULL, -- NULL = cliente no registrado
    barber_id UUID NOT NULL REFERENCES public.barbers(id) ON DELETE CASCADE,
    service_id UUID NOT NULL REFERENCES public.services(id) ON DELETE CASCADE,
    starts_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    ends_at TIMESTAMPTZ,
    status public.appointment_status NOT NULL DEFAULT 'walk_in',
    price_snapshot NUMERIC(10,2) NOT NULL CHECK (price_snapshot >= 0),
    duration_snapshot_min INTEGER NOT NULL CHECK (duration_snapshot_min > 0),
    notes TEXT,
    payment_method VARCHAR(20) CHECK (payment_method IN ('cash', 'yape', 'plin', 'card', 'other')),
    payment_amount NUMERIC(10,2) CHECK (payment_amount >= 0),
    payment_confirmed BOOLEAN NOT NULL DEFAULT FALSE,
    created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (ends_at IS NULL OR ends_at > starts_at)
);

COMMENT ON TABLE public.walk_ins IS 'Atenciones sin cita previa. Se convierten en cita completada al finalizar.';

-- --------------------------------------------
-- ÍNDICES CRÍTICOS PARA CONSULTAS FRECUENTES
-- --------------------------------------------
-- Appointments
CREATE INDEX idx_appointments_customer ON public.appointments(customer_id);
CREATE INDEX idx_appointments_barber_starts ON public.appointments(barber_id, starts_at);
CREATE INDEX idx_appointments_status ON public.appointments(status);
CREATE INDEX idx_appointments_starts_at ON public.appointments(starts_at);
CREATE INDEX idx_appointments_date_range ON public.appointments(starts_at, ends_at);
CREATE INDEX idx_appointments_idempotency ON public.appointments(idempotency_key) WHERE idempotency_key IS NOT NULL;
CREATE INDEX idx_appointments_source ON public.appointments(source);

-- Appointment Events
CREATE INDEX idx_appointment_events_appointment ON public.appointment_events(appointment_id);
CREATE INDEX idx_appointment_events_actor ON public.appointment_events(actor_id);
CREATE INDEX idx_appointment_events_created ON public.appointment_events(created_at);

-- Walk-ins
CREATE INDEX idx_walk_ins_barber_date ON public.walk_ins(barber_id, starts_at);
CREATE INDEX idx_walk_ins_customer ON public.walk_ins(customer_id);
CREATE INDEX idx_walk_ins_status ON public.walk_ins(status);