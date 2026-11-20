-- ============================================
-- MIGRACIÓN 007: Row Level Security (RLS) Policies
-- ============================================
-- Seguridad a nivel de fila para todas las tablas expuestas
-- ============================================

-- --------------------------------------------
-- HABILITAR RLS EN TODAS LAS TABLAS
-- --------------------------------------------
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.barbers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.barber_services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.business_hours ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.barber_hours ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.schedule_blocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.appointment_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.walk_ins ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loyalty_programs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loyalty_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notification_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.barber_attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.barber_absences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.audit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.settings ENABLE ROW LEVEL SECURITY;

-- --------------------------------------------
-- FUNCIONES AUXILIARES PARA POLÍTICAS
-- --------------------------------------------

-- Obtener rol del usuario actual desde profiles
CREATE OR REPLACE FUNCTION public.get_my_role()
RETURNS VARCHAR
LANGUAGE sql
STABLE
SECURITY INVOKER
AS $$
    SELECT role FROM public.profiles WHERE id = auth.uid();
$$;

-- Verificar si el usuario actual es admin/owner/receptionist
CREATE OR REPLACE FUNCTION public.is_staff()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY INVOKER
AS $$
    SELECT role IN ('admin', 'owner', 'receptionist') FROM public.profiles WHERE id = auth.uid();
$$;

-- Verificar si el usuario actual es barbero
CREATE OR REPLACE FUNCTION public.is_barber()
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY INVOKER
AS $$
    SELECT role = 'barber' FROM public.profiles WHERE id = auth.uid();
$$;

-- Obtener barber_id del usuario actual (si es barbero)
CREATE OR REPLACE FUNCTION public.get_my_barber_id()
RETURNS UUID
LANGUAGE sql
STABLE
SECURITY INVOKER
AS $$
    SELECT id FROM public.barbers WHERE profile_id = auth.uid() AND is_active = TRUE;
$$;

-- Verificar si el usuario actual es el propietario del customer_id
CREATE OR REPLACE FUNCTION public.is_my_customer(customer_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY INVOKER
AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.customers
        WHERE profile_id = customer_uuid
        AND profile_id = auth.uid()
    );
$$;

-- --------------------------------------------
-- POLÍTICAS: PROFILES
-- --------------------------------------------
-- Usuario ve su propio perfil
CREATE POLICY "profiles_select_own" ON public.profiles
    FOR SELECT USING (id = auth.uid());

-- Staff ve todos los perfiles
CREATE POLICY "profiles_select_staff" ON public.profiles
    FOR SELECT USING (public.is_staff());

-- Usuario actualiza su propio perfil (excepto role)
CREATE POLICY "profiles_update_own" ON public.profiles
    FOR UPDATE USING (id = auth.uid())
    WITH CHECK (id = auth.uid() AND role = (SELECT role FROM public.profiles WHERE id = auth.uid()));

-- Staff actualiza cualquier perfil
CREATE POLICY "profiles_update_staff" ON public.profiles
    FOR UPDATE USING (public.is_staff())
    WITH CHECK (public.is_staff());

-- Inserción solo via trigger de auth (no directo)
CREATE POLICY "profiles_insert_trigger" ON public.profiles
    FOR INSERT WITH CHECK (false); -- Solo via trigger handle_new_user()

-- --------------------------------------------
-- POLÍTICAS: CUSTOMERS
-- --------------------------------------------
-- Cliente ve su propio registro
CREATE POLICY "customers_select_own" ON public.customers
    FOR SELECT USING (profile_id = auth.uid());

-- Staff ve todos los clientes
CREATE POLICY "customers_select_staff" ON public.customers
    FOR SELECT USING (public.is_staff());

-- Cliente actualiza su propio registro
CREATE POLICY "customers_update_own" ON public.customers
    FOR UPDATE USING (profile_id = auth.uid())
    WITH CHECK (profile_id = auth.uid());

-- Staff actualiza cualquier cliente
CREATE POLICY "customers_update_staff" ON public.customers
    FOR UPDATE USING (public.is_staff())
    WITH CHECK (public.is_staff());

-- Inserción solo via trigger/registro
CREATE POLICY "customers_insert_trigger" ON public.customers
    FOR INSERT WITH CHECK (false);

-- --------------------------------------------
-- POLÍTICAS: BARBERS (Catálogo público + gestión staff)
-- --------------------------------------------
-- Público: ver barberos activos
CREATE POLICY "barbers_select_public" ON public.barbers
    FOR SELECT USING (is_active = TRUE);

-- Staff: ver todos (incluyendo inactivos)
CREATE POLICY "barbers_select_staff" ON public.barbers
    FOR SELECT USING (public.is_staff());

-- Barbero ve su propio perfil completo
CREATE POLICY "barbers_select_own" ON public.barbers
    FOR SELECT USING (profile_id = auth.uid());

-- Staff gestiona barberos
CREATE POLICY "barbers_modify_staff" ON public.barbers
    FOR ALL USING (public.is_staff())
    WITH CHECK (public.is_staff());

-- --------------------------------------------
-- POLÍTICAS: SERVICES (Catálogo público + gestión staff)
-- --------------------------------------------
-- Público: ver servicios activos y públicos
CREATE POLICY "services_select_public" ON public.services
    FOR SELECT USING (is_active = TRUE AND is_public = TRUE);

-- Staff: ver todos los servicios
CREATE POLICY "services_select_staff" ON public.services
    FOR SELECT USING (public.is_staff());

-- Staff gestiona servicios
CREATE POLICY "services_modify_staff" ON public.services
    FOR ALL USING (public.is_staff())
    WITH CHECK (public.is_staff());

-- --------------------------------------------
-- POLÍTICAS: BARBER_SERVICES
-- --------------------------------------------
-- Público: ver asignaciones activas (para catálogo)
CREATE POLICY "barber_services_select_public" ON public.barber_services
    FOR SELECT USING (
        is_active = TRUE
        AND EXISTS (SELECT 1 FROM public.barbers WHERE id = barber_id AND is_active = TRUE)
        AND EXISTS (SELECT 1 FROM public.services WHERE id = service_id AND is_active = TRUE AND is_public = TRUE)
    );

-- Staff: ver todas
CREATE POLICY "barber_services_select_staff" ON public.barber_services
    FOR SELECT USING (public.is_staff());

-- Barbero ve sus propias asignaciones
CREATE POLICY "barber_services_select_own" ON public.barber_services
    FOR SELECT USING (barber_id = public.get_my_barber_id());

-- Staff gestiona asignaciones
CREATE POLICY "barber_services_modify_staff" ON public.barber_services
    FOR ALL USING (public.is_staff())
    WITH CHECK (public.is_staff());

-- --------------------------------------------
-- POLÍTICAS: BUSINESS_HOURS
-- --------------------------------------------
-- Público: ver horarios generales (para mostrar en UI)
CREATE POLICY "business_hours_select_public" ON public.business_hours
    FOR SELECT USING (TRUE);

-- Staff: gestionar
CREATE POLICY "business_hours_modify_staff" ON public.business_hours
    FOR ALL USING (public.is_staff())
    WITH CHECK (public.is_staff());

-- --------------------------------------------
-- POLÍTICAS: BARBER_HOURS
-- --------------------------------------------
-- Público: ver horarios de barberos activos
CREATE POLICY "barber_hours_select_public" ON public.barber_hours
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM public.barbers WHERE id = barber_id AND is_active = TRUE)
    );

-- Staff: ver y gestionar todos
CREATE POLICY "barber_hours_select_staff" ON public.barber_hours
    FOR SELECT USING (public.is_staff());

CREATE POLICY "barber_hours_modify_staff" ON public.barber_hours
    FOR ALL USING (public.is_staff())
    WITH CHECK (public.is_staff());

-- Barbero ve/gestiona sus propios horarios
CREATE POLICY "barber_hours_modify_own" ON public.barber_hours
    FOR ALL USING (barber_id = public.get_my_barber_id())
    WITH CHECK (barber_id = public.get_my_barber_id());

-- --------------------------------------------
-- POLÍTICAS: SCHEDULE_BLOCKS
-- --------------------------------------------
-- Público: ver bloques que afectan disponibilidad (para cálculo slots)
CREATE POLICY "schedule_blocks_select_public" ON public.schedule_blocks
    FOR SELECT USING (
        (barber_id IS NULL OR EXISTS (SELECT 1 FROM public.barbers WHERE id = barber_id AND is_active = TRUE))
        AND ends_at > NOW()
    );

-- Staff: ver y gestionar todos
CREATE POLICY "schedule_blocks_select_staff" ON public.schedule_blocks
    FOR SELECT USING (public.is_staff());

CREATE POLICY "schedule_blocks_modify_staff" ON public.schedule_blocks
    FOR ALL USING (public.is_staff())
    WITH CHECK (public.is_staff());

-- Barbero ve/gestiona sus propios bloques
CREATE POLICY "schedule_blocks_modify_own" ON public.schedule_blocks
    FOR ALL USING (barber_id = public.get_my_barber_id())
    WITH CHECK (barber_id = public.get_my_barber_id());

-- --------------------------------------------
-- POLÍTICAS: APPOINTMENTS (CRÍTICO - propiedad y roles)
-- --------------------------------------------
-- Cliente: ve SUS citas
CREATE POLICY "appointments_select_own" ON public.appointments
    FOR SELECT USING (customer_id = auth.uid());

-- Barbero: ve citas asignadas a ÉL
CREATE POLICY "appointments_select_barber" ON public.appointments
    FOR SELECT USING (barber_id = public.get_my_barber_id());

-- Staff: ve TODAS las citas
CREATE POLICY "appointments_select_staff" ON public.appointments
    FOR SELECT USING (public.is_staff());

-- Cliente: crea sus citas (validado por RPC book_appointment)
CREATE POLICY "appointments_insert_client" ON public.appointments
    FOR INSERT WITH CHECK (
        customer_id = auth.uid()
        AND status = (SELECT value::text FROM public.settings WHERE key = 'booking.initial_status')
        AND source IN ('app', 'phone', 'whatsapp')
    );

-- Staff: crea citas (admin panel, phone, walk_in conversion)
CREATE POLICY "appointments_insert_staff" ON public.appointments
    FOR INSERT WITH CHECK (public.is_staff());

-- Cliente: actualiza SUS citas (solo cancel/reprogramar vía RPC)
CREATE POLICY "appointments_update_own" ON public.appointments
    FOR UPDATE USING (customer_id = auth.uid())
    WITH CHECK (
        customer_id = auth.uid()
        AND status IN ('cancelled', 'rescheduled') -- solo transiciones permitidas al cliente
        AND cancelled_by IS NULL OR cancelled_by = auth.uid()
    );

-- Barbero: actualiza estado de SUS citas (vía RPC update_appointment_status)
CREATE POLICY "appointments_update_barber" ON public.appointments
    FOR UPDATE USING (barber_id = public.get_my_barber_id())
    WITH CHECK (
        barber_id = public.get_my_barber_id()
        AND status IN ('in_progress', 'completed', 'no_show')
    );

-- Staff: actualiza cualquier cita
CREATE POLICY "appointments_update_staff" ON public.appointments
    FOR UPDATE USING (public.is_staff())
    WITH CHECK (public.is_staff());

-- NO DELETE: citas nunca se borran, solo cambian estado a cancelled
CREATE POLICY "appointments_delete_none" ON public.appointments
    FOR DELETE USING (false);

-- --------------------------------------------
-- POLÍTICAS: APPOINTMENT_EVENTS (Auditoría)
-- --------------------------------------------
-- Cliente: ve eventos de SUS citas
CREATE POLICY "appointment_events_select_own" ON public.appointment_events
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM public.appointments WHERE id = appointment_id AND customer_id = auth.uid())
    );

-- Barbero: ve eventos de SUS citas
CREATE POLICY "appointment_events_select_barber" ON public.appointment_events
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM public.appointments WHERE id = appointment_id AND barber_id = public.get_my_barber_id())
    );

-- Staff: ve todos los eventos
CREATE POLICY "appointment_events_select_staff" ON public.appointment_events
    FOR SELECT USING (public.is_staff());

-- Inserción solo via RPC/trigger (no directo)
CREATE POLICY "appointment_events_insert_system" ON public.appointment_events
    FOR INSERT WITH CHECK (false);

-- NO UPDATE/DELETE: eventos son inmutables
CREATE POLICY "appointment_events_no_modify" ON public.appointment_events
    FOR UPDATE USING (false);
CREATE POLICY "appointment_events_no_delete" ON public.appointment_events
    FOR DELETE USING (false);

-- --------------------------------------------
-- POLÍTICAS: WALK_INS
-- --------------------------------------------
-- Barbero: ve sus walk-ins
CREATE POLICY "walk_ins_select_barber" ON public.walk_ins
    FOR SELECT USING (barber_id = public.get_my_barber_id());

-- Staff: ve todos
CREATE POLICY "walk_ins_select_staff" ON public.walk_ins
    FOR SELECT USING (public.is_staff());

-- Staff/Barbero: crear walk-ins
CREATE POLICY "walk_ins_insert_staff_barber" ON public.walk_ins
    FOR INSERT WITH CHECK (
        public.is_staff() OR barber_id = public.get_my_barber_id()
    );

-- Staff/Barbero: actualizar
CREATE POLICY "walk_ins_update_staff_barber" ON public.walk_ins
    FOR UPDATE USING (
        public.is_staff() OR barber_id = public.get_my_barber_id()
    )
    WITH CHECK (
        public.is_staff() OR barber_id = public.get_my_barber_id()
    );

-- --------------------------------------------
-- POLÍTICAS: PAYMENTS
-- --------------------------------------------
-- Cliente: ve SUS pagos
CREATE POLICY "payments_select_own" ON public.payments
    FOR SELECT USING (customer_id = auth.uid());

-- Barbero: ve pagos de SUS citas
CREATE POLICY "payments_select_barber" ON public.payments
    FOR SELECT USING (
        EXISTS (SELECT 1 FROM public.appointments WHERE id = appointment_id AND barber_id = public.get_my_barber_id())
        OR EXISTS (SELECT 1 FROM public.walk_ins WHERE id = walk_in_id AND barber_id = public.get_my_barber_id())
    );

-- Staff: ve todos
CREATE POLICY "payments_select_staff" ON public.payments
    FOR SELECT USING (public.is_staff());

-- Staff/Barbero: crear pagos
CREATE POLICY "payments_insert_staff_barber" ON public.payments
    FOR INSERT WITH CHECK (public.is_staff() OR barber_id = public.get_my_barber_id());

-- Staff: confirmar pagos
CREATE POLICY "payments_update_staff" ON public.payments
    FOR UPDATE USING (public.is_staff())
    WITH CHECK (public.is_staff());

-- --------------------------------------------
-- POLÍTICAS: LOYALTY
-- --------------------------------------------
-- Público: ver programa activo
CREATE POLICY "loyalty_programs_select_public" ON public.loyalty_programs
    FOR SELECT USING (is_active = TRUE);

-- Staff: gestionar
CREATE POLICY "loyalty_programs_modify_staff" ON public.loyalty_programs
    FOR ALL USING (public.is_staff())
    WITH CHECK (public.is_staff());

-- Cliente: ve SUS transacciones
CREATE POLICY "loyalty_transactions_select_own" ON public.loyalty_transactions
    FOR SELECT USING (customer_id = auth.uid());

-- Staff: ve todas
CREATE POLICY "loyalty_transactions_select_staff" ON public.loyalty_transactions
    FOR SELECT USING (public.is_staff());

-- Inserción solo via RPC/trigger
CREATE POLICY "loyalty_transactions_insert_system" ON public.loyalty_transactions
    FOR INSERT WITH CHECK (false);

-- --------------------------------------------
-- POLÍTICAS: REVIEWS
-- --------------------------------------------
-- Público: ver reseñas públicas
CREATE POLICY "reviews_select_public" ON public.reviews
    FOR SELECT USING (is_public = TRUE);

-- Cliente: ve SUS reseñas (incluyendo privadas)
CREATE POLICY "reviews_select_own" ON public.reviews
    FOR SELECT USING (customer_id = auth.uid());

-- Barbero: ve reseñas SUYAS
CREATE POLICY "reviews_select_barber" ON public.reviews
    FOR SELECT USING (barber_id = public.get_my_barber_id());

-- Staff: ve todas
CREATE POLICY "reviews_select_staff" ON public.reviews
    FOR SELECT USING (public.is_staff());

-- Cliente: crea reseña de SU cita completada
CREATE POLICY "reviews_insert_client" ON public.reviews
    FOR INSERT WITH CHECK (
        customer_id = auth.uid()
        AND is_verified = TRUE
        AND EXISTS (
            SELECT 1 FROM public.appointments
            WHERE id = appointment_id
            AND customer_id = auth.uid()
            AND status = 'completed'
        )
    );

-- Barbero/Staff: responder reseña
CREATE POLICY "reviews_update_barber_staff" ON public.reviews
    FOR UPDATE USING (
        barber_id = public.get_my_barber_id() OR public.is_staff()
    )
    WITH CHECK (
        barber_id = public.get_my_barber_id() OR public.is_staff()
        AND responded_by = auth.uid()
    );

-- --------------------------------------------
-- POLÍTICAS: NOTIFICATIONS
-- --------------------------------------------
-- Usuario: ve SUS notificaciones
CREATE POLICY "notifications_select_own" ON public.notifications
    FOR SELECT USING (recipient_id = auth.uid());

-- Usuario: marca como leída
CREATE POLICY "notifications_update_own_read" ON public.notifications
    FOR UPDATE USING (recipient_id = auth.uid())
    WITH CHECK (recipient_id = auth.uid() AND status = 'read');

-- Sistema: insertar notificaciones (via RPC)
CREATE POLICY "notifications_insert_system" ON public.notifications
    FOR INSERT WITH CHECK (false);

-- Staff: ver todas (para debugging/admin)
CREATE POLICY "notifications_select_staff" ON public.notifications
    FOR SELECT USING (public.is_staff());

-- --------------------------------------------
-- POLÍTICAS: NOTIFICATION_PREFERENCES
-- --------------------------------------------
-- Usuario: ve y gestiona SUS preferencias
CREATE POLICY "notification_prefs_select_own" ON public.notification_preferences
    FOR SELECT USING (profile_id = auth.uid());

CREATE POLICY "notification_prefs_update_own" ON public.notification_preferences
    FOR UPDATE USING (profile_id = auth.uid())
    WITH CHECK (profile_id = auth.uid());

-- Inserción via trigger
CREATE POLICY "notification_prefs_insert_trigger" ON public.notification_preferences
    FOR INSERT WITH CHECK (false);

-- --------------------------------------------
-- POLÍTICAS: ATTENDANCE / ABSENCES
-- --------------------------------------------
-- Barbero: ve SU asistencia
CREATE POLICY "attendance_select_own" ON public.barber_attendance
    FOR SELECT USING (barber_id = public.get_my_barber_id());

-- Staff: ve toda asistencia
CREATE POLICY "attendance_select_staff" ON public.barber_attendance
    FOR SELECT USING (public.is_staff());

-- Staff/Barbero: registrar asistencia
CREATE POLICY "attendance_insert_staff_barber" ON public.barber_attendance
    FOR INSERT WITH CHECK (public.is_staff() OR barber_id = public.get_my_barber_id());

CREATE POLICY "attendance_update_staff_barber" ON public.barber_attendance
    FOR UPDATE USING (public.is_staff() OR barber_id = public.get_my_barber_id())
    WITH CHECK (public.is_staff() OR barber_id = public.get_my_barber_id());

-- Ausencias
CREATE POLICY "absences_select_own" ON public.barber_absences
    FOR SELECT USING (barber_id = public.get_my_barber_id());

CREATE POLICY "absences_select_staff" ON public.barber_absences
    FOR SELECT USING (public.is_staff());

CREATE POLICY "absences_modify_own" ON public.barber_absences
    FOR ALL USING (barber_id = public.get_my_barber_id())
    WITH CHECK (barber_id = public.get_my_barber_id());

CREATE POLICY "absences_modify_staff" ON public.barber_absences
    FOR ALL USING (public.is_staff())
    WITH CHECK (public.is_staff());

-- --------------------------------------------
-- POLÍTICAS: AUDIT_LOGS (Solo staff, inmutable)
-- --------------------------------------------
CREATE POLICY "audit_logs_select_staff" ON public.audit_logs
    FOR SELECT USING (public.is_staff());

CREATE POLICY "audit_logs_insert_system" ON public.audit_logs
    FOR INSERT WITH CHECK (false);

CREATE POLICY "audit_logs_no_modify" ON public.audit_logs
    FOR UPDATE USING (false);
CREATE POLICY "audit_logs_no_delete" ON public.audit_logs
    FOR DELETE USING (false);

-- --------------------------------------------
-- POLÍTICAS: SETTINGS
-- --------------------------------------------
-- Público: ver settings is_public = true
CREATE POLICY "settings_select_public" ON public.settings
    FOR SELECT USING (is_public = TRUE);

-- Staff: ver y gestionar todos
CREATE POLICY "settings_select_staff" ON public.settings
    FOR SELECT USING (public.is_staff());

CREATE POLICY "settings_modify_staff" ON public.settings
    FOR ALL USING (public.is_staff())
    WITH CHECK (public.is_staff());