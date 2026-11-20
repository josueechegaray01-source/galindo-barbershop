-- ============================================
-- MIGRACIÓN 008: Funciones RPC y Triggers de Negocio
-- ============================================
-- book_appointment, get_available_slots, triggers para nuevos usuarios, etc.
-- ============================================

-- --------------------------------------------
-- 1. TRIGGER: NUEVO USUARIO EN AUTH -> CREAR PERFIL Y PREFERENCIAS
-- --------------------------------------------
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    _full_name VARCHAR;
    _phone VARCHAR;
    _role VARCHAR;
BEGIN
    -- Extraer metadatos enviados en auth.signUp
    _full_name := COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', 'Cliente Galindo');
    _phone := NEW.raw_user_meta_data->>'phone';
    _role := COALESCE(NEW.raw_user_meta_data->>'role', 'client');

    -- Validar que rol sea válido (cliente por defecto si intentan inyectar admin)
    IF _role NOT IN ('client', 'barber', 'receptionist') THEN
        _role := 'client';
    END IF;

    -- Insertar en profiles
    INSERT INTO public.profiles (id, full_name, phone, role, is_active)
    VALUES (NEW.id, _full_name, _phone, _role, TRUE)
    ON CONFLICT (id) DO NOTHING;

    -- Si es cliente, insertar en customers
    IF _role = 'client' THEN
        INSERT INTO public.customers (profile_id)
        VALUES (NEW.id)
        ON CONFLICT (profile_id) DO NOTHING;
    END IF;

    -- Crear preferencias de notificación por defecto
    INSERT INTO public.notification_preferences (profile_id)
    VALUES (NEW.id)
    ON CONFLICT (profile_id) DO NOTHING;

    RETURN NEW;
END;
$$;

-- Asociar trigger a auth.users
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

COMMENT ON FUNCTION public.handle_new_user() IS 'Crea automáticamente profile, customer y notification_preferences cuando un usuario se registra en Supabase Auth.';


-- --------------------------------------------
-- 2. FUNCIÓN RPC: CALCULAR FRANJAS DISPONIBLES (SLOTS)
-- --------------------------------------------
CREATE OR REPLACE FUNCTION public.get_available_slots(
    p_service_id UUID,
    p_barber_id UUID,
    p_date DATE
)
RETURNS TABLE (
    slot_start TIMESTAMPTZ,
    slot_end TIMESTAMPTZ,
    is_available BOOLEAN
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    _service_duration INTEGER;
    _service_buffer INTEGER;
    _total_duration INTEGER;
    _weekday SMALLINT;
    _is_open BOOLEAN;
    _start_time TIME;
    _end_time TIME;
    _break_start TIME;
    _break_end TIME;
    _is_break_active BOOLEAN;
    _current_time TIME;
    _slot_start_dt TIMESTAMPTZ;
    _slot_end_dt TIMESTAMPTZ;
    _slot_interval INTEGER;
    _min_advance_hours INTEGER;
    _max_advance_days INTEGER;
    _now TIMESTAMPTZ := NOW();
    _date_start TIMESTAMPTZ;
    _date_end TIMESTAMPTZ;
BEGIN
    -- 1. Obtener duración y buffer del servicio
    SELECT duration_min, buffer_min INTO _service_duration, _service_buffer
    FROM public.services
    WHERE id = p_service_id AND is_active = TRUE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Servicio no encontrado o inactivo';
    END IF;

    -- Verificar que el barbero realiza este servicio
    IF NOT EXISTS (
        SELECT 1 FROM public.barber_services
        WHERE barber_id = p_barber_id AND service_id = p_service_id AND is_active = TRUE
    ) THEN
        RAISE EXCEPTION 'El barbero seleccionado no realiza este servicio';
    END IF;

    -- Aplicar override de duración si existe
    SELECT COALESCE(duration_override_min, _service_duration) INTO _service_duration
    FROM public.barber_services
    WHERE barber_id = p_barber_id AND service_id = p_service_id;

    _total_duration := _service_duration + _service_buffer;

    -- 2. Obtener configuraciones globales
    SELECT (value::text)::integer INTO _slot_interval FROM public.settings WHERE key = 'booking.slot_interval_min';
    SELECT (value::text)::integer INTO _min_advance_hours FROM public.settings WHERE key = 'booking.min_advance_hours';
    SELECT (value::text)::integer INTO _max_advance_days FROM public.settings WHERE key = 'booking.max_advance_days';

    _slot_interval := COALESCE(_slot_interval, 30);
    _min_advance_hours := COALESCE(_min_advance_hours, 1);
    _max_advance_days := COALESCE(_max_advance_days, 30);

    -- Validar fecha solicitada
    IF p_date < CURRENT_DATE OR p_date > (CURRENT_DATE + (_max_advance_days || ' days')::INTERVAL) THEN
        RETURN; -- Fuera de rango permitido
    END IF;

    -- 3. Obtener horario del barbero para el día de la semana (0=Dom, 6=Sáb)
    _weekday := EXTRACT(DOW FROM p_date);

    -- Buscar horario individual del barbero
    SELECT is_open, start_time, end_time, break_start, break_end, is_break_active
    INTO _is_open, _start_time, _end_time, _break_start, _break_end, _is_break_active
    FROM public.barber_hours
    WHERE barber_id = p_barber_id AND weekday = _weekday;

    -- Si no tiene horario individual, usar horario general del negocio
    IF NOT FOUND THEN
        SELECT is_open, start_time, end_time, break_start, break_end, is_break_active
        INTO _is_open, _start_time, _end_time, _break_start, _break_end, _is_break_active
        FROM public.business_hours
        WHERE weekday = _weekday;
    END IF;

    -- Si el local/barbero está cerrado ese día, retornar vacío
    IF NOT FOUND OR NOT _is_open THEN
        RETURN;
    END IF;

    -- 4. Iterar generando franjas desde _start_time hasta _end_time - _total_duration
    _current_time := _start_time;
    _date_start := (p_date || ' 00:00:00')::TIMESTAMPTZ AT TIME ZONE 'America/Lima';

    WHILE (_current_time + (_total_duration || ' minutes')::INTERVAL)::TIME <= _end_time LOOP
        _slot_start_dt := (p_date || ' ' || _current_time)::TIMESTAMPTZ AT TIME ZONE 'America/Lima';
        _slot_end_dt := _slot_start_dt + (_total_duration || ' minutes')::INTERVAL;

        -- Verificar si está en horario de descanso (break)
        IF _is_break_active AND _break_start IS NOT NULL AND _break_end IS NOT NULL THEN
            IF _current_time >= _break_start AND _current_time < _break_end THEN
                -- Saltar al fin del descanso
                _current_time := _break_end;
                CONTINUE;
            END IF;
            -- Verificar si el slot solapa con el descanso
            IF _current_time < _break_start AND (_current_time + (_total_duration || ' minutes')::INTERVAL)::TIME > _break_start THEN
                _current_time := _break_end;
                CONTINUE;
            END IF;
        END IF;

        -- Verificar antelación mínima (no reservar en el pasado o muy pronto)
        IF _slot_start_dt > (_now + (_min_advance_hours || ' hours')::INTERVAL) THEN
            
            -- Verificar si hay solapamiento con citas existentes (pendientes, confirmadas, en_curso)
            -- o con bloques de horario (schedule_blocks)
            IF NOT EXISTS (
                SELECT 1 FROM public.appointments a
                WHERE a.barber_id = p_barber_id
                  AND a.status IN ('pending', 'confirmed', 'in_progress')
                  AND tsrange(a.starts_at, a.ends_at) && tsrange(_slot_start_dt, _slot_end_dt)
            ) AND NOT EXISTS (
                SELECT 1 FROM public.schedule_blocks sb
                WHERE (sb.barber_id = p_barber_id OR sb.barber_id IS NULL)
                  AND tsrange(sb.starts_at, sb.ends_at) && tsrange(_slot_start_dt, _slot_end_dt)
            ) THEN
                slot_start := _slot_start_dt;
                slot_end := _slot_end_dt;
                is_available := TRUE;
                RETURN NEXT;
            END IF;
        END IF;

        -- Avanzar al siguiente slot según intervalo configurado
        _current_time := (_current_time + (_slot_interval || ' minutes')::INTERVAL)::TIME;
    END LOOP;

    RETURN;
END;
$$;

COMMENT ON FUNCTION public.get_available_slots IS 'Calcula franjas horarias disponibles para un servicio, barbero y fecha, respetando horarios, descansos, bloqueos y citas existentes.';


-- --------------------------------------------
-- 3. FUNCIÓN RPC: RESERVAR CITA (ATÓMICA Y SEGURA)
-- --------------------------------------------
CREATE OR REPLACE FUNCTION public.book_appointment(
    p_service_id UUID,
    p_barber_id UUID,
    p_starts_at TIMESTAMPTZ,
    p_note TEXT DEFAULT NULL,
    p_idempotency_key VARCHAR DEFAULT NULL
)
RETURNS public.appointments
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    _customer_id UUID;
    _service RECORD;
    _barber RECORD;
    _duration_min INTEGER;
    _ends_at TIMESTAMPTZ;
    _initial_status public.appointment_status;
    _new_appointment public.appointments;
    _pending_blocks BOOLEAN;
    _confirmed_blocks BOOLEAN;
BEGIN
    -- 1. Obtener customer_id del usuario autenticado
    _customer_id := auth.uid();
    IF _customer_id IS NULL THEN
        RAISE EXCEPTION 'No autorizado. Debe iniciar sesión para reservar.';
    END IF;

    -- Verificar que el usuario sea cliente
    IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = _customer_id AND role = 'client' AND is_active = TRUE) THEN
        -- Si es admin/receptionist reservando para un cliente, permitir (futuro), pero por ahora solo clients
        IF NOT public.is_staff() THEN
            RAISE EXCEPTION 'Solo los clientes pueden crear reservas mediante esta función.';
        END IF;
    END IF;

    -- 2. Si hay idempotency_key, verificar si ya existe una cita con esa clave
    IF p_idempotency_key IS NOT NULL THEN
        SELECT * INTO _new_appointment FROM public.appointments WHERE idempotency_key = p_idempotency_key;
        IF FOUND THEN
            RETURN _new_appointment; -- Operación idempotente: retorna la cita existente
        END IF;
    END IF;

    -- 3. Obtener y validar servicio
    SELECT * INTO _service FROM public.services WHERE id = p_service_id AND is_active = TRUE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'El servicio seleccionado no existe o no está activo.';
    END IF;

    -- 4. Obtener y validar barbero
    SELECT * INTO _barber FROM public.barbers WHERE id = p_barber_id AND is_active = TRUE;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'El barbero seleccionado no existe o no está disponible.';
    END IF;

    -- Verificar asignación barbero-servicio
    IF NOT EXISTS (
        SELECT 1 FROM public.barber_services
        WHERE barber_id = p_barber_id AND service_id = p_service_id AND is_active = TRUE
    ) THEN
        RAISE EXCEPTION 'El barbero seleccionado no realiza el servicio solicitado.';
    END IF;

    -- Obtener duración (con override si existe)
    SELECT COALESCE(duration_override_min, _service.duration_min) INTO _duration_min
    FROM public.barber_services
    WHERE barber_id = p_barber_id AND service_id = p_service_id;

    _ends_at := p_starts_at + (_duration_min || ' minutes')::INTERVAL;

    -- 5. Validar estado inicial configurado
    SELECT (value::text)::public.appointment_status INTO _initial_status FROM public.settings WHERE key = 'booking.initial_status';
    _initial_status := COALESCE(_initial_status, 'pending');

    -- 6. Verificaciones de concurrencia y solapamiento
    -- Nota: La restricción Exclusion GiST ya protege contra doble reserva a nivel DB,
    -- pero hacemos la comprobación explícita para dar un mensaje de error claro al usuario.
    SELECT (value::text)::boolean INTO _pending_blocks FROM public.settings WHERE key = 'booking.pending_blocks_availability';
    SELECT (value::text)::boolean INTO _confirmed_blocks FROM public.settings WHERE key = 'booking.confirmed_blocks_availability';

    IF EXISTS (
        SELECT 1 FROM public.appointments a
        WHERE a.barber_id = p_barber_id
          AND a.status IN ('pending', 'confirmed', 'in_progress')
          AND tsrange(a.starts_at, a.ends_at) && tsrange(p_starts_at, _ends_at)
    ) THEN
        RAISE EXCEPTION 'El horario seleccionado ya no está disponible. Por favor elija otro horario.';
    END IF;

    -- Verificar bloques de horario
    IF EXISTS (
        SELECT 1 FROM public.schedule_blocks sb
        WHERE (sb.barber_id = p_barber_id OR sb.barber_id IS NULL)
          AND tsrange(sb.starts_at, sb.ends_at) && tsrange(p_starts_at, _ends_at)
    ) THEN
        RAISE EXCEPTION 'El horario seleccionado coincide con un bloqueo o cierre programado.';
    END IF;

    -- 7. Insertar cita con snapshots inmutables
    INSERT INTO public.appointments (
        customer_id,
        barber_id,
        service_id,
        starts_at,
        ends_at,
        status,
        price_snapshot,
        duration_snapshot_min,
        service_name_snapshot,
        barber_name_snapshot,
        notes,
        source,
        idempotency_key
    ) VALUES (
        _customer_id,
        p_barber_id,
        p_service_id,
        p_starts_at,
        _ends_at,
        _initial_status,
        _service.price,
        _duration_min,
        _service.name,
        _barber.display_name,
        p_note,
        'app',
        p_idempotency_key
    )
    RETURNING * INTO _new_appointment;

    -- 8. Registrar evento de auditoría en appointment_events
    INSERT INTO public.appointment_events (
        appointment_id,
        old_status,
        new_status,
        actor_id,
        actor_role,
        reason
    ) VALUES (
        _new_appointment.id,
        NULL,
        _initial_status,
        _customer_id,
        'client',
        'Reserva creada por el cliente'
    );

    RETURN _new_appointment;
END;
$$;

COMMENT ON FUNCTION public.book_appointment IS 'Función transaccional atómica para reservar citas. Valida disponibilidad, asignación, solapamientos, crea snapshots inmutables y registra evento de auditoría.';


-- --------------------------------------------
-- 4. FUNCIÓN RPC: CANCELAR CITA
-- --------------------------------------------
CREATE OR REPLACE FUNCTION public.cancel_appointment(
    p_appointment_id UUID,
    p_reason TEXT DEFAULT NULL
)
RETURNS public.appointments
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    _appointment public.appointments;
    _actor_id UUID;
    _actor_role VARCHAR;
    _min_cancel_hours NUMERIC;
    _hours_until_start NUMERIC;
    _allow_client_cancel BOOLEAN;
BEGIN
    _actor_id := auth.uid();
    IF _actor_id IS NULL THEN
        RAISE EXCEPTION 'No autorizado.';
    END IF;

    SELECT role INTO _actor_role FROM public.profiles WHERE id = _actor_id;

    -- Obtener cita
    SELECT * INTO _appointment FROM public.appointments WHERE id = p_appointment_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Cita no encontrada.';
    END IF;

    -- Verificar permisos (propietario de la cita, barbero asignado o staff)
    IF _actor_role = 'client' AND _appointment.customer_id <> _actor_id THEN
        RAISE EXCEPTION 'No tiene permiso para cancelar esta cita.';
    END IF;

    IF _actor_role = 'barber' AND _appointment.barber_id <> public.get_my_barber_id() THEN
        RAISE EXCEPTION 'No tiene permiso para cancelar esta cita.';
    END IF;

    -- Verificar si ya está cancelada o completada
    IF _appointment.status IN ('cancelled', 'completed') THEN
        RAISE EXCEPTION 'La cita ya se encuentra %.', _appointment.status;
    END IF;

    -- Si es cliente, verificar política de anticipación y permisos
    IF _actor_role = 'client' THEN
        SELECT (value::text)::boolean INTO _allow_client_cancel FROM public.settings WHERE key = 'booking.allow_client_cancel';
        IF NOT COALESCE(_allow_client_cancel, TRUE) THEN
            RAISE EXCEPTION 'Las cancelaciones por parte del cliente están desactivadas. Contacte al establecimiento.';
        END IF;

        SELECT (value::text)::numeric INTO _min_cancel_hours FROM public.settings WHERE key = 'booking.min_cancel_hours';
        _min_cancel_hours := COALESCE(_min_cancel_hours, 2);

        _hours_until_start := EXTRACT(EPOCH FROM (_appointment.starts_at - NOW())) / 3600;

        IF _hours_until_start < _min_cancel_hours THEN
            RAISE EXCEPTION 'No es posible cancelar con menos de % horas de anticipación. Contacte al establecimiento.', _min_cancel_hours;
        END IF;
    END IF;

    -- Actualizar estado de la cita
    UPDATE public.appointments
    SET status = 'cancelled',
        cancellation_reason = p_reason,
        cancelled_by = _actor_id,
        cancelled_at = NOW(),
        updated_at = NOW()
    WHERE id = p_appointment_id
    RETURNING * INTO _appointment;

    -- Registrar evento de auditoría
    INSERT INTO public.appointment_events (
        appointment_id,
        old_status,
        new_status,
        actor_id,
        actor_role,
        reason
    ) VALUES (
        p_appointment_id,
        _appointment.status,
        'cancelled',
        _actor_id,
        _actor_role,
        COALESCE(p_reason, 'Cita cancelada')
    );

    RETURN _appointment;
END;
$$;

COMMENT ON FUNCTION public.cancel_appointment IS 'Cancela una cita validando políticas de anticipación y permisos. Libera automáticamente el intervalo gracias a la condición de exclusión GiST.';


-- --------------------------------------------
-- 5. FUNCIÓN RPC: ACTUALIZAR ESTADO DE CITA (PARA STAFF / BARBERO)
-- --------------------------------------------
CREATE OR REPLACE FUNCTION public.update_appointment_status(
    p_appointment_id UUID,
    p_new_status public.appointment_status,
    p_reason TEXT DEFAULT NULL
)
RETURNS public.appointments
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    _appointment public.appointments;
    _actor_id UUID;
    _actor_role VARCHAR;
    _old_status public.appointment_status;
BEGIN
    _actor_id := auth.uid();
    IF _actor_id IS NULL THEN
        RAISE EXCEPTION 'No autorizado.';
    END IF;

    SELECT role INTO _actor_role FROM public.profiles WHERE id = _actor_id;

    -- Obtener cita actual
    SELECT * INTO _appointment FROM public.appointments WHERE id = p_appointment_id;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Cita no encontrada.';
    END IF;

    _old_status := _appointment.status;

    -- Validar permisos por rol
    IF _actor_role = 'client' THEN
        RAISE EXCEPTION 'Los clientes no pueden cambiar estados directamente.';
    END IF;

    IF _actor_role = 'barber' AND _appointment.barber_id <> public.get_my_barber_id() THEN
        RAISE EXCEPTION 'El barbero solo puede actualizar sus propias citas asignadas.';
    END IF;

    IF NOT public.is_staff() AND _actor_role <> 'barber' THEN
        RAISE EXCEPTION 'No tiene permisos para actualizar estados de citas.';
    END IF;

    -- Validar transiciones permitidas según rol
    IF _actor_role = 'barber' AND p_new_status NOT IN ('in_progress', 'completed', 'no_show') THEN
        RAISE EXCEPTION 'Los barberos solo pueden cambiar el estado a en atención, atendida o no presentado.';
    END IF;

    -- Actualizar estado
    UPDATE public.appointments
    SET status = p_new_status,
        confirmed_by = CASE WHEN p_new_status = 'confirmed' THEN _actor_id ELSE confirmed_by END,
        confirmed_at = CASE WHEN p_new_status = 'confirmed' AND confirmed_at IS NULL THEN NOW() ELSE confirmed_at END,
        completed_at = CASE WHEN p_new_status = 'completed' THEN NOW() ELSE completed_at END,
        updated_at = NOW()
    WHERE id = p_appointment_id
    RETURNING * INTO _appointment;

    -- Registrar evento de auditoría
    INSERT INTO public.appointment_events (
        appointment_id,
        old_status,
        new_status,
        actor_id,
        actor_role,
        reason
    ) VALUES (
        p_appointment_id,
        _old_status,
        p_new_status,
        _actor_id,
        _actor_role,
        COALESCE(p_reason, 'Actualización de estado por staff/barbero')
    );

    RETURN _appointment;
END;
$$;

COMMENT ON FUNCTION public.update_appointment_status IS 'Actualiza el estado de una cita con validación de roles y registro de auditoría en appointment_events.';