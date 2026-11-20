-- ============================================
-- MIGRACIÓN 006: Control de Asistencia, Ausencias y Auditoría General
-- ============================================
-- barber_attendance, barber_absences, audit_logs, settings
-- ============================================

-- --------------------------------------------
-- CONTROL DE ASISTENCIA DE BARBEROS
-- --------------------------------------------
DO $$ BEGIN
    CREATE TYPE public.attendance_status AS ENUM (
        'present',      -- Presente
        'late',         -- Tardanza
        'absent',       -- Ausente (sin justificar)
        'justified',    -- Ausencia justificada
        'on_break',     -- En descanso
        'left_early'    -- Salida anticipada
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE TABLE public.barber_attendance (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    barber_id UUID NOT NULL REFERENCES public.barbers(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    scheduled_start TIME NOT NULL,
    scheduled_end TIME NOT NULL,
    actual_start TIMESTAMPTZ,
    actual_end TIMESTAMPTZ,
    status public.attendance_status NOT NULL DEFAULT 'absent',
    notes TEXT,
    recorded_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (barber_id, date)
);

COMMENT ON TABLE public.barber_attendance IS 'Registro diario de asistencia de barberos. Se genera automáticamente o manualmente.';

CREATE INDEX idx_barber_attendance_barber_date ON public.barber_attendance(barber_id, date);
CREATE INDEX idx_barber_attendance_date ON public.barber_attendance(date);
CREATE INDEX idx_barber_attendance_status ON public.barber_attendance(status);

-- --------------------------------------------
-- AUSENCIAS PLANIFICADAS (vacaciones, licencias)
-- --------------------------------------------
DO $$ BEGIN
    CREATE TYPE public.absence_type AS ENUM (
        'vacation',       -- Vacaciones
        'sick_leave',     -- Licencia médica
        'personal',       -- Asuntos personales
        'training',       -- Capacitación
        'other'           -- Otro
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE TABLE public.barber_absences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    barber_id UUID NOT NULL REFERENCES public.barbers(id) ON DELETE CASCADE,
    type public.absence_type NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    reason TEXT,
    approved_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    approved_at TIMESTAMPTZ,
    is_approved BOOLEAN NOT NULL DEFAULT FALSE,
    creates_schedule_blocks BOOLEAN NOT NULL DEFAULT TRUE, -- auto-crear blocks en schedule_blocks
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (end_date >= start_date)
);

COMMENT ON TABLE public.barber_absences IS 'Ausencias planificadas de barberos. Al aprobar, puede crear schedule_blocks automáticamente.';

CREATE INDEX idx_barber_absences_barber_dates ON public.barber_absences(barber_id, start_date, end_date);
CREATE INDEX idx_barber_absences_approved ON public.barber_absences(is_approved);

-- --------------------------------------------
-- LOG DE AUDITORÍA GENERAL (operaciones sensibles)
-- --------------------------------------------
DO $$ BEGIN
    CREATE TYPE public.audit_action AS ENUM (
        'create', 'update', 'delete', 'login', 'logout',
        'password_change', 'role_change', 'permission_change',
        'data_export', 'data_import', 'config_change',
        'payment_confirm', 'payment_refund',
        'appointment_status_change', 'bulk_operation'
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE TABLE public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    actor_role VARCHAR(20),
    action public.audit_action NOT NULL,
    entity_type VARCHAR(50) NOT NULL, -- ej: 'appointment', 'service', 'barber', 'payment'
    entity_id UUID,
    old_data JSONB,
    new_data JSONB,
    metadata JSONB DEFAULT '{}'::jsonb, -- IP, user_agent, request_id, etc.
    severity VARCHAR(10) NOT NULL DEFAULT 'info' CHECK (severity IN ('debug', 'info', 'warning', 'error', 'critical')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.audit_logs IS 'Log inmutable de auditoría para operaciones sensibles. No editable ni eliminable.';

-- Índices para consultas de auditoría
CREATE INDEX idx_audit_logs_actor ON public.audit_logs(actor_id);
CREATE INDEX idx_audit_logs_entity ON public.audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_logs_action ON public.audit_logs(action);
CREATE INDEX idx_audit_logs_created ON public.audit_logs(created_at);
CREATE INDEX idx_audit_logs_severity ON public.audit_logs(severity);

-- --------------------------------------------
-- CONFIGURACIONES DEL SISTEMA (key-value tipado)
-- --------------------------------------------
CREATE TABLE public.settings (
    key VARCHAR(100) PRIMARY KEY,
    value JSONB NOT NULL,
    value_type VARCHAR(20) NOT NULL DEFAULT 'json' CHECK (value_type IN ('string', 'number', 'boolean', 'json', 'array')),
    category VARCHAR(50) NOT NULL DEFAULT 'general',
    description TEXT,
    is_public BOOLEAN NOT NULL DEFAULT FALSE, -- si true, accesible vía API pública
    is_editable BOOLEAN NOT NULL DEFAULT TRUE, -- si false, solo editable por owner/admin vía SQL
    validation JSONB, -- JSON Schema para validación
    updated_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.settings IS 'Configuraciones dinámicas del sistema. is_public = accesible por clientes (ej: slot_interval_min).';

-- Configuraciones por defecto (DEMO - valores configurables según decisiones de negocio)
INSERT INTO public.settings (key, value, value_type, category, description, is_public, validation) VALUES
-- Reservas
('booking.slot_interval_min', '30', 'number', 'booking', 'Intervalo en minutos entre franjas horarias ofrecidas', TRUE, '{"minimum": 5, "maximum": 60, "multipleOf": 5}'),
('booking.min_advance_hours', '1', 'number', 'booking', 'Antelación mínima en horas para reservar', TRUE, '{"minimum": 0, "maximum": 168}'),
('booking.max_advance_days', '30', 'number', 'booking', 'Días máximos hacia el futuro para reservar', TRUE, '{"minimum": 1, "maximum": 365}'),
('booking.initial_status', '"pending"', 'string', 'booking', 'Estado inicial al crear reserva: pending o confirmed', TRUE, '{"enum": ["pending", "confirmed"]}'),
('booking.pending_blocks_availability', 'true', 'boolean', 'booking', 'Si pending bloquea disponibilidad', TRUE, '{}'),
('booking.confirmed_blocks_availability', 'true', 'boolean', 'booking', 'Si confirmed bloquea disponibilidad', TRUE, '{}'),
('booking.allow_client_cancel', 'true', 'boolean', 'booking', 'Permitir al cliente cancelar su cita', TRUE, '{}'),
('booking.allow_client_reschedule', 'true', 'boolean', 'booking', 'Permitir al cliente reprogramar su cita', TRUE, '{}'),
('booking.min_cancel_hours', '2', 'number', 'booking', 'Antelación mínima en horas para cancelar sin penalización', TRUE, '{"minimum": 0}'),
('booking.min_reschedule_hours', '2', 'number', 'booking', 'Antelación mínima en horas para reprogramar', TRUE, '{"minimum": 0}'),
('booking.max_cancellations_per_month', '0', 'number', 'booking', 'Máx cancelaciones por mes (0 = sin límite)', TRUE, '{"minimum": 0}'),

-- Negocio
('business.name', '"Galindo Barbershop"', 'string', 'business', 'Nombre comercial', TRUE, '{}'),
('business.phone', '""', 'string', 'business', 'Teléfono de contacto', TRUE, '{}'),
('business.email', '""', 'string', 'business', 'Email de contacto', TRUE, '{"format": "email"}'),
('business.address', '""', 'string', 'business', 'Dirección física', TRUE, '{}'),
('business.timezone', '"America/Lima"', 'string', 'business', 'Zona horaria', TRUE, '{}'),
('business.currency', '"PEN"', 'string', 'business', 'Moneda (ISO 4217)', TRUE, '{}'),
('business.locale', '"es_PE"', 'string', 'business', 'Locale para formateo', TRUE, '{}'),

-- Notificaciones
('notifications.email_enabled', 'false', 'boolean', 'notifications', 'Habilitar envío de emails', FALSE, '{}'),
('notifications.whatsapp_enabled', 'false', 'boolean', 'notifications', 'Habilitar WhatsApp (requiere integración)', FALSE, '{}'),
('notifications.reminder_hours_before', '[24, 2]', 'array', 'notifications', 'Horas antes para enviar recordatorios', FALSE, '{}'),

-- Fidelización
('loyalty.enabled', 'true', 'boolean', 'loyalty', 'Programa de fidelidad activado', TRUE, '{}'),

-- Reportes
('reports.auto_export_enabled', 'false', 'boolean', 'reports', 'Exportación automática de reportes', FALSE, '{}'),
('reports.export_frequency', '"daily"', 'string', 'reports', 'Frecuencia: daily, weekly, monthly', FALSE, '{"enum": ["daily", "weekly", "monthly"]}')

ON CONFLICT (key) DO NOTHING;

-- --------------------------------------------
-- VISTAS ÚTILES PARA CONSULTAS COMUNES
-- --------------------------------------------

-- Vista: Citas con datos completos para listados
CREATE OR REPLACE VIEW public.v_appointments_full AS
SELECT
    a.id,
    a.customer_id,
    c.profile_id AS customer_profile_id,
    p.full_name AS customer_name,
    p.phone AS customer_phone,
    p.email AS customer_email,
    a.barber_id,
    b.display_name AS barber_name,
    b.slug AS barber_slug,
    a.service_id,
    s.name AS service_name,
    s.category AS service_category,
    a.starts_at,
    a.ends_at,
    a.status,
    a.price_snapshot,
    a.duration_snapshot_min,
    a.notes,
    a.source,
    a.created_at,
    a.updated_at
FROM public.appointments a
JOIN public.customers c ON a.customer_id = c.profile_id
JOIN public.profiles p ON c.profile_id = p.id
JOIN public.barbers b ON a.barber_id = b.id
JOIN public.services s ON a.service_id = s.id;

COMMENT ON VIEW public.v_appointments_full IS 'Vista completa de citas con datos de cliente, barbero y servicio.';

-- Vista: Disponibilidad agregada por barbero/fecha (para dashboard)
CREATE OR REPLACE VIEW public.v_barber_daily_schedule AS
SELECT
    b.id AS barber_id,
    b.display_name AS barber_name,
    bh.weekday,
    bh.start_time,
    bh.end_time,
    bh.is_open,
    bh.break_start,
    bh.break_end,
    bh.is_break_active
FROM public.barbers b
LEFT JOIN public.barber_hours bh ON b.id = bh.barber_id
WHERE b.is_active = TRUE
UNION ALL
SELECT
    b.id AS barber_id,
    b.display_name AS barber_name,
    bh.weekday,
    bh.start_time,
    bh.end_time,
    bh.is_open,
    bh.break_start,
    bh.break_end,
    bh.is_break_active
FROM public.barbers b
CROSS JOIN public.business_hours bh
WHERE b.is_active = TRUE
  AND NOT EXISTS (SELECT 1 FROM public.barber_hours bh2 WHERE bh2.barber_id = b.id AND bh2.weekday = bh.weekday)
  AND bh.is_open = TRUE;

COMMENT ON VIEW public.v_barber_daily_schedule IS 'Horarios efectivos por barbero (individual o general fallback).';