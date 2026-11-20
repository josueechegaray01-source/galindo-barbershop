-- ============================================
-- MIGRACIÓN 005: Pagos, Fidelización, Reseñas, Notificaciones
-- ============================================
-- payments, loyalty_programs, loyalty_transactions, reviews, notifications
-- ============================================

-- --------------------------------------------
-- MÉTODOS DE PAGO (enum)
-- --------------------------------------------
DO $$ BEGIN
    CREATE TYPE public.payment_method AS ENUM (
        'cash',       -- Efectivo
        'yape',       -- Yape (Perú)
        'plin',       -- Plin (Perú)
        'card',       -- Tarjeta débito/crédito
        'transfer',   -- Transferencia bancaria
        'other'       -- Otro
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE public.payment_status AS ENUM (
        'pending',      -- Pendiente de confirmación
        'confirmed',    -- Confirmado
        'partial',      -- Pago parcial
        'refunded',     -- Reembolsado
        'cancelled'     -- Cancelado
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- --------------------------------------------
-- PAGOS
-- --------------------------------------------
CREATE TABLE public.payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    appointment_id UUID REFERENCES public.appointments(id) ON DELETE SET NULL,
    walk_in_id UUID REFERENCES public.walk_ins(id) ON DELETE SET NULL,
    customer_id UUID NOT NULL REFERENCES public.customers(profile_id) ON DELETE CASCADE,
    amount NUMERIC(10,2) NOT NULL CHECK (amount >= 0),
    method public.payment_method NOT NULL,
    status public.payment_status NOT NULL DEFAULT 'pending',
    reference VARCHAR(100), -- código de operación Yape/Plin, últimos 4 dígitos tarjeta, etc.
    notes TEXT,
    confirmed_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    confirmed_at TIMESTAMPTZ,
    receipt_number VARCHAR(50) UNIQUE, -- número de comprobante generado
    receipt_pdf_url TEXT, -- URL del PDF generado en storage
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CHECK (appointment_id IS NOT NULL OR walk_in_id IS NOT NULL)
);

COMMENT ON TABLE public.payments IS 'Registro de pagos por citas y walk-ins. Un pago puede ser parcial o completo.';

-- --------------------------------------------
-- PROGRAMA DE FIDELIZACIÓN
-- --------------------------------------------
CREATE TABLE public.loyalty_programs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    points_per_sol NUMERIC(5,2) NOT NULL DEFAULT 1.00 CHECK (points_per_sol > 0), -- puntos por cada S/ 1 gastado
    points_per_visit INTEGER NOT NULL DEFAULT 0 CHECK (points_per_visit >= 0), -- puntos extra por visita
    min_points_redeem INTEGER NOT NULL DEFAULT 100 CHECK (min_points_redeem > 0),
    points_value_sol NUMERIC(10,4) NOT NULL DEFAULT 0.01 CHECK (points_value_sol > 0), -- valor en soles de 1 punto
    expires_months INTEGER NOT NULL DEFAULT 12 CHECK (expires_months > 0), -- expiración en meses
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    tiers JSONB DEFAULT '[]'::jsonb, -- niveles: [{"name": "Bronce", "min_points": 0, "discount_pct": 0}, ...]
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.loyalty_programs IS 'Configuración del programa de fidelización. Un negocio puede tener uno activo.';

-- Insertar programa por defecto (DEMO)
INSERT INTO public.loyalty_programs (name, description, points_per_sol, points_per_visit, min_points_redeem, points_value_sol, expires_months, tiers) VALUES
('Galindo Club', 'Programa de fidelidad Galindo Barbershop', 1.00, 10, 100, 0.01, 12,
 '[{"name": "Bronce", "min_points": 0, "discount_pct": 0, "color": "#CD7F32"},
  {"name": "Plata", "min_points": 500, "discount_pct": 5, "color": "#C0C0C0"},
  {"name": "Oro", "min_points": 1500, "discount_pct": 10, "color": "#FFD700"},
  {"name": "Platino", "min_points": 3000, "discount_pct": 15, "color": "#E5E4E2"}]')
ON CONFLICT DO NOTHING;

-- --------------------------------------------
-- TRANSACCIONES DE FIDELIZACIÓN
-- --------------------------------------------
DO $$ BEGIN
    CREATE TYPE public.loyalty_transaction_type AS ENUM (
        'earned_purchase',   -- Ganados por compra
        'earned_visit',      -- Ganados por visita
        'earned_bonus',      -- Ganados por bono/promoción
        'earned_referral',   -- Ganados por referido
        'redeemed',          -- Canjeados (descuento)
        'expired',           -- Expirados
        'adjusted',          -- Ajuste manual (admin)
        'refunded'           -- Devueltos por cancelación
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE TABLE public.loyalty_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL REFERENCES public.customers(profile_id) ON DELETE CASCADE,
    program_id UUID NOT NULL REFERENCES public.loyalty_programs(id) ON DELETE CASCADE,
    appointment_id UUID REFERENCES public.appointments(id) ON DELETE SET NULL,
    payment_id UUID REFERENCES public.payments(id) ON DELETE SET NULL,
    type public.loyalty_transaction_type NOT NULL,
    points INTEGER NOT NULL, -- positivo = ganados, negativo = canjeados/expirados
    balance_after INTEGER NOT NULL CHECK (balance_after >= 0),
    description TEXT,
    expires_at TIMESTAMPTZ, -- cuándo expiran estos puntos (si aplica)
    created_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.loyalty_transactions IS 'Historial inmutable de movimientos de puntos de fidelidad.';

CREATE INDEX idx_loyalty_transactions_customer ON public.loyalty_transactions(customer_id);
CREATE INDEX idx_loyalty_transactions_appointment ON public.loyalty_transactions(appointment_id);
CREATE INDEX idx_loyalty_transactions_created ON public.loyalty_transactions(created_at);

-- --------------------------------------------
-- RESEÑAS Y CALIFICACIONES
-- --------------------------------------------
CREATE TABLE public.reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    customer_id UUID NOT NULL REFERENCES public.customers(profile_id) ON DELETE CASCADE,
    barber_id UUID REFERENCES public.barbers(id) ON DELETE SET NULL,
    service_id UUID REFERENCES public.services(id) ON DELETE SET NULL,
    appointment_id UUID UNIQUE REFERENCES public.appointments(id) ON DELETE SET NULL, -- una reseña por cita
    rating SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    title VARCHAR(200),
    comment TEXT,
    is_public BOOLEAN NOT NULL DEFAULT TRUE,
    is_verified BOOLEAN NOT NULL DEFAULT FALSE, -- verificada = cita completada real
    response TEXT, -- respuesta del barbero/admin
    responded_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    responded_at TIMESTAMPTZ,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.reviews IS 'Reseñas de clientes. appointment_id UNIQUE asegura max 1 reseña por cita.';

CREATE INDEX idx_reviews_barber ON public.reviews(barber_id) WHERE is_public = TRUE;
CREATE INDEX idx_reviews_service ON public.reviews(service_id) WHERE is_public = TRUE;
CREATE INDEX idx_reviews_customer ON public.reviews(customer_id);
CREATE INDEX idx_reviews_rating ON public.reviews(rating);

-- --------------------------------------------
-- TIPOS DE NOTIFICACIÓN
-- --------------------------------------------
DO $$ BEGIN
    CREATE TYPE public.notification_channel AS ENUM (
        'in_app',       -- Dentro de la app
        'email',        -- Correo electrónico
        'whatsapp',     -- WhatsApp (requiere integración externa)
        'sms',          -- SMS (requiere proveedor)
        'push'          -- Push notification (futuro)
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    CREATE TYPE public.notification_status AS ENUM (
        'pending',      -- Pendiente de envío
        'sent',         -- Enviado
        'delivered',    -- Entregado (confirmado por proveedor)
        'read',         -- Leído (solo in_app)
        'failed',       -- Falló
        'cancelled'     -- Cancelado
    );
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- --------------------------------------------
-- NOTIFICACIONES
-- --------------------------------------------
CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipient_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    channel public.notification_channel NOT NULL DEFAULT 'in_app',
    type VARCHAR(50) NOT NULL, -- ej: 'appointment_confirmed', 'appointment_reminder', 'payment_received', 'review_received'
    title VARCHAR(200) NOT NULL,
    body TEXT NOT NULL,
    data JSONB DEFAULT '{}'::jsonb, -- datos extra: appointment_id, deep_link, etc.
    status public.notification_status NOT NULL DEFAULT 'pending',
    priority SMALLINT NOT NULL DEFAULT 0, -- mayor = más urgente
    scheduled_for TIMESTAMPTZ, -- para envíos programados (recordatorios)
    sent_at TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    read_at TIMESTAMPTZ,
    error_message TEXT,
    external_id VARCHAR(100), -- ID del proveedor (WhatsApp, email, push)
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.notifications IS 'Sistema de notificaciones multicanal. scheduled_for para recordatorios automáticos.';

CREATE INDEX idx_notifications_recipient ON public.notifications(recipient_id);
CREATE INDEX idx_notifications_status ON public.notifications(status);
CREATE INDEX idx_notifications_scheduled ON public.notifications(scheduled_for) WHERE status = 'pending';
CREATE INDEX idx_notifications_type ON public.notifications(type);

-- --------------------------------------------
-- CONFIGURACIÓN DE NOTIFICACIONES POR USUARIO
-- --------------------------------------------
CREATE TABLE public.notification_preferences (
    profile_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    in_app_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    email_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    whatsapp_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    sms_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    push_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    -- Tipos específicos
    appointment_reminders BOOLEAN NOT NULL DEFAULT TRUE,
    appointment_confirmations BOOLEAN NOT NULL DEFAULT TRUE,
    appointment_changes BOOLEAN NOT NULL DEFAULT TRUE,
    payment_receipts BOOLEAN NOT NULL DEFAULT TRUE,
    promotions BOOLEAN NOT NULL DEFAULT FALSE,
    reviews_requests BOOLEAN NOT NULL DEFAULT TRUE,
    -- Horarios de no molestar
    quiet_hours_start TIME,
    quiet_hours_end TIME,
    timezone VARCHAR(50) NOT NULL DEFAULT 'America/Lima',
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.notification_preferences IS 'Preferencias de notificación por usuario. quiet_hours en zona horaria del usuario.';

-- Insertar preferencias por defecto para nuevos usuarios (via trigger en profiles)