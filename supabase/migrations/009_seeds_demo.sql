-- ============================================
-- MIGRACIÓN 009: Datos DEMO (Semillas iniciales)
-- ============================================
-- Servicios, Barberos, Asignaciones (Ficticios rotulados DEMO)
-- ============================================

-- Nota: Estos datos son puramente DEMO para pruebas y desarrollo.
-- El negocio real deberá reemplazar o actualizar esta información.

-- --------------------------------------------
-- 1. SERVICIOS DEMO
-- --------------------------------------------
INSERT INTO public.services (id, name, slug, description, price, duration_min, buffer_min, category, is_active, is_public, sort_order) VALUES
('11111111-1111-1111-1111-111111111111', 'Corte Clásico Galindo', 'corte-clasico-galindo', 'Corte tradicional con tijera y máquina, incluye lavado y acabado con productos premium.', 25.00, 30, 5, 'cortes', TRUE, TRUE, 1),
('22222222-2222-2222-2222-222222222222', 'Diseño de Barba con Toalla Caliente', 'diseno-barba-toalla-caliente', 'Perfilado de barba con navaja, toalla caliente y aceites esenciales hidratantes.', 20.00, 25, 5, 'barba', TRUE, TRUE, 2),
('33333333-3333-3333-3333-333333333333', 'Combo Galindo (Corte + Barba)', 'combo-galindo-corte-barba', 'Experiencia completa: Corte clásico y diseño de barba con toalla caliente.', 40.00, 55, 5, 'combos', TRUE, TRUE, 3),
('44444444-4444-4444-4444-444444444444', 'Corte Infantil (Niños)', 'corte-infantil-ninos', 'Corte especial para engreídos de la casa (hasta 12 años).', 20.00, 30, 5, 'cortes', TRUE, TRUE, 4),
('55555555-5555-5555-5555-555555555555', 'Afeitado Tradicional', 'afeitado-tradicional', 'Afeitado clásico al ras con navaja, espuma caliente y loción aftershave.', 18.00, 20, 5, 'barba', TRUE, TRUE, 5)
ON CONFLICT (id) DO NOTHING;

-- --------------------------------------------
-- 2. BARBEROS DEMO (Perfiles se crearán cuando los usuarios se registren, aquí creamos los registros base)
-- Nota: En Supabase, para asociar barberos a auth.users, se pueden crear usuarios en Auth o dejar profile_id NULL temporalmente.
-- --------------------------------------------
INSERT INTO public.barbers (id, display_name, slug, bio, phone, email, specialization, years_experience, is_active, sort_order) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'Claudio Galindo', 'claudio-galindo', 'Fundador y maestro barbero con más de 25 años de experiencia en Ica.', '+51 987654321', 'claudio@galindobarbershop.pe', ARRAY['Corte Clásico', 'Barba', 'Navaja'], 25, TRUE, 1),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'Carlos Mendoza', 'carlos-mendoza', 'Especialista en fades modernos, diseños y texturas.', '+51 912345678', 'carlos@galindobarbershop.pe', ARRAY['Fade', 'Corte Moderno', 'Diseños'], 6, TRUE, 2),
('cccccccc-cccc-cccc-cccc-cccccccccccc', 'Miguel Torres', 'miguel-torres', 'Experto en arreglos de barba, perfilado y tratamientos capilares.', '+51 998877665', 'miguel@galindobarbershop.pe', ARRAY['Barba', 'Toalla Caliente', 'Afeitado'], 8, TRUE, 3)
ON CONFLICT (id) DO NOTHING;

-- --------------------------------------------
-- 3. ASIGNACIÓN BARBERO-SERVICIO (Todos los barberos hacen todos los servicios en DEMO)
-- --------------------------------------------
INSERT INTO public.barber_services (barber_id, service_id, is_active)
SELECT b.id, s.id, TRUE
FROM public.barbers b
CROSS JOIN public.services s
ON CONFLICT (barber_id, service_id) DO NOTHING;

-- --------------------------------------------
-- 4. HORARIOS INDIVIDUALES DEMO (Opcional, usan business_hours por defecto)
-- --------------------------------------------
-- Aquí podemos dejar que usen business_hours, o asignar un horario especial al maestro Claudio
INSERT INTO public.barber_hours (barber_id, weekday, start_time, end_time, is_open, break_start, break_end, is_break_active)
SELECT 
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::UUID,
    weekday,
    '09:00'::TIME,
    '18:00'::TIME,
    TRUE,
    '13:00'::TIME,
    '14:00'::TIME,
    TRUE
FROM generate_series(1, 6) AS weekday
ON CONFLICT (barber_id, weekday) DO NOTHING;

-- Domingo cerrado para Claudio también
INSERT INTO public.barber_hours (barber_id, weekday, start_time, end_time, is_open)
VALUES ('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa'::UUID, 0, '09:00', '20:00', FALSE)
ON CONFLICT (barber_id, weekday) DO NOTHING;