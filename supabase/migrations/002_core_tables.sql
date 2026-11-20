-- ============================================
-- MIGRACIÓN 002: Tablas principales (Core)
-- ============================================
-- Perfiles, Clientes, Barberos, Servicios
-- ============================================

-- --------------------------------------------
-- PERFILES (vinculado a auth.users)
-- --------------------------------------------
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name VARCHAR(120) NOT NULL,
    phone VARCHAR(20),
    avatar_url TEXT,
    role VARCHAR(20) NOT NULL DEFAULT 'client'
        CHECK (role IN ('client', 'barber', 'admin', 'receptionist', 'owner')),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.profiles IS 'Perfiles de usuario extendidos desde auth.users. El rol determina permisos en la aplicación.';
COMMENT ON COLUMN public.profiles.role IS 'Roles: client, barber, admin, receptionist, owner';

-- --------------------------------------------
-- CLIENTES (datos adicionales del cliente)
-- --------------------------------------------
CREATE TABLE public.customers (
    profile_id UUID PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
    dni VARCHAR(12) UNIQUE,
    birth_date DATE,
    preferences JSONB DEFAULT '{}'::jsonb,
    notes TEXT,
    marketing_consent BOOLEAN NOT NULL DEFAULT FALSE,
    marketing_consent_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.customers IS 'Datos adicionales específicos de clientes (no barberos/admins)';

-- --------------------------------------------
-- BARBEROS / PROFESIONALES
-- --------------------------------------------
CREATE TABLE public.barbers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    profile_id UUID UNIQUE REFERENCES public.profiles(id) ON DELETE SET NULL,
    display_name VARCHAR(120) NOT NULL,
    slug VARCHAR(120) UNIQUE NOT NULL,
    bio TEXT,
    phone VARCHAR(20),
    email CITEXT,
    avatar_url TEXT,
    specialization TEXT[],
    years_experience SMALLINT CHECK (years_experience >= 0),
    hire_date DATE,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    sort_order SMALLINT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.barbers IS 'Barberos/profesionales del establecimiento. profile_id vincula con auth si el barbero tiene acceso a la app';

-- --------------------------------------------
-- SERVICIOS
-- --------------------------------------------
CREATE TABLE public.services (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    price NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    duration_min INTEGER NOT NULL CHECK (duration_min > 0),
    buffer_min INTEGER NOT NULL DEFAULT 0 CHECK (buffer_min >= 0), -- tiempo extra entre citas
    category VARCHAR(50) NOT NULL DEFAULT 'general',
    image_url TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    is_public BOOLEAN NOT NULL DEFAULT TRUE, -- visible en catálogo público
    requires_confirmation BOOLEAN NOT NULL DEFAULT FALSE,
    sort_order SMALLINT NOT NULL DEFAULT 0,
    metadata JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.services IS 'Catálogo de servicios ofrecidos. price en PEN (S/). duration_min en minutos.';

-- --------------------------------------------
-- RELACIÓN BARBERO-SERVICIO (quién hace qué)
-- --------------------------------------------
CREATE TABLE public.barber_services (
    barber_id UUID NOT NULL REFERENCES public.barbers(id) ON DELETE CASCADE,
    service_id UUID NOT NULL REFERENCES public.services(id) ON DELETE CASCADE,
    duration_override_min INTEGER CHECK (duration_override_min > 0), -- duración específica de este barbero para este servicio
    price_override NUMERIC(10,2) CHECK (price_override >= 0), -- precio específico (raro, pero posible)
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    sort_order SMALLINT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (barber_id, service_id)
);

COMMENT ON TABLE public.barber_services IS 'Asignación de servicios a barberos. duration_override_min permite que un barbero tarde más/menos en un servicio específico.';

-- --------------------------------------------
-- ÍNDICES BÁSICOS
-- --------------------------------------------
CREATE INDEX idx_profiles_role ON public.profiles(role);
CREATE INDEX idx_profiles_is_active ON public.profiles(is_active);
CREATE INDEX idx_barbers_is_active ON public.barbers(is_active);
CREATE INDEX idx_barbers_slug ON public.barbers(slug);
CREATE INDEX idx_services_is_active ON public.services(is_active);
CREATE INDEX idx_services_is_public ON public.services(is_public);
CREATE INDEX idx_services_category ON public.services(category);
CREATE INDEX idx_services_slug ON public.services(slug);
CREATE INDEX idx_barber_services_barber ON public.barber_services(barber_id);
CREATE INDEX idx_barber_services_service ON public.barber_services(service_id);
CREATE INDEX idx_barber_services_active ON public.barber_services(is_active);