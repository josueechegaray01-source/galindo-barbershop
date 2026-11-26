-- ============================================================
-- MIGRACIÓN 010: Reparación del backend REAL de Galindo Barbershop
-- ============================================================
-- Contexto: la base de datos real usa un esquema simplificado, distinto de
-- las migraciones 001-009, y se creó sin los privilegios por defecto: ni
-- `authenticated` ni `service_role` podían leer o escribir nada, y no
-- existían las funciones de reserva.
--
-- Este script repara SOBRE el esquema real existente:
--   1. Privilegios mínimos por rol.
--   2. RLS y políticas (catálogo público; citas y perfil solo del dueño).
--   3. FKs de barbero: apuntaban a profiles.id; se apuntan a barbers.id
--      (la fuente real del catálogo), sin validar filas antiguas.
--   4. Trigger de perfil para nuevos usuarios + backfill.
--   5. Funciones de reserva:
--        get_available_slots(p_service_id, p_barber_id, p_date)
--        book_appointment(p_service_id, p_barber_id, p_starts_at, p_notes)
--
-- Idempotente: se puede ejecutar varias veces sin daño.
-- Ejecutar como rol postgres (Supabase Dashboard → SQL Editor).
--
-- Supuesto documentado: barber_hours.day_of_week usa la convención de
-- EXTRACT(DOW): 0=Domingo, 1=Lunes … 6=Sábado (igual que la migración 003).
-- ============================================================

BEGIN;

-- ============================================================
-- 1. PRIVILEGIOS
-- ============================================================
GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;

-- Catálogo y horarios: lectura pública (landing y flujo de reserva)
GRANT SELECT ON TABLE public.services, public.barbers, public.barber_services,
    public.business_hours
    TO anon, authenticated;

-- Citas: el cliente autenticado ve y crea las suyas
-- (la vía principal de escritura es la RPC book_appointment)
GRANT SELECT, INSERT, UPDATE ON TABLE public.appointments TO authenticated;

-- Perfil propio
GRANT SELECT, UPDATE ON TABLE public.profiles TO authenticated;

-- Administración: service_role es la clave de gestión y nunca llega al cliente
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public
    TO service_role;

-- ============================================================
-- 2. RLS + POLÍTICAS
-- ============================================================
DO $$
DECLARE t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'services','barbers','barber_services','business_hours','barber_hours',
    'schedule_blocks','barber_absences','appointments','appointment_events',
    'walk_ins','payments','loyalty_points','reviews','notifications',
    'profiles','settings','audit_logs','barber_attendance'
  ] LOOP
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t);
  END LOOP;
END $$;

DROP POLICY IF EXISTS galindo_services_read ON public.services;
CREATE POLICY galindo_services_read ON public.services
    FOR SELECT TO anon, authenticated
    USING (is_active = TRUE AND is_public = TRUE);

DROP POLICY IF EXISTS galindo_barbers_read ON public.barbers;
CREATE POLICY galindo_barbers_read ON public.barbers
    FOR SELECT TO anon, authenticated USING (is_active = TRUE);

DROP POLICY IF EXISTS galindo_barber_services_read ON public.barber_services;
CREATE POLICY galindo_barber_services_read ON public.barber_services
    FOR SELECT TO anon, authenticated USING (TRUE);

DROP POLICY IF EXISTS galindo_business_hours_read ON public.business_hours;
CREATE POLICY galindo_business_hours_read ON public.business_hours
    FOR SELECT TO anon, authenticated USING (TRUE);

DROP POLICY IF EXISTS galindo_appointments_select_own ON public.appointments;
CREATE POLICY galindo_appointments_select_own ON public.appointments
    FOR SELECT TO authenticated USING (customer_id = auth.uid());

DROP POLICY IF EXISTS galindo_appointments_insert_own ON public.appointments;
CREATE POLICY galindo_appointments_insert_own ON public.appointments
    FOR INSERT TO authenticated
    WITH CHECK (customer_id = auth.uid() AND status = 'pending');

DROP POLICY IF EXISTS galindo_appointments_update_own ON public.appointments;
CREATE POLICY galindo_appointments_update_own ON public.appointments
    FOR UPDATE TO authenticated
    USING (customer_id = auth.uid() AND status = 'pending')
    WITH CHECK (customer_id = auth.uid());

DROP POLICY IF EXISTS galindo_profiles_select_own ON public.profiles;
CREATE POLICY galindo_profiles_select_own ON public.profiles
    FOR SELECT TO authenticated USING (id = auth.uid());

DROP POLICY IF EXISTS galindo_profiles_update_own ON public.profiles;
CREATE POLICY galindo_profiles_update_own ON public.profiles
    FOR UPDATE TO authenticated
    USING (id = auth.uid())
    WITH CHECK (id = auth.uid());

-- ============================================================
-- 3. FKs DE BARBERO -> barbers.id
-- ============================================================
-- El catálogo real de barberos vive en `barbers`. Las FKs hacia
-- profiles.id son un error de diseño: los barberos del catálogo no tienen
-- usuario en auth. Se recrean NOT VALID para no fallar con filas antiguas.
DO $$
DECLARE r RECORD;
BEGIN
  FOR r IN
    SELECT c.conname, c.conrelid::regclass AS tbl
    FROM pg_constraint c
    JOIN pg_attribute a
      ON a.attrelid = c.conrelid AND a.attnum = c.conkey[1]
    WHERE c.contype = 'f'
      AND c.confrelid = 'public.profiles'::regclass
      AND a.attname = 'barber_id'
      AND c.relid IN (
        'public.appointments'::regclass, 'public.walk_ins'::regclass,
        'public.barber_hours'::regclass, 'public.barber_services'::regclass,
        'public.schedule_blocks'::regclass, 'public.barber_absences'::regclass,
        'public.barber_attendance'::regclass)
  LOOP
    EXECUTE format('ALTER TABLE %s DROP CONSTRAINT %I', r.tbl, r.conname);
  END LOOP;
END $$;

DO $$
DECLARE t TEXT;
BEGIN
  FOREACH t IN ARRAY ARRAY['appointments','walk_ins','barber_hours',
      'barber_services','schedule_blocks','barber_absences','barber_attendance']
  LOOP
    EXECUTE format('ALTER TABLE public.%I DROP CONSTRAINT IF EXISTS %I',
                   t, t || '_barber_id_fkey');
    EXECUTE format(
      'ALTER TABLE public.%I ADD CONSTRAINT %I FOREIGN KEY (barber_id) '
      'REFERENCES public.barbers(id) ON DELETE CASCADE NOT VALID',
      t, t || '_barber_id_fkey');
  END LOOP;
END $$;

CREATE INDEX IF NOT EXISTS idx_appointments_barber_range
    ON public.appointments (barber_id, scheduled_start, scheduled_end);
CREATE INDEX IF NOT EXISTS idx_appointments_customer
    ON public.appointments (customer_id, scheduled_start);

-- ============================================================
-- 4. PERFIL AUTOMÁTICO PARA NUEVOS USUARIOS + BACKFILL
-- ============================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, phone, role, is_email_verified)
  VALUES (
    NEW.id,
    COALESCE(NEW.email, ''),
    COALESCE(
      NULLIF(NEW.raw_user_meta_data->>'full_name', ''),
      NULLIF(NEW.raw_user_meta_data->>'name', ''),
      CASE WHEN NEW.email IS NOT NULL THEN split_part(NEW.email, '@', 1) END,
      'Cliente'),
    NULLIF(NEW.raw_user_meta_data->>'phone', ''),
    'client',
    NEW.email_confirmed_at IS NOT NULL
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

INSERT INTO public.profiles (id, email, full_name, role, is_email_verified)
SELECT u.id,
       COALESCE(u.email, ''),
       COALESCE(
         NULLIF(u.raw_user_meta_data->>'full_name', ''),
         CASE WHEN u.email IS NOT NULL THEN split_part(u.email, '@', 1) END,
         'Cliente'),
       'client',
       u.email_confirmed_at IS NOT NULL
FROM auth.users u
LEFT JOIN public.profiles p ON p.id = u.id
WHERE p.id IS NULL
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 5. JORNADA APLICABLE (helper compartido por las dos RPCs)
-- ============================================================
-- Devuelve la ventana válida de un barbero para un día de la semana:
-- horario general del local (business_hours) acotado por el horario
-- individual (barber_hours) cuando exista. is_open = FALSE si está cerrado.
-- ============================================================
CREATE OR REPLACE FUNCTION public.galindo_service_window(
    p_barber_id UUID,
    p_dow INTEGER,
    OUT o_open TIME,
    OUT o_close TIME,
    OUT o_break_from TIME,
    OUT o_break_to TIME,
    OUT o_is_open BOOLEAN
)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    g_open TIME;
    g_close TIME;
    b RECORD;
BEGIN
    o_open := NULL; o_close := NULL;
    o_break_from := NULL; o_break_to := NULL;
    o_is_open := FALSE;

    -- Horario general (si existe la fila y el día está definido)
    SELECT CASE p_dow
             WHEN 1 THEN monday_open    WHEN 2 THEN tuesday_open
             WHEN 3 THEN wednesday_open WHEN 4 THEN thursday_open
             WHEN 5 THEN friday_open    WHEN 6 THEN saturday_open
             WHEN 0 THEN sunday_open   END,
           CASE p_dow
             WHEN 1 THEN monday_close    WHEN 2 THEN tuesday_close
             WHEN 3 THEN wednesday_close WHEN 4 THEN thursday_close
             WHEN 5 THEN friday_close    WHEN 6 THEN saturday_close
             WHEN 0 THEN sunday_close   END
    INTO g_open, g_close
    FROM public.business_hours
    LIMIT 1;

    IF FOUND AND g_open IS NOT NULL AND g_close IS NOT NULL THEN
        o_open := g_open;
        o_close := g_close;
    END IF;

    -- Horario individual del barbero
    SELECT * INTO b FROM public.barber_hours
    WHERE barber_id = p_barber_id AND day_of_week = p_dow
    LIMIT 1;

    IF FOUND THEN
        -- Si el local tiene horario y el barbero no lo extiende más allá
        IF COALESCE(b.is_day_off, FALSE) OR b.open_time IS NULL
           OR b.close_time IS NULL THEN
            RETURN;                       -- día libre del barbero
        END IF;

        IF o_open IS NOT NULL THEN
            -- Intersección: nunca fuera del local
            o_open  := GREATEST(o_open,  b.open_time);
            o_close := LEAST(o_close, b.close_time);
        ELSE
            o_open  := b.open_time;
            o_close := b.close_time;
        END IF;
        o_break_from := b.break_start;
        o_break_to   := b.break_end;
    END IF;

    o_is_open := o_open IS NOT NULL AND o_close IS NOT NULL AND o_open < o_close;
END;
$$;

-- ============================================================
-- 6. OCUPACIÓN DE UN INTERVALO (helper de las RPCs)
-- ============================================================
CREATE OR REPLACE FUNCTION public.galindo_slot_is_free(
    p_barber_id UUID,
    p_from TIMESTAMP,
    p_to TIMESTAMP
)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT NOT EXISTS (
        SELECT 1 FROM public.appointments a
        WHERE a.barber_id = p_barber_id
          AND a.status IN ('pending', 'confirmed', 'in_progress')
          AND tsrange(a.scheduled_start, a.scheduled_end, '[)')
              && tsrange(p_from, p_to, '[)')
    ) AND NOT EXISTS (
        SELECT 1 FROM public.schedule_blocks sb
        WHERE (sb.barber_id = p_barber_id OR sb.barber_id IS NULL)
          AND tsrange(sb.block_start, sb.block_end)
              && tsrange(p_from, p_to, '[)')
    ) AND NOT EXISTS (
        SELECT 1 FROM public.barber_absences ba
        WHERE ba.barber_id = p_barber_id
          AND tsrange(ba.absence_start, ba.absence_end)
              && tsrange(p_from, p_to, '[)')
    );
$$;

-- ============================================================
-- 7. RPC: FRANJAS DISPONIBLES
-- ============================================================
-- Devuelve slot_start/slot_end (timestamptz, zona America/Lima) libres
-- para un servicio, barbero y fecha (YYYY-MM-DD).
-- ============================================================
CREATE OR REPLACE FUNCTION public.get_available_slots(
    p_service_id UUID,
    p_barber_id UUID,
    p_date DATE
)
RETURNS TABLE (slot_start TIMESTAMPTZ, slot_end TIMESTAMPTZ)
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_duration INTEGER;
    v_interval INTEGER;
    v_advance  INTEGER;
    v_max_days INTEGER;
    v_win public.galindo_service_window%ROWTYPE;
    v_cur TIME;
    v_end TIME;
    v_from TIMESTAMPTZ;
    v_to TIMESTAMPTZ;
    v_naive_from TIMESTAMP;
    v_naive_to TIMESTAMP;
    v_now TIMESTAMPTZ := now();
BEGIN
    -- Servicio activo y público
    SELECT duration_min INTO v_duration
    FROM public.services
    WHERE id = p_service_id AND is_active = TRUE AND is_public = TRUE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'El servicio seleccionado no está disponible.';
    END IF;

    -- Barbero activo que realiza el servicio (con duración propia si existe)
    IF NOT EXISTS (SELECT 1 FROM public.barbers
                   WHERE id = p_barber_id AND is_active = TRUE) THEN
        RAISE EXCEPTION 'El barbero seleccionado no está disponible.';
    END IF;

    SELECT COALESCE(bs.duration_minutes, v_duration) INTO v_duration
    FROM public.barber_services bs
    WHERE bs.barber_id = p_barber_id AND bs.service_id = p_service_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'El barbero seleccionado no realiza este servicio.';
    END IF;

    -- Configuración (con valores por defecto del negocio)
    SELECT COALESCE(NULLIF(value, '')::INTEGER, 30) INTO v_interval
    FROM public.settings WHERE key = 'booking.slot_interval_min';
    SELECT COALESCE(NULLIF(value, '')::INTEGER, 60) INTO v_advance
    FROM public.settings WHERE key = 'booking.min_advance_minutes';
    SELECT COALESCE(NULLIF(value, '')::INTEGER, 30) INTO v_max_days
    FROM public.settings WHERE key = 'booking.max_advance_days';
    v_interval := GREATEST(COALESCE(v_interval, 30), 5);
    v_advance  := COALESCE(v_advance, 60);
    v_max_days := COALESCE(v_max_days, 30);

    IF p_date < (v_now AT TIME ZONE 'America/Lima')::DATE
       OR p_date > ((v_now AT TIME ZONE 'America/Lima')::DATE + v_max_days) THEN
        RETURN;                            -- fuera del rango de reserva
    END IF;

    SELECT * INTO v_win FROM public.galindo_service_window(
        p_barber_id, EXTRACT(DOW FROM p_date)::INTEGER);
    IF NOT v_win.o_is_open THEN
        RETURN;                            -- local o barbero cerrado ese día
    END IF;

    v_cur := v_win.o_open;
    v_end  := v_win.o_close - make_interval(mins => v_duration);

    WHILE v_cur <= v_end LOOP
        -- Saltar solapamiento con el descanso del barbero
        IF v_win.o_break_from IS NOT NULL AND v_win.o_break_to IS NOT NULL
           AND v_cur < v_win.o_break_to
           AND (v_cur + make_interval(mins => v_duration)) > v_win.o_break_from THEN
            v_cur := v_win.o_break_to;
            CONTINUE;
        END IF;

        v_from := (p_date::TEXT || ' ' || v_cur::TEXT)::TIMESTAMP
                  AT TIME ZONE 'America/Lima';
        v_to   := v_from + make_interval(mins => v_duration);
        v_naive_from := v_from AT TIME ZONE 'America/Lima';
        v_naive_to   := v_to   AT TIME ZONE 'America/Lima';

        -- Antelación mínima y ausencia de citas, bloqueos o ausencias
        IF v_from >= v_now + make_interval(mins => v_advance)
           AND public.galindo_slot_is_free(
                   p_barber_id, v_naive_from, v_naive_to) THEN
            slot_start := v_from;
            slot_end   := v_to;
            RETURN NEXT;
        END IF;

        v_cur := v_cur + make_interval(mins => v_interval);
    END LOOP;
END;
$$;

-- ============================================================
-- 8. RPC: RESERVAR CITA (atómica)
-- ============================================================
CREATE OR REPLACE FUNCTION public.book_appointment(
    p_service_id UUID,
    p_barber_id UUID,
    p_starts_at TIMESTAMPTZ,
    p_notes TEXT DEFAULT NULL
)
RETURNS public.appointments
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_customer UUID := auth.uid();
    v_service public.services%ROWTYPE;
    v_duration INTEGER;
    v_price NUMERIC;
    v_end TIMESTAMPTZ;
    v_naive_from TIMESTAMP;
    v_naive_to TIMESTAMP;
    v_status TEXT := 'pending';
    v_advance INTEGER;
    v_max_days INTEGER;
    v_win public.galindo_service_window%ROWTYPE;
    v_appt public.appointments%ROWTYPE;
BEGIN
    IF v_customer IS NULL THEN
        RAISE EXCEPTION 'AUTH_REQUIRED: debes iniciar sesión para reservar.';
    END IF;

    -- Asegurar el perfil del cliente (el trigger lo crea normalmente)
    INSERT INTO public.profiles (id, email, full_name, role)
    VALUES (
        v_customer,
        COALESCE((SELECT email FROM auth.users WHERE id = v_customer), ''),
        COALESCE(
            NULLIF((SELECT raw_user_meta_data->>'full_name'
                    FROM auth.users WHERE id = v_customer), ''),
            'Cliente Galindo'),
        'client'
    )
    ON CONFLICT (id) DO NOTHING;

    -- Servicio y barbero válidos
    SELECT * INTO v_service FROM public.services
    WHERE id = p_service_id AND is_active = TRUE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'El servicio seleccionado no está disponible.';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM public.barbers
                   WHERE id = p_barber_id AND is_active = TRUE) THEN
        RAISE EXCEPTION 'El barbero seleccionado no está disponible.';
    END IF;

    SELECT COALESCE(bs.duration_minutes, v_service.duration_min),
           COALESCE(bs.price, v_service.price)
    INTO v_duration, v_price
    FROM public.barber_services bs
    WHERE bs.barber_id = p_barber_id AND bs.service_id = p_service_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'El barbero seleccionado no realiza el servicio solicitado.';
    END IF;

    v_end := p_starts_at + make_interval(mins => v_duration);
    v_naive_from := p_starts_at AT TIME ZONE 'America/Lima';
    v_naive_to   := v_end       AT TIME ZONE 'America/Lima';

    -- Configuración
    SELECT COALESCE(NULLIF(value, '')::INTEGER, 60) INTO v_advance
    FROM public.settings WHERE key = 'booking.min_advance_minutes';
    SELECT COALESCE(NULLIF(value, '')::INTEGER, 30) INTO v_max_days
    FROM public.settings WHERE key = 'booking.max_advance_days';
    v_advance  := COALESCE(v_advance, 60);
    v_max_days := COALESCE(v_max_days, 30);
    SELECT COALESCE(NULLIF(value, ''), 'pending') INTO v_status
    FROM public.settings WHERE key = 'booking.initial_status';
    IF v_status NOT IN ('pending', 'confirmed') THEN
        v_status := 'pending';
    END IF;

    -- Antelación mínima y rango máximo
    IF p_starts_at < now() + make_interval(mins => v_advance) THEN
        RAISE EXCEPTION 'SLOT_INVALID: falta antelación para reservar este horario.';
    END IF;
    IF v_naive_from::DATE > ((now() AT TIME ZONE 'America/Lima')::DATE
                             + v_max_days) THEN
        RAISE EXCEPTION 'SLOT_INVALID: la fecha está fuera del plazo de reserva.';
    END IF;

    -- Jornada de atención (general acotada por la del barbero)
    SELECT * INTO v_win FROM public.galindo_service_window(
        p_barber_id, EXTRACT(DOW FROM v_naive_from)::INTEGER);
    IF NOT v_win.o_is_open
       OR v_naive_from::TIME < v_win.o_open
       OR v_naive_to::TIME > v_win.o_close
       OR (v_win.o_break_from IS NOT NULL AND v_win.o_break_to IS NOT NULL
           AND v_naive_from::TIME < v_win.o_break_to
           AND v_naive_to::TIME > v_win.o_break_from) THEN
        RAISE EXCEPTION 'SLOT_INVALID: el horario está fuera de la jornada de atención.';
    END IF;

    -- Cita existente en ese horario (bloquea) o bloqueo/ausencia
    IF NOT public.galindo_slot_is_free(
            p_barber_id, v_naive_from, v_naive_to) THEN
        IF EXISTS (
            SELECT 1 FROM public.appointments a
            WHERE a.barber_id = p_barber_id
              AND a.status IN ('pending', 'confirmed', 'in_progress')
              AND tsrange(a.scheduled_start, a.scheduled_end, '[)')
                  && tsrange(v_naive_from, v_naive_to, '[)')
        ) THEN
            RAISE EXCEPTION 'SLOT_TAKEN: el horario acaba de ser reservado. Elige otro.';
        END IF;
        RAISE EXCEPTION 'SLOT_BLOCKED: el horario coincide con un cierre programado.';
    END IF;

    -- Insertar la cita
    INSERT INTO public.appointments (
        customer_id, barber_id, service_id, status,
        scheduled_start, scheduled_end, price, notes
    ) VALUES (
        v_customer, p_barber_id, p_service_id, v_status,
        v_naive_from, v_naive_to, v_price, p_notes
    )
    RETURNING * INTO v_appt;

    -- Evento de auditoría
    INSERT INTO public.appointment_events (
        appointment_id, event_type, "timestamp", created_by, notes
    ) VALUES (
        v_appt.id, 'created', now()::TIMESTAMP, v_customer,
        jsonb_build_object('source', 'web', 'status', v_status)
    );

    RETURN v_appt;
END;
$$;

-- ============================================================
-- 9. PERMISOS DE LAS FUNCIONES
-- ============================================================
REVOKE ALL ON FUNCTION public.get_available_slots(UUID, UUID, DATE) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_available_slots(UUID, UUID, DATE)
    TO anon, authenticated;

REVOKE ALL ON FUNCTION public.book_appointment(UUID, UUID, TIMESTAMPTZ, TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.book_appointment(UUID, UUID, TIMESTAMPTZ, TEXT)
    TO authenticated;

-- Los helpers solo se usan dentro de las RPCs (SECURITY DEFINER)
REVOKE ALL ON FUNCTION public.galindo_service_window(UUID, INTEGER) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.galindo_slot_is_free(UUID, TIMESTAMP, TIMESTAMP) FROM PUBLIC;

COMMIT;

-- ============================================================
-- VERIFICACIÓN (ejecutar aparte, tras aplicar)
--   SELECT * FROM public.get_available_slots(
--       (SELECT id FROM public.services ORDER BY sort_order LIMIT 1),
--       (SELECT id FROM public.barbers   ORDER BY sort_order LIMIT 1),
--       (now() AT TIME ZONE 'America/Lima')::DATE + 1);
-- ============================================================
