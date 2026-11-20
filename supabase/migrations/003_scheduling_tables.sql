-- ============================================
-- MIGRACIÓN 003: Tablas de horarios y disponibilidad
-- ============================================
-- business_hours, barber_hours, schedule_blocks
-- ============================================

-- --------------------------------------------
-- HORARIOS GENERALES DEL NEGOCIO
-- --------------------------------------------
CREATE TABLE public.business_hours (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    weekday SMALLINT NOT NULL CHECK (weekday BETWEEN 0 AND 6), -- 0=Domingo, 6=Sábado
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_open BOOLEAN NOT NULL DEFAULT TRUE,
    break_start TIME,
    break_end TIME,
    is_break_active BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (weekday),
    CHECK (end_time > start_time),
    CHECK (break_end IS NULL OR break_start IS NULL OR break_end > break_start),
    CHECK (break_start IS NULL OR (break_start >= start_time AND break_start <= end_time)),
    CHECK (break_end IS NULL OR (break_end >= start_time AND break_end <= end_time))
);

COMMENT ON TABLE public.business_hours IS 'Horario general de atención del local. weekday: 0=Dom, 1=Lun, ..., 6=Sáb. break para almuerzo/pausa.';

-- Insertar horario por defecto (DEMO - Lun-Sáb 9:00-20:00, break 13:00-14:00)
INSERT INTO public.business_hours (weekday, start_time, end_time, is_open, break_start, break_end, is_break_active) VALUES
(0, '09:00', '20:00', FALSE, NULL, NULL, FALSE),  -- Domingo cerrado
(1, '09:00', '20:00', TRUE, '13:00', '14:00', TRUE),   -- Lunes
(2, '09:00', '20:00', TRUE, '13:00', '14:00', TRUE),   -- Martes
(3, '09:00', '20:00', TRUE, '13:00', '14:00', TRUE),   -- Miércoles
(4, '09:00', '20:00', TRUE, '13:00', '14:00', TRUE),   -- Jueves
(5, '09:00', '20:00', TRUE, '13:00', '14:00', TRUE),   -- Viernes
(6, '09:00', '20:00', TRUE, '13:00', '14:00', TRUE)    -- Sábado
ON CONFLICT (weekday) DO NOTHING;

-- --------------------------------------------
-- HORARIOS INDIVIDUALES POR BARBERO
-- --------------------------------------------
CREATE TABLE public.barber_hours (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    barber_id UUID NOT NULL REFERENCES public.barbers(id) ON DELETE CASCADE,
    weekday SMALLINT NOT NULL CHECK (weekday BETWEEN 0 AND 6),
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_open BOOLEAN NOT NULL DEFAULT TRUE,
    break_start TIME,
    break_end TIME,
    is_break_active BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (barber_id, weekday),
    CHECK (end_time > start_time),
    CHECK (break_end IS NULL OR break_start IS NULL OR break_end > break_start),
    CHECK (break_start IS NULL OR (break_start >= start_time AND break_start <= end_time)),
    CHECK (break_end IS NULL OR (break_end >= start_time AND break_end <= end_time))
);

COMMENT ON TABLE public.barber_hours IS 'Horarios individuales por barbero. Si no existe registro para un día, se usa business_hours. Sobrescribe el horario general.';

-- --------------------------------------------
-- BLOQUEOS DE HORARIO (descansos, vacaciones, cierres)
-- --------------------------------------------
CREATE TABLE public.schedule_blocks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    barber_id UUID REFERENCES public.barbers(id) ON DELETE CASCADE, -- NULL = bloqueo para todo el negocio
    title VARCHAR(200) NOT NULL,
    reason VARCHAR(500),
    starts_at TIMESTAMPTZ NOT NULL,
    ends_at TIMESTAMPTZ NOT NULL,
    is_recurring BOOLEAN NOT NULL DEFAULT FALSE,
    recurrence_rule TEXT, -- RRULE estándar (ej: FREQ=WEEKLY;BYDAY=MO,WE,FR)
    recurrence_end DATE,
    color VARCHAR(7) DEFAULT '#EF4444', -- hex color para UI
    created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (ends_at > starts_at)
);

COMMENT ON TABLE public.schedule_blocks IS 'Bloqueos de disponibilidad. barber_id NULL = afecta a todos. recurrence_rule sigue RFC 5545.';

-- --------------------------------------------
-- ÍNDICES PARA CONSULTAS DE DISPONIBILIDAD
-- --------------------------------------------
CREATE INDEX idx_business_hours_weekday ON public.business_hours(weekday);
CREATE INDEX idx_barber_hours_barber_weekday ON public.barber_hours(barber_id, weekday);
CREATE INDEX idx_schedule_blocks_barber_time ON public.schedule_blocks(barber_id, starts_at, ends_at);
CREATE INDEX idx_schedule_blocks_global_time ON public.schedule_blocks(starts_at, ends_at) WHERE barber_id IS NULL;
CREATE INDEX idx_schedule_blocks_recurring ON public.schedule_blocks(is_recurring) WHERE is_recurring = TRUE;