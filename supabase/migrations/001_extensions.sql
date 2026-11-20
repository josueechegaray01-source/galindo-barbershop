-- ============================================
-- MIGRACIÓN 001: Extensiones PostgreSQL requeridas
-- ============================================
-- Ejecutar primero antes que cualquier otra migración
-- ============================================

-- UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- UUID-OSSP para gen_random_uuid() alternative
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- btree_gist para exclusion constraints (anti-doble-reserva)
CREATE EXTENSION IF NOT EXISTS "btree_gist";

-- citext para emails case-insensitive
CREATE EXTENSION IF NOT EXISTS "citext";

-- pg_trgm para búsquedas trigram (futuro)
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Verificar extensiones instaladas
DO $$
DECLARE
    ext_record RECORD;
BEGIN
    RAISE NOTICE 'Extensiones instaladas:';
    FOR ext_record IN SELECT extname FROM pg_extension WHERE extname IN ('pgcrypto', 'uuid-ossp', 'btree_gist', 'citext', 'pg_trgm') ORDER BY extname
    LOOP
        RAISE NOTICE '  - %', ext_record.extname;
    END LOOP;
END $$;